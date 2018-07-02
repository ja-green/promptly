## promptly-edit

edit_usage="\
usage:
  promptly edit [options]

options:
  -e, --editor  specify an editor to use
  -h, --help    show this help screen

see 'promptly help edit' for more information"

cmd_edit() {
  if [[ -f "${PROMPTLY_HOME}/index" ]]; then

    if [ ! -z "${editor}" ]; then
      "${editor}" "${PROMPTLY_HOME}/index"
    elif [ ! -z "${EDITOR}" ]; then
      "${EDITOR}" "${PROMPTLY_HOME}/index"
    elif type nano; then
      nano "${PROMPTLY_HOME}/index"

    else
      error "no editor specified\n"
    fi

  else
    die "index not found\n"
  fi
}

main() {
  while [ -n "${1}" ]; do
    case "${1}" in
    --) shift; break;;
    -*) case "${1}" in
    -e|--editor)  [ ! -z "${2}" ] && editor="${2}"; shift || die "option '%s' requires an argument" "${1}" ;;
    -h|--help)    usage "${edit_usage}" ;;
    -*)           die "unknown option '%s'\n" "${1}" ;;
    esac ;;

    *) die "unknown option '%s'\n" "${1}" ;;

    esac
    shift

  done

  source "/usr/lib/promptly/promptly-parse-config"

  cmd_edit
}

main ${@}
