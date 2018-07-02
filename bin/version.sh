## promptly-version

version=""

version_usage="\
usage:
  promply version

see 'promptly help version' for more information"

cmd_version() {
  echo "promptly ${version}"
}

main() {
  while [ -n "${1}" ]; do
    case "${1}" in
    --) shift; break;;
    -*) case "${1}" in
    -h|--help)  usage "${version_usage}" ;;
    -*)         die "unknown option '%s'\n" "${1}" ;;
    esac ;;

    *) die "unknown option '%s'\n" "${1}" ;;

    esac
    shift

  done

  source "/usr/lib/promptly/promptly-parse-config"

  cmd_version
}

main ${@}
