prql() { 
  ([ -z "$1" ] || [ "$1" == "-" ] || [ -f "$1" ]) && prqlc compile "$@" || echo "$1" | prqlc compile - "${@:2}"; 
}

capitalize() {
  local input="$1"
  local first_letter="$(echo "${input:0:1}" | tr '[:lower:]' '[:upper:]')"
  local rest_of_string="${input:1}"
  echo "${first_letter}${rest_of_string}"
}

prql-import() { 
  if ([[ -d "$1" ]] && [[ -f "$1/$(capitalize $1).prql" ]]); then
    cd "$1" && prql-mod "$(capitalize $1).prql"
  elif [[ -f "$1.prql" ]]; then
    cat "$1.prql" | sed -r "s/^let[ ]+/let $1${2:-__}/"
  else
    echo "Could not import '$library_name'. Aborting ..."
    return 1
  fi
}

prql-mod() { 
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
      import_replacement="$(prql-import "$library_name" "$separator")"
      if [[ $? -ne 0 ]]; then
	echo "ERROR: $import_replacement"
        return 1
      fi
      output=$(echo "$output" | awk -v import_replacement="$import_replacement" '{gsub("'"$line"'", import_replacement)}1')
      output=$(echo "$output" | sed -r "s/\<$library_name\>\./$library_name$separator/g")
    fi
  done
  echo "$output"
}

