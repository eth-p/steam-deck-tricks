#!/usr/bin/env zsh
# ---------------------------------------------------------------------------------------------------------------------
# steam-deck-tricks | https://github.com/eth-p/steam-deck-tricks/
#
# Function: tweak_get_info
# Gets information declared by a Tweak.
#
# SYNOPSIS:
#     tweak_get_info [tweak_name]
#
# OPTIONS:
#     --quiet/-q  -- Silences the error messages from the function.
#
# OUTPUT:
#     A bash/zsh-eval'able string containing information about the Tweak.
#     Example:
#         TWEAK_ID=my-tweak
#         TWEAK_NAME=foo
#         TWEAK_DESCRIPTION=bar
#         TWEAK_CATEGORY=baz
#         TWEAK_VERSION=1
#         TWEAK_DEPENDENCIES=(
#             abc/def:\ Comment
#         )
#
# RETURNS:
#     0   -- Success
#     1   -- Invalid arguments
#     10  -- Unknown Tweak
#     11  -- Invalid or malformed Tweak
# ---------------------------------------------------------------------------------------------------------------------

tweak_get_info() {
	typeset tweak tweakbuild opt_quiet
	zparseopts -D -E -F -- \
		q=opt_quiet -quiet=opt_quiet \
		|| return 1

	# Handle quiet option.
	if [ -n "$opt_quiet" ]; then exec 9>/dev/null; else exec 9>&2; fi

	# Get the path to the TWEAKBUILD file.
	{
		tweak="${1:?Requires tweak to be provided}"
		tweakbuild="$(tweak_get_path $opt_quiet "$tweak" --tweakbuild)" || return $?
	} 1>&9 2>&9

	# Run the TWEAKBUILD file and dump the variables describing it.
	run_tweakbuild "$tweakbuild" <<-'EOI'
		post() {
			printf "%s=%q\n" \
				TWEAK_ID "$tweak" \
				TWEAK_NAME "$name" \
				TWEAK_DESCRIPTION "$desc" \
				TWEAK_CATEGORY "$cat" \
				TWEAK_VERSION "$version"
			
			printf "TWEAK_DEPENDENCIES=(\n"
			printf "	%q\n" "${depends[@]}"
			printf ")\n"
		}
	EOI
}

# Run if invoked directly.
if [ "$ZSH_EVAL_CONTEXT" = "toplevel" ]; then
	set -euo pipefail
	source "$(dirname -- "$(realpath -- "$0")")/_lib.zsh"
	tweak_get_info "$@"
	exit $?
fi
