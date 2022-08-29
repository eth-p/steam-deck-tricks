#!/usr/bin/env zsh
# ---------------------------------------------------------------------------------------------------------------------
# steam-deck-tricks | https://github.com/eth-p/steam-deck-tricks/
#
# Function: check_dependency
# Checks that a dependency is met.
#
# SYNOPSIS:
#     check_dependency [type]/[id](: [comment])
#     check_dependency --type [type] --comment [comment] [id]
#
# OPTIONS:
#     --quiet/-q   -- Silences the error messages from the function.
#     --porcelain  -- Print output in a parser-friendly format, with fields delimited by 0x1F characters.
#     --type       -- Specify the dependency type.
#     --comment    -- Specify the dependency comment.
#
# RETURNS:
#     0   -- Success
#     1   -- Invalid arguments
#     10  -- Invalid dependency specifier
#     11  -- Unsupported dependency type
#     20  -- Unmet dependency
# ---------------------------------------------------------------------------------------------------------------------

check_dependency() {
	typeset dep_type dep_comment dep_id opt_quiet opt_porcelain
	zparseopts -D -E -F -- \
		-quiet=opt_quiet q=opt_quiet \
		-comment:=dep_comment \
		-type:=dep_type \
		-porcelain=opt_porcelain \
		|| return 1

	# Handle quiet option.
	if [ -n "$opt_quiet" ]; then exec 9>/dev/null; else exec 9>&2; fi

	# Handle options.
	dep_id="${1:?Requires dependency string to be provided}" 2>&9

	# Parse the dependency string if needed.
	# Format: [type]/[id](: [comment])
	if [[ -z "$dep_type" && -z "$dep_comment" ]]; then
		[[ "$dep_id" =~ '^([a-z]+)/([a-zA-Z0-9_\.\-]+)(:[[:space:]]*(.*))?$' ]] || {
			echo "check_dependency: invalid dependency specifier: $dep_id"
			return 10
		} 2>&9

		dep_type="${match[1]}"
		dep_id="${match[2]}"
		dep_comment="${match[4]}"
	else
		dep_type="${dep_type[2]}"
		dep_comment="${dep_comment[2]:-}"
	fi

	# Check that there exists a command or function that can check the dependency type.
	if ! type "sdt_check_${dep_type}" &>/dev/null; then
		echo "check_dependency: unsupported dependency type: $dep_type"
		return 11
	fi 2>&9

	# Run the command/function to check the dependency.
	typeset result
	"sdt_check_${dep_type}" \
		"${dep_id}" \
		--type "${dep_type}" \
		--comment "${dep_comment}" \
		1>&2 2>&9 \
		|| result=$?

	if [ $result -eq 0 ]; then
		return 0
	fi

	# Print machine-parseable info.
	if [ -n "$opt_porcelain" ]; then
		printf "%s\x1F%s\x1F%s" "$dep_type" "$dep_id" "$dep_comment"
		return 20
	fi
	
	# Print human-readable info.
	printf "'%s' on '%s'" "$dep_id" "${dep_type}"
	if [ -n "${dep_comment}" ]; then
		printf " (%s)" "$dep_comment"
	fi
	printf "\n"
	return 20
}

# Run if invoked directly.
if [ "$ZSH_EVAL_CONTEXT" = "toplevel" ]; then
	set -euo pipefail
	source "$(dirname -- "$(realpath -- "$0")")/_lib.zsh"
	check_dependency "$@"
	exit $?
fi
