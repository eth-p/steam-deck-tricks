#!/usr/bin/env zsh
# ---------------------------------------------------------------------------------------------------------------------
# steam-deck-tricks | https://github.com/eth-p/steam-deck-tricks/
# The environment used when executing 'TWEAKBUILD' files.
# ---------------------------------------------------------------------------------------------------------------------

declare -Agr CATEGORY=(
	[QUALITY_OF_LIFE]="quality-of-life"
	[THEME]="theme"
)

declare -Agr WELL_KNOWN=(
	[KDE_LOGOUT_HOOKS]="${HOME}/.config/plasma-workspace/shutdown/"
)
