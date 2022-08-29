#!/usr/bin/env zsh
# ---------------------------------------------------------------------------------------------------------------------
# steam-deck-tricks | https://github.com/eth-p/steam-deck-tricks/
#
# Function: tweak_install
# Installs a tweak.
#
# SYNOPSIS:
#     tweak_install [tweak_name]
#
# OPTIONS:
#     --quiet/-q    -- Silences the error messages from the function.
#     --verbose/-v  -- Prints info messages from the installer.
#
# RETURNS:
#     0   -- Success
#     1   -- Invalid arguments
#     10  -- Unknown Tweak
#     11  -- Invalid Tweak
#     32  -- Installation failed (previous version could not be removed)
#     31  -- Installation failed (could not install)
#     30  -- Installation failed (unknown error)
# ---------------------------------------------------------------------------------------------------------------------

tweak_install() {
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

	# Uninstall the old version, if installed.
	if [ -f "$tweak_file_db" ]; then
		(
			if [ -z "$opt_verbose" ]; then exec 1>/dev/null; fi
			echo "tweak is already installed; uninstalling it to provide clean environment for upgrade..."

			cd "$(dirname -- "$tweakbuild")"
			PROGRAM='tweak_install_preclean' python "${STEAM_DECK_TRICKS_DIR}/installer/py/uninstall_file_db.py" \
				< <(gunzip < "$tweak_file_db") \
				2>&9 \
				| sed 's/^/| /'
		) || result=$?
		
		typeset result=0
		if [ $result -ne 0 ]; then
			echo "tweak_install: uninstallation of previous version failed"
			echo "tweak_install: aborting installation"
			rm "$tempfile"
			return 32
		fi 1>&9
	fi

	# Get a temporary file for storing the newly-generated registry.
	typeset tempfile=''
	tempfile="$(mktemp)"

	# Generate a list of files to be installed by this Tweak.
	exec 4>&1
	typeset result=0
	(
		if [ -z "$opt_verbose" ]; then exec 1>/dev/null; fi
		echo "generating file database for future updates/uninstall..."

		{ run_tweakbuild "$tweakbuild" | gzip > "$tempfile" } <<-'EOI'
			pre() {
				STEAM_DECK_TRICKS_INSTALL=true
			}

			post() {
				{
					__sdt_journal_prepare
					"install:${STEAM_DECK_TRICKS_DISTRO}" 1>&4
					__sdt_journal_commit
					__dsl_export done
				} 3>&1 | python "$STEAM_DECK_TRICKS_DIR/installer/py/build_file_db.py" "$tweak" "$version" 2>&9
			}
		EOI
	) || result=$?

	if [ $result -ne 0 ]; then
		echo "tweak_install: unexpected error generating file database"
		return 11
	fi 1>&9
	
	# Install the new version.
	typeset result=0
	(
		if [ -z "$opt_verbose" ]; then exec 1>/dev/null; fi
		echo "installing tweak..."

		mv "$tempfile" "$tweak_file_db"
		cd "$(dirname -- "$tweakbuild")"
		
		PROGRAM='tweak_install' python "${STEAM_DECK_TRICKS_DIR}/installer/py/install_file_db.py" \
			< <(gunzip < "$tweak_file_db") \
			2>&9 \
			| sed 's/^/| /'
	) || result=$?
		
	if [ $result -ne 0 ]; then
		echo "tweak_install: installation failed"
		return 31
	fi 1>&9

	# Success!
	printf "Successfully installed tweak '%s'\n" "$TWEAK_ID"
}

# Run if invoked directly.
if [ "$ZSH_EVAL_CONTEXT" = "toplevel" ]; then
	set -euo pipefail
	source "$(dirname -- "$(realpath -- "$0")")/_lib.zsh"
	tweak_install "$@"
	exit $?
fi
