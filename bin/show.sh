## promptly-show

show_usage="\
usage:
  promply show [options]

options:
  -a, --all     show all active prompt sections
  -l, --left    show left prompt
  -r, --right   show right prompt
  -t, --title   show window title
  -h, --help    show this help screen

see 'promptly help show' for more information"

show_left() {
  prompt="$(promptly parse-index --left)"
  [ ! -z "${prompt}" ] || [ ! -z "${show_l}" ] || [ ! -z "${show_a}" ] \
    && echo -e "your left prompt will display as:\n  ${prompt}\n"
}

show_right() {
  prompt="$(promptly parse-index --right)"   
  [ ! -z "${prompt}" ] || [ ! -z "${show_r}" ] || [ ! -z "${show_a}" ] \
    && echo -e "your right prompt will display as:\n  ${prompt}\n"
}

show_title() {
  prompt="$(promptly parse-index --title)"
  [ ! -z "${prompt}" ] || [ ! -z "${show_t}" ] || [ ! -z "${show_a}" ] \
    && echo -e "your window title will display as:\n  ${prompt}\n"
}

cmd_show() {
  if [[ -f "${PROMPTLY_HOME}/index" ]]; then

    declare -A show_prompt=(
      [l]="$(show_left)"
      [r]="$(show_right)"
      [t]="$(show_title)"
    )

    echo -e "your prompt is set to:"

    while read -r line; do
      echo -e "  ${line}"
    done < "${PROMPTLY_HOME}/index"

    echo -e "${show_prompt[l]}"
    echo -e "${show_prompt[r]}"
    echo -e "${show_prompt[t]}"

  else
    die "prompt index not found\n"
  fi
}

main() {
  while [ -n "${1}" ]; do
    case "${1}" in
    --) shift; break;;
    -*) case "${1}" in
    -l|--left)  show_l=1 ;;
    -r|--right) show_r=1 ;;
    -t|--title) show_t=1 ;;
    -a|--all)   show_a=1 ;;
    -h|--help)  usage "${show_usage}" ;;
    -*)         die "unknown option '%s'\n" "${1}" ;;
    esac ;;

    *) die "unknown option '%s'\n" "${1}" ;;

    esac
    shift

  done

  source "/usr/lib/promptly/promptly-parse-config"

  cmd_show
}

main ${@}
