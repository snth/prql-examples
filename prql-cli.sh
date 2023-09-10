prql() { 
  prql-init
  input=$( ([[ -z "$1" ]] || [[ "$1" == "-" ]] || [[ -f "$1" ]]) && cat "${1:--}" || echo -e "$1" )
  destinaton="${2:--}"
  options="${@:3}"
  prql-lib "$@" 	# TODO: should this use just $input?
  query="$PRQL_LIB_OUTPUT"
  prql-compile "$query" "$destination" "$options"
  if [[ $? -ne 0 ]]; then
    prql-cleanup
    return $?
  fi
  sql="$PRQL_COMPILE_OUTPUT"
  echo "$sql"
  prql-cleanup
}

prql-init() {
  ORIGINAL_PRQL_COMPILE_OPTIONS="$PRQL_COMPILE_OPTIONS"
  ORIGINAL_PRQL_EXEC_COMMAND="$PRQL_EXEC_COMMAND"
}

prql-cleanup() {
  PRQL_COMPILE_OPTIONS="$ORIGINAL_PRQL_COMPILE_OPTIONS"
  unset ORIGINAL_PRQL_COMPILE_OPTIONS
  PRQL_EXEC_COMMAND="$ORIGINAL_PRQL_EXEC_COMMAND"
  unset ORIGINAL_PRQL_EXEC_COMMAND
}

prql-compile() { 
  IFS=" "
  query="$1"
  options="${@:2}"
  if [ -n "$PRQL_COMPILE_OPTIONS" ]; then
    echo "Using PRQL_COMPILE_OPTIONS=$PRQL_COMPILE_OPTIONS" >&2
    options="${options[@]} ${PRQL_COMPILE_OPTIONS}"
  fi
  PRQL_COMPILE_OUTPUT="$( echo "$query" | prqlc compile - - )"
  if [[ $? -ne 0 ]]; then
    echo -e "\n# QUERY\n\n$query\n\n"
    return 1
  fi
}

prql-git() {
  # Requires mergestat
  sql=$(prql-lib "$1" | prqlc compile --target=sql.sqlite --hide-signature-comment)
  (exit $?) && mergestat "${sql}" ${@:2}
}

prql-exec() {
  # Looks for PRQL_EXEC_COMMAND and passes output to that if present
  prql-init
  input=$( ([[ -z "$1" ]] || [[ "$1" == "-" ]] || [[ -f "$1" ]]) && cat "${1:--}" || echo -e "$1" )
  destinaton="${2:--}"
  options="${@:3}"
  prql-lib "$@" 	# TODO: should this use just $input?
  query="$PRQL_LIB_OUTPUT"
  prql-compile "$query" "$destination" "$options"
  if [[ $? -ne 0 ]]; then
    prql-cleanup
    return $?
  fi
  sql="$PRQL_COMPILE_OUTPUT"
  echo "$( env | grep PRQL_ )" >&2
  if [ -n "$PRQL_EXEC_COMMAND" ]; then
    echo "Using PRQL_EXEC_COMMAND=$PRQL_EXEC_COMMAND" >&2
    $PRQL_EXEC_COMMAND "$sql"
  else
    echo "ERROR: No PRQL_EXEC_COMMAND found!"
    echo -e "# SQL\n\n$sql"
    prql-cleanup
    return 1
  fi
  prql-cleanup
}

capitalize() {
  local input="$1"
  local first_letter="$(echo "${input:0:1}" | tr '[:lower:]' '[:upper:]')"
  local rest_of_string="${input:1}"
  echo "${first_letter}${rest_of_string}"
}

prql-import() { 
  # FIXME: Add support for aliases
  local output=""
  local separator="${2:-__}"
  local prefix="${3:-$1}"
  local prql_lib_path="${PRQL_LIB_PATH:-.}"
  PRQL_LIB_PATH=""
  echo "Using PRQL_LIB_PATH=$prql_lib_path" >&2
  IFS=":"
  for lib_dir in $prql_lib_path; do
    if ([[ -d "$lib_dir/$1" ]] && [[ -f "$lib_dir/$1/$(capitalize $1).prql" ]]); then
      pushd "$lib_dir/$1" > /dev/null
      prql-lib "$(capitalize $1).prql" "$separator" "$prefix"
      popd > /dev/null
      output="$PRQL_LIB_OUTPUT"
      echo "Imported $lib_dir/$1/$(capitalize $1).prql" >&2
      # Also source .env file if present for prql-exec
      if [ -f "$lib_dir/$1/.env" ]; then
        #cat "$lib_dir/$1/.env" >&2
        source "$lib_dir/$1/.env"
	if [ -n "PRQL_EXEC_COMMAND" ]; then
	  export PRQL_EXEC_COMMAND="$PRQL_EXEC_COMMAND"
	fi
	if [ -n "PRQL_COMPILE_OPTIONS" ]; then
	  export PRQL_COMPILE_OPTIONS="$PRQL_COMPILE_OPTIONS"
	fi
      fi
      break
    elif [[ -f "$lib_dir/$1.prql" ]]; then
      output=$(cat "$lib_dir/$1.prql")
      echo "Imported $lib_dir/$1.prql" >&2
      break
    fi
  done
  # apply the prefix to all let statements
  output=$(echo "$output" | sed -r "s/^let[ ]+/let $prefix$separator/")
  PRQL_IMPORT_OUTPUT="$output"
}

prql-lib() { 
  local input=$( ([[ -z "$1" ]] || [[ "$1" == "-" ]] || [[ -f "$1" ]]) && cat "${1:--}" || echo -e "$1" )
  local output="$input"
  local separator="${2:-__}"
  # Define the pattern to match lines
  local match_pattern="^import[[:space:]]\{1,\}[[:alnum:]]\{1,\}[[:space:]]\{0,\}$"
  # Use sed to extract lines matching the pattern and capture the two words following "import"
  local matches=$(echo "$output" | sed -n "/$match_pattern/p")
  # Iterate over the matches using a for loop
  IFS=$'\n'  # Set the Internal Field Separator to newline to iterate over lines
  for line in $matches; do
    if [[ "$line" =~ ^import[[:space:]]+([[:alnum:]]+)[[:space:]]* ]]; then
      local library_name="${BASH_REMATCH[1]}"
      local prefix="${3:-$library_name}"
      prql-import "$library_name" "$separator" "$prefix"
      local import_replacement="$PRQL_IMPORT_OUTPUT"
      if [[ $? -ne 0 ]]; then
	echo "ERROR: $import_replacement"
        return 1
      fi
      # Replace the import statement with the code from the module/library
      output=$(echo "$output" | awk -v import_replacement="$import_replacement" '{gsub("'"$line"'", import_replacement)}1')
      # Replace references to the module/library
      output=$(echo "$output" | sed -r "s/\<$library_name\>\./$prefix$separator/g")
    fi
  done
  # FIXME: Test for remaining import statements and report error
  PRQL_LIB_OUTPUT="$output"
}
