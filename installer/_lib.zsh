#!/usr/bin/env zsh
# ---------------------------------------------------------------------------------------------------------------------
# steam-deck-tricks | https://github.com/eth-p/steam-deck-tricks/
# Initializes required variables and functions for steam-deck-tricks.
# ---------------------------------------------------------------------------------------------------------------------

# Path to the root of the steam-deck-tricks repo.
STEAM_DECK_TRICKS_DIR="${STEAM_DECK_TRICKS_DIR:-$(realpath -- "$(dirname -- "$(realpath -- "$0")")/..")}"

# Path to the steam-deck-tricks config folder.
# User preferences will be stored here.
# Default: ~/.config/steam-deck-tricks
STEAM_DECK_TRICKS_CONFIG="${STEAM_DECK_TRICKS_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/steam-deck-tricks}"

# Path to the steam-deck-tricks data folder.
# Installation data will be stored here.
# Default: ~/.local/share/steam-deck-tricks
STEAM_DECK_TRICKS_DATA="${STEAM_DECK_TRICKS_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/steam-deck-tricks}"

# Name of the current distro.
# This should NOT be overridden unless for debug purposes.
declare -gr STEAM_DECK_TRICKS_DISTRO="${STEAM_DECK_TRICKS_DISTRO:-$({
	if [ -f /etc/lsb-release ]; then
		cat /etc/lsb-release | grep '^DISTRIB_CODENAME=' \
			| cut -d'=' -f2- | tr '[[:upper:]]' '[[:lower:]]'
	elif [ -f /etc/os-release ]; then
		cat /etc/os-release | grep '^ID=' \
			| cut -d'=' -f2- | tr '[[:upper:]]' '[[:lower:]]'
	else
		echo "unknown"
	fi
})}"

# Lazily load library functions.
# This will add a lazy load function for every '*.zsh' function that doesn't start with an underscore.
for __libfile in "$STEAM_DECK_TRICKS_DIR"/installer/*.zsh; do
	__libfunc="$(basename -- "$__libfile" .zsh)"
	if [ "${__libfunc:0:1}" = "_" ]; then continue; fi
	if type "$__libfunc" &>/dev/null; then continue; fi
	eval "$(printf '%s() { source "%q"; %s "$@" || return $?; }' \
		"$__libfunc" "$__libfile" "$__libfunc")"
done

# Function for running another function within the scope of the caller.
functioncode() {
	type -f "$1" | sed '1d;$d'
}

# Create directories used by steam-deck-tricks.
[ -d "${STEAM_DECK_TRICKS_DATA}/installed" ] || mkdir -p "${STEAM_DECK_TRICKS_DATA}/installed"
