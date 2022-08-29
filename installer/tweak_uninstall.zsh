#!/usr/bin/env zsh
# ---------------------------------------------------------------------------------------------------------------------
# steam-deck-tricks | https://github.com/eth-p/steam-deck-tricks/
#
# Function: tweak_uninstall
# Uninstalls a tweak.
#
# SYNOPSIS:
#     tweak_uninstall [tweak_name]
#
# OPTIONS:
#     --quiet/-q    -- Silences the error messages from the function.
#     --verbose/-v  -- Prints info messages from the installer.
#
# RETURNS:
#     0   -- Success
#     1   -- Invalid arguments
#     10  -- Unknown Tweak
# ---------------------------------------------------------------------------------------------------------------------

tweak_uninstall() {
	typeset tweak tweakbuild opt_quiet opt_verbose
	zparseopts -D -E -F -- \
		q=opt_quiet -quiet=opt_quiet \
		v=opt_verbose -verbose=opt_verbose \
		|| return 1

	# Handle quiet option.
	if [ -n "$opt_quiet" ]; then exec 9>/dev/null; else exec 9>&2; fi

	# Read info about the Tweak.
	{
		tweak="${1:?Requires tweak to be provided}"
		tweakbuild="$(tweak_get_path $opt_quiet "$tweak" --tweakbuild)" || return $?
		tweakinfo="$(tweak_get_info $opt_quiet "$tweak")" || return $?
		eval "$tweakinfo"
	} 1>&9 2>&9

	# Determine where the registry of installed files will end up.
	# This will be used for uninstalling the old version (if installed)
	typeset tweak_file_db=''
	tweak_file_db="${STEAM_DECK_TRICKS_DATA}/installed/${tweak}.db"

	# Fail early if not installed.
	if ! [ -f "$tweak_file_db" ]; then
		echo "tweak_uninstall: tweak is not installed: $TWEAK_ID"
		return 1
	fi 1>&9

	# Uninstall the old version.
	(
		if [ -z "$opt_verbose" ]; then exec 1>/dev/null; fi
		echo "uninstalling tweak..."

		cd "$(dirname -- "$tweakbuild")"
		PROGRAM='tweak_uninstall' python "${STEAM_DECK_TRICKS_DIR}/installer/py/uninstall_file_db.py" \
			< <(gunzip < "$tweak_file_db") \
			2>&9 \
			| sed 's/^/| /'
	) || result=$?
	
	# Success!
	rm "$tweak_file_db"
	printf "Successfully uninstalled tweak '%s'\n" "$TWEAK_ID"
}

# Run if invoked directly.
if [ "$ZSH_EVAL_CONTEXT" = "toplevel" ]; then
	set -euo pipefail
	source "$(dirname -- "$(realpath -- "$0")")/_lib.zsh"
	tweak_uninstall "$@"
	exit $?
fi
