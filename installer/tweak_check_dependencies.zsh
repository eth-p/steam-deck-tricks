#!/usr/bin/env zsh
# ---------------------------------------------------------------------------------------------------------------------
# steam-deck-tricks | https://github.com/eth-p/steam-deck-tricks/
#
# Function: tweak_check_dependencies
# Checks that all tweak dependencies are met.
#
# SYNOPSIS:
#     tweak_check_dependencies [tweak_name]
#
# OPTIONS:
#     --quiet/-q   -- Silences the error messages from the function.
#     --all/-a     -- Check all dependencies, even if one failed.
#     --porcelain  -- Print output in a parser-friendly format, with fields delimited by 0x1F characters.
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

tweak_check_dependencies() {
	typeset tweak tweakbuild tweakinfo opt_quiet opt_all opt_porcelain
	zparseopts -D -E -F -- \
		q=opt_quiet -quiet=opt_quiet \
		a=opt_all -all=opt_all \
		-porcelain=opt_porcelain \
		|| return 1

	# Handle quiet option.
	if [ -n "$opt_quiet" ]; then exec 9>/dev/null; else exec 9>&2; fi

	# Read info about the Tweak.
	{
		tweak="${1:?Requires tweak to be provided}"
		tweakinfo="$(tweak_get_info $opt_quiet "$tweak")" || return $?
		eval "$tweakinfo"
	} 1>&9 2>&9

	# Check dependencies.
	typeset dependency='' message='' result=0 failures=()
	for dependency in "${TWEAK_DEPENDENCIES[@]}"; do
		message="$(check_dependency "$dependency" $opt_porcelain)" || result=$?
		case "$result" in

			# Dependency met.
			0) {
				if [ -n "$opt_porcelain" ]; then
					printf "pass\x1F%s\n" "$message"
				fi
			};;

 			# Dependency unmet.
			20) {
				failures+=("$message")

				if [ -n "$opt_porcelain" ]; then
					printf "fail\x1F%s\n" "$message"
				fi

				if [[ -z "$opt_all" ]]; then
					break
				fi
			};;

			*) {
				return $result
			};;
		esac
	done

	# If there are no failures, return 0.
	if [[ "${#failures[@]}" -eq 0 ]]; then
		return 0
	fi

	# Print the failures and return 20.
	if [ -z "$opt_porcelain" ]; then
		echo "Unmet dependencies:"
		printf " - %s\n" "${failures[@]}"
	fi

	return 20
}

# Run if invoked directly.
if [ "$ZSH_EVAL_CONTEXT" = "toplevel" ]; then
	set -euo pipefail
	source "$(dirname -- "$(realpath -- "$0")")/_lib.zsh"
	tweak_check_dependencies "$@"
	exit $?
fi
