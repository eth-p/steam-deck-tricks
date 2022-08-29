#!/usr/bin/env zsh
# ---------------------------------------------------------------------------------------------------------------------
# steam-deck-tricks | https://github.com/eth-p/steam-deck-tricks/
# The install function DSL used for installing within 'TRICKBUILD' files.
# ---------------------------------------------------------------------------------------------------------------------

__sdt_disabled() {
	{
		echo "disabled command: $1"
		echo "This command is disabled in favor of the install DSL."
		echo ""
		echo "Refer to the guide for more information:"
		echo "  {{TODO}}"
	} 1>&2
	exit 250
}

__sdt_disabled_commands=(
	cp
	rm
	touch
	chmod chown
)

for __command_name in "${__sdt_disabled_commands[@]}"; do
	eval "${__command_name}() { __sdt_disabled ${__command_name}; }"
done


# ---------------------------------------------------------------------------------------------------------------------
# DSL:
# ---------------------------------------------------------------------------------------------------------------------

# Writes a DSL command that will be interpreted by the `build_file_db.py` script.
#
# Arguments:
#   $1  -- The DSL command.
#   $@  -- The data to provide, in pairs of [key value].
#
# Example:
#   __dsl_export touch \
#       key1  "val1" \
#       key2  "val2"
__dsl_export() {
	typeset name
	name="${1:?Requires DSL name}"
	shift

	{
		printf -- "---\n"
		printf -- "dsl: %s\ndata:\n" "$name"
		if [ "$#" -gt 0 ]; then
			printf -- "  %s: |-\n    %s\n" "$@"
		fi
	} 1>&3
}

__sdt_require_install() {
	if ! "$STEAM_DECK_TRICKS_INSTALL"; then
		echo "not installing"
		exit 250
	fi 1>&2
}

__SDT_TOTAL_FILES=0

__sdt_journal_prepare() {
	__SDT_DIRTY=false
	__SDT_FILES=()
	__SDT_RENAME=()
	__SDT_DEST=''
	__SDT_PERM=0755
}

__sdt_journal_commit() {
	if ! "$__SDT_DIRTY"; then return 0; fi

	if [[ "${#__SDT_FILES[@]}" -eq 0 ]]; then
		echo "No files were specified."
		return 1
	fi 1>&2

	if [[ -z "$__SDT_DEST" ]]; then
		echo "No destination specified for file(s): "
		printf " - %s\n" "${__SDT_FILES[@]}"
		return 1
	fi 1>&2

	if [[ "${#__SDT_RENAME[@]}" -ne 0 && "${#__SDT_FILES[@]}" -ne "${#__SDT_RENAME[@]}" ]]; then
		echo "When renaming files, all files must be renamed."
		printf "There are %s files specified, but %s names.\n" \
			"${#__SDT_FILES[@]}" \
			"${#__SDT_RENAME[@]}"
		return 1
	fi 1>&2

	{
		local i fsrc fdst_dir fdst_name
		for i in {1..${#__SDT_FILES[@]}}; do
			fsrc="${__SDT_FILES[$i]}"
			fdst_dir="${__SDT_DEST}"
			fdst_name="${__SDT_RENAME[$i]:-${__SDT_RENAME[1]:-$fsrc}}"

			__dsl_export "put" \
				source      "$fsrc" \
				destination "${fdst_dir}/${fdst_name}" \
				permission  "${__SDT_PERM}"

			__SDT_TOTAL_FILES=$(( __SDT_TOTAL_FILES + 1 ))
		done
	}

	__sdt_journal_prepare
}

put() {
	__sdt_require_install

	__sdt_journal_commit
	__SDT_DIRTY=true
	__SDT_FILES=("$@")
}

dest() {
	__sdt_require_install

	__SDT_DIRTY=true
	__SDT_DEST="$1"
}

name() {
	__sdt_require_install

	__SDT_DIRTY=true
	__SDT_RENAME=("$@")
}

perm() {
	__sdt_require_install
	
	__SDT_DIRTY=true
	__SDT_PERM="$1"
}
