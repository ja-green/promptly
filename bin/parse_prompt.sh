## imported

usage() {
  echo -e "${1}"
}

die() {
  printf "${1}" "${2}" >&2

  exit 1 
}

## parse-prompt

source "${PROMPTLY_HOME}/component.d/git"
source "${PROMPTLY_HOME}/component.d/system"

parse_prompt_usage="\
usage:                                  \n
  promptly parse-prompt <options>        \n
                                        \n
options:                                \n
  -l, --left    parse left prompt only  \n
  -r, --right   parse right prompt only \n
  -t, --title   parse window title only \n
  -h, --help    show this help screen   \n"

parse_any() {
  echo "${line:$i:1}"

  return 0
}

parse_esc() {
  true $((i++))
  echo ${line:$i:1}

  return 0
}

parse_cmd() {
  cmd=${line:$((i+1))}
  cmd=${cmd%%\)*}
  echo -e "$(eval cpnt_${cmd} 2>/dev/null)"

  return $((${#cmd}+1))
}

cmd_parse_prompt() {
  demo_ps1=""
  section="L"

  while read -r line; do
    [[ "${line}" == \#* ]] && continue

    for (( i=0; i<${#line}; i++ )); do

      case "${line:$i:2}" in
      R:) section="R"; true $((i+=2)) ;;
      T:) section="T"; true $((i+=2)) ;;
      L:) section="L"; true $((i+=2)) ;;
      esac

      case "${section}" in
      R) case "${line:$i:1}" in
          \() prompt[r]+="$(parse_cmd)" ;;
          \\) prompt[r]+="$(parse_esc)" ;;
           *) prompt[r]+="$(parse_any)" ;;
         esac ;;
      T) case "${line:$i:1}" in
          \() prompt[t]+="$(parse_cmd)" ;;
          \\) prompt[t]+="$(parse_esc)" ;;
           *) prompt[t]+="$(parse_any)" ;;
         esac ;;
      L) case "${line:$i:1}" in
          \() prompt[l]+="$(parse_cmd)" ;;
          \\) prompt[l]+="$(parse_esc)" ;;
           *) prompt[l]+="$(parse_any)" ;;
         esac ;;
      esac

      true $((i+=${?}))

    done
  done < "${prog_home}/PROMPT_STR"

  if   [ -z ${l_only} ]; then
    echo -e "${prompt[l]}"
  elif [ -z ${r_only} ]; then
    echo -e "${prompt[r]}"
  elif [ -z ${t_only} ]; then
    echo -e "${prompt[t]}"
  fi 
}

main() {
  while [ -n "${1}" ]; do
    case "${1}" in
    --) shift; break;;
    -*) case "${1}" in
    -l|--left)  l_only=1 ;;
    -r|--right) r_only=1 ;;
    -t|--title) t_only=1 ;;
    -h|--help)  usage ${parse_prompt_usage} ;;
    -*)         die "fatal: unknown option '%s'\n" "${1}" ;;
    esac ;;

    *) die "fatal: unknown option '%s'\n" "${1}" ;;

    esac
    shift

  done

  echo -e "$(cmd_parse_prompt)"
}

main ${@}

