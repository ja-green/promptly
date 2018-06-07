## imported

usage() {
  echo -e "${1}"
}

die() {
  printf "${1}" "${2}" >&2

  exit 1 
}

## parse-index

source "/usr/lib/promptly/component.d/git"
source "/usr/lib/promptly/component.d/system"

parse_index_usage="\
usage:
  promptly parse-index <options>

options:
  -l, --left    parse left prompt only
  -r, --right   parse right prompt only
  -t, --title   parse window title only
  -f, --format  format prompt for PS1
  -h, --help    show this help screen

see 'promptly help parse-index' for more information"

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

cmd_parse_index() {
  [ ! -f "${PROMPTLY_HOME}/index" ] \
    && die "fatal: cannot find index prompt file\n"

  demo_ps1=""
  section="L"

  declare -A prompt

  while read -r line; do
    [[ "${line}" == \#* ]] && continue

    for (( i=0; i<${#line}; i++ )); do

      case "${line:$i:2}" in
      T:) section="T"; true $((i+=2)) ;;
      L:) section="L"; true $((i+=2)) ;;
      R:) section="R"; true $((i+=2)) ;;
      esac

      case "${section}" in
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
      R) case "${line:$i:1}" in
          \() prompt[r]+="$(parse_cmd)" ;;
          \\) prompt[r]+="$(parse_esc)" ;;
           *) prompt[r]+="$(parse_any)" ;;
         esac ;;
      esac

      true $((i+=${?}))

    done
  done < "${PROMPTLY_HOME}/index"

  if [ ! -z "${format}" ]; then
    [ ${prompt[t]+_} ] && t_p="${prompt[t]}"
    [ ${prompt[l]+_} ] && l_p="${prompt[l]}"
    [ ${prompt[r]+_} ] && r_p="${prompt[r]}"

    printf "$(tput sc)%$(($(tput cols)-1))s$(tput rc)%s\033]0;%s\007" \
            "${r_p}" "${l_p}" "${t_p}"

  else
    if   [ ! -z "${t_only}" ]; then
      echo -e "${prompt[t]}"
    elif [ ! -z "${l_only}" ]; then
      echo -e "${prompt[l]}"
    elif [ ! -z "${r_only}" ]; then
      echo -e "${prompt[r]}"
    fi
  fi
}

main() {
  while [ -n "${1}" ]; do
    case "${1}" in
    --) shift; break;;
    -*) case "${1}" in
    -l|--left)   l_only=1 ;;
    -r|--right)  r_only=1 ;;
    -t|--title)  t_only=1 ;;
    -f|--format) format=1 ;;
    -h|--help)   usage "${parse_index_usage}" ;;
    -*)          die "fatal: unknown option '%s'\n" "${1}" ;;
    esac ;;

    *) die "fatal: unknown option '%s'\n" "${1}" ;;

    esac
    shift

  done

  cmd_parse_index
}

main ${@}

