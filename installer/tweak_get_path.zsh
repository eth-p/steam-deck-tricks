#!/usr/bin/env zsh
# ---------------------------------------------------------------------------------------------------------------------
# steam-deck-tricks | https://github.com/eth-p/steam-deck-tricks/
#
# Function: tweak_get_path
# Gets the path to a Tweak, ensuring the Tweak is valid.
#
# SYNOPSIS:
#     tweak_get_path [tweak_name]
#
# OPTIONS:
#     --quiet/-q    -- Silences the error messages from the function.
#     --tweakbuild  -- Prints the path to the TWEAKBUILD file instead.
#
# OUTPUT:
#     Outputs the full path to the specified Tweak's root directory, or
#     to the TWEAKBUILD file if `--tweakbuild` was provided as an option.
#
# RETURNS:
#     0   -- Success
#     1   -- Invalid arguments
#     10  -- Unknown Tweak
#     11  -- Invalid or malformed Tweak
# ---------------------------------------------------------------------------------------------------------------------

tweak_get_path() {
	typeset tweak tweakdir opt_quiet opt_tweakbuild
	zparseopts -D -E -F -- \
		q=opt_quiet -quiet=opt_quiet \
		-tweakbuild=opt_tweakbuild \
		|| return 1

	# Handle the quiet option.
	if [ -n "$opt_quiet" ]; then exec 9>/dev/null; else exec 9>&2; fi

	# Calculate the path to the TWEAKBUILD file and do some basic checks for validity.
	{
		tweak="${1:?Requires tweak to be provided}"
		tweakdir="${STEAM_DECK_TRICKS_DIR}/tweaks/${tweak}"
		tweakbuild="${tweakdir}/TWEAKBUILD"

		# Check that the Tweak exists.
		if ! [ -e "$tweakdir" ]; then
			echo "unknown tweak: $tweak"
			return 10
		fi

		if ! [ -d "$tweakdir" ]; then
			echo "invalid tweak: $tweak: tweak is not a directory"
			return 11
		fi

		# Check that the tweak contains a TWEAKBUILD file.
		if ! [ -e "$tweakbuild" ]; then
			echo "invalid tweak: $tweak: TWEAKBUILD is missing"
			return 11
		fi

		if ! [ -f "$tweakbuild" ]; then
			echo "invalid tweak: $tweak: TWEAKBUILD is not a file"
			return 11
		fi

		# Check that the tweak contains a TWEAKBUILD file that is readable.
		if ! [ -f "$tweakbuild" ]; then
			echo "invalid tweak: $tweak: TWEAKBUILD is not readable"
			return 11
		fi
	} 1>&9 2>&9

	# Print the path to the Tweak or TWEAKBUILD file.
	if [ -n "${opt_tweakbuild}" ]; then
		printf "%s\n" "${tweakbuild}"
	else
		printf "%s\n" "${tweakdir}"
	fi
}

# Run if invoked directly.
if [ "$ZSH_EVAL_CONTEXT" = "toplevel" ]; then
	set -euo pipefail
	source "$(dirname -- "$(realpath -- "$0")")/_lib.zsh"
	tweak_get_path "$@"
	exit $?
fi

