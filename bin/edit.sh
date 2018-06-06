## imported

usage() {
  echo -e "${1}"
}

die() {
  printf "${1}" "${2}" >&2

  exit 1
}

## edit

edit_usage="\
usage:                                   \n
  promptly edit [options]                \n
                                         \n
options:                                 \n
  -e, --editor  specify an editor ti use \n
  -h, --help    show this help screen    \n"

cmd_edit() {
  if [[ -f "${PROMPTLY_HOME}/PROMPT_STR" ]]; then

    if [ ! -z ${EDITOR} ]; then
      ${EDITOR} "${PROMPTLY_HOME}/PROMPT_STR"
    elif [ ! -z "${editor}" ]; then
      ${editor} "${PROMPTLY_HOME}/PROMPT_STR"
    elif type nano; then
      nano "${PROMPTLY_HOME}/PROMPT_STR"

    else
      die "fatal: no editor specified"
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
    -h|--help)  usage ${parse_prompt_usage} ;;
    -*)         die "fatal: unknown option '%s'\n" "${1}" ;;
    esac ;;

    *) die "fatal: unknown option '%s'\n" "${1}" ;;

    esac
    shift

  done

  [ -z ${PROMPTLY_HOME} ] \
    && die "fatal: environment variable 'PROMPTLY_HOME' not set\n"

  echo -e "$(cmd_edit)"
}

main ${@}

