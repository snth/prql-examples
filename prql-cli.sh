prql() { 
  input=$( ([[ -z "$1" ]] || [[ "$1" == "-" ]] || [[ -f "$1" ]]) && cat "${1:--}" || echo -e "$1" )
  query="$( echo "$input" | prql-lib )"
  output="${2:--}"
  options="${@:3}"
  if [ -n "$PRQL_COMPILE_OPTIONS" ]; then
    echo "Using PRQL_COMPILE_OPTIONS=$PRQL_COMPILE_OPTIONS" >&2
    options="${options[@]} ${PRQL_COMPILE_OPTIONS}"
  fi
  echo "DEBUG: prqlc compile - $output ${options[@]}" >&2
  result="$( echo "$query" | prqlc compile - "$output" "${options[@]}")"
  if [[ $? -ne 0 ]]; then
    echo -e "\n# QUERY\n\n$query\n\n"
    return 1
  fi
  echo "$result"
}

prql-git() {
  # Requires mergestat
  sql=$(prql-lib "$1" | prqlc compile --target=sql.sqlite --hide-signature-comment)
  (exit $?) && mergestat "${sql}" ${@:2}
}

prql-exec() {
  # Looks for PRQL_EXEC_COMMAND and passes output to that if present
  sql=$( prql "$@" )
  echo "$( env | grep PRQL_ )" >&2
  if (exit $?) && [ -n "$PRQL_EXEC_COMMAND" ]; then
    echo "Using PRQL_EXEC_COMMAND=$PRQL_EXEC_COMMAND" >&2
    exec_cmd="$PRQL_EXEC_COMMAND"
    echo "DEBUG: $exec_cmd $sql" >&2
    $exec_cmd $sql
  else
    echo "ERROR: No PRQL_EXEC_COMMAND found!"
    echo -e "# SQL\n\n$sql"
    return 1
  fi
}

capitalize() {
  local input="$1"
  local first_letter="$(echo "${input:0:1}" | tr '[:lower:]' '[:upper:]')"
  local rest_of_string="${input:1}"
  echo "${first_letter}${rest_of_string}"
}

prql-import() { 
  # FIXME: Add support for aliases
  separator="${2:-__}"
  prefix="${3:-$1}"
  prql_lib_path="${PRQL_LIB_PATH:-.}"
  PRQL_LIB_PATH=""
  echo "Using PRQL_LIB_PATH=$prql_lib_path" >&2
  IFS=":"
  for lib_dir in $prql_lib_path; do
    if ([[ -d "$lib_dir/$1" ]] && [[ -f "$lib_dir/$1/$(capitalize $1).prql" ]]); then
      output=$(cd "$lib_dir/$1" && prql-lib "$(capitalize $1).prql" "$separator" "$prefix")
      echo "Imported $lib_dir/$1/$(capitalize $1).prql" >&2
      # Also source .env file if present for prql-exec
      if [ -f "$lib_dir/$1/.env" ]; then
        #cat "$lib_dir/$1/.env" >&2
        source "$lib_dir/$1/.env"
	if [ -n "PRQL_EXEC_COMMAND" ]; then
	  export PRQL_EXEC_COMMAND="$PRQL_EXEC_COMMAND"
	  echo export PRQL_EXEC_COMMAND="$PRQL_EXEC_COMMAND" >&2
	fi
	if [ -n "PRQL_COMPILE_OPTIONS" ]; then
	  export PRQL_COMPILE_OPTIONS="$PRQL_COMPILE_OPTIONS"
	  echo export PRQL_COMPILE_OPTIONS="$PRQL_COMPILE_OPTIONS" >&2
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
  echo "$output"
}

prql-lib() { 
  input=$( ([[ -z "$1" ]] || [[ "$1" == "-" ]] || [[ -f "$1" ]]) && cat "${1:--}" || echo -e "$1" )
  output="$input"
  separator="${2:-__}"
  # Define the pattern to match lines
  match_pattern="^import[[:space:]]\{1,\}[[:alnum:]]\{1,\}[[:space:]]\{0,\}$"
  # Use sed to extract lines matching the pattern and capture the two words following "import"
  matches=$(echo "$output" | sed -n "/$match_pattern/p")
  # Iterate over the matches using a for loop
  IFS=$'\n'  # Set the Internal Field Separator to newline to iterate over lines
  for line in $matches; do
    if [[ "$line" =~ ^import[[:space:]]+([[:alnum:]]+)[[:space:]]* ]]; then
      library_name="${BASH_REMATCH[1]}"
      prefix="${3:-$library_name}"
      import_replacement="$(prql-import "$library_name" "$separator" "$prefix")"
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
  echo "$output"
}
