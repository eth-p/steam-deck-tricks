#!/usr/bin/env zsh
# ---------------------------------------------------------------------------------------------------------------------
# steam-deck-tricks | https://github.com/eth-p/steam-deck-tricks/
#
# Function: sdt_check_flatpak
# Checks that a Flatpak is installed.
#
# SYNOPSIS:
#     sdt_check_flatpak --type flatpak --comment [comment] [id]
#
# OPTIONS:
#     --quiet/-q  -- Silences the error messages from the function.
#     --type      -- Specify the dependency type.
#     --comment   -- Specify the dependency comment.
#
# RETURNS:
#     0   -- Success
#     1   -- Invalid arguments
#     20  -- Unmet dependency
# ---------------------------------------------------------------------------------------------------------------------

sdt_check_flatpak() {
	local dep_type dep_comment dep_id
	zparseopts -D -E -F -- \
		-comment:=dep_comment \
		-type:=dep_type \
        || return 1

	dep_id="${1:?Requires dependency string to be provided}"
	flatpak info "$dep_id" &>/dev/null || return 20
}

# Run if invoked directly.
if [ "$ZSH_EVAL_CONTEXT" = "toplevel" ]; then
	set -euo pipefail
	source "$(dirname -- "$(realpath -- "$0")")/_lib.zsh"
	sdt_check_flatpak "$@"
	exit $?
fi

