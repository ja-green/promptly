## imported

usage() {
  echo -e "${1}"
}

die() {
  printf "${1}" "${2}" >&2

  exit 1
}

## promptly-show

show_usage="\
usage:                                 \n
  promply show [options]               \n
                                       \n
options:                               \n
  -l, --left    show left prompt only  \n
  -r, --right   show right prompt only \n
  -t, --title   show window title only \n
  -h, --help    show this help screen  \n"

show_left() {
  echo -e "your left prompt will display as: \
    \n\t$(promptly parse-prompt --left)\n"
}

show_right() {
  echo -e "your right prompt will display as: \
    \n\t$(promptly parse-prompt --right)\n"
}

show_title() {
  echo -e "your window title will display as: \
    \n\t$(promptly parse-prompt --title)\n"
}

cmd_show() {
  if [[ -f "${PROMPTLY_HOME}/PROMPT_STR" ]]; then

    echo -e "your prompt is set to:"

    while read -r line; do
      echo -e "\t${line}"
    done < "${PROMPTLY_HOME}/PROMPT_STR"

    if   [ -z ${l_only} ]; then
      echo -e "$(show_left)"
    elif [ -z ${r_only} ]; then
      echo -e "$(show_right)"
    elif [ -z ${t_only} ]; then
      echo -e "$(show_title)"

    else
      [ ${prompt[l]+_} ] \
        && echo -e "$(show_left)"
      [ ${prompt[r]+_} ] \
        && echo -e "$(show_right)"
      [ ${prompt[t]+_} ] \
        && echo -e "$(show_title)"
    fi

  else
    die "fatal: 'PROMPT_STR' not found\n"
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
    -h|--help)  usage ${show_usage} ;;
    -*)         die "fatal: unknown option '%s'\n" "${1}" ;;
    esac ;;

    *) die "fatal: unknown option '%s'\n" "${1}" ;;

    esac
    shift

  done

  [ -z ${PROMPTLY_HOME} ] \
    && die "fatal: environment variable 'PROMPTLY_HOME' not set\n"

  echo -e "$(cmd_show)"
}

main ${@}

