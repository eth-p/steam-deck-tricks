#!/usr/bin/env zsh
# ---------------------------------------------------------------------------------------------------------------------
# steam-deck-tricks | https://github.com/eth-p/steam-deck-tricks/
#
# Function: run_tweakbuild
# Execute the code inside a TWEAKBUILD file.
#
# SYNOPSIS:
#     run_tweakbuild [file]
#
# OPTIONS:
#     --quiet/-q  -- Silences the error messages from the function.
#
# INPUT:
#     Zsh code to be executed before loading the TWEAKBUILD file.
#     Pre-execution and post-execution hooks can be declared with `pre` and `post` functions.
#
# RETURNS:
#     0   -- Success
#     1   -- Invalid arguments
#     10  -- Unknown Tweak
#     11  -- Invalid or malformed Tweak
# ---------------------------------------------------------------------------------------------------------------------

run_tweakbuild() {
	local tweakbuild tweakdir opt_quiet opt_dir
	zparseopts -D -E -F -- \
		q=opt_quiet -quiet=opt_quiet \
        C=opt_dir -chdir=opt_dir \
		|| return 1

	if [ -n "$opt_quiet" ]; then exec 9>/dev/null; else exec 9>&2; fi
    {
        tweakbuild="$(realpath "${1:?Requires tweakbuild file to be provided}")" || return $?
        tweakdir="${opt_dir[2]:-$(dirname -- "$tweakbuild")}"
        tweak="$(basename -- "$(dirname -- "$tweakbuild")")"

        # Check that the TWEAKBUILD file exists.
        if ! [ -f "$tweakbuild" ]; then
            echo "missing TWEAKBUILD file: $tweakbuild"
            return 10
        fi
    } 1>&9 2>&9

	# Run the TWEAKBUILD file in a subprocess.
	(
		set -euo pipefail
		cd "$tweakdir"

		typeset -g STEAM_DECK_TRICKS_INSTALL=false
		typeset -g tweak="$tweak"
		typeset -g tweakdir="$tweakdir"
		typeset -g tweakbuild="$tweakbuild"

        # Load the hooks.
        local hook_pre='true'
        local hook_post='true'

        eval "$(cat)"

        if [ ${+functions[pre]} -eq 1 ]; then
            hook_pre="$(functioncode pre)"
            unset -f pre
        fi

        if [ ${+functions[post]} -eq 1 ]; then
            hook_post="$(functioncode post)"
            unset -f post
        fi

        # Run the pre hook.
        eval "$hook_pre"

        # Load TWEAKBUILD environment.
        local script
        for script in "$STEAM_DECK_TRICKS_DIR/installer/env"/*.zsh; do
            source "$script"
        done
        unset script

        # Run the TWEAKBUILD contents in semi-protected environment.
        # The hook_pre and hook_post variables will be shadowed, and protected variables will be shadowed and marked as read-only.
        function () {
            typeset -r hook_pre hook_post
            typeset var; for var in "${tweakbuild_protected_vars[@]}"; do
                typeset -r $var="${(P)var}"
            done; unset var

            source "$tweakbuild";
        } || return 11

        # Run the post hook.
        eval "$hook_post"
	) || return $?
}

tweakbuild_protected_vars=(
    tweak
    tweakdir
    tweakbuild
    STEAM_DECK_TRICKS_INSTALL
)

# Run if invoked directly.
if [ "$ZSH_EVAL_CONTEXT" = "toplevel" ]; then
	set -euo pipefail
	source "$(dirname -- "$(realpath -- "$0")")/_lib.zsh"
	run_tweakbuild "$@"
	exit $?
fi
