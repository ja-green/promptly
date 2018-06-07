## imported

usage() {
  echo -e "${1}"

  exit 0
}

die() {
  printf "${1}" "${2}" >&2

  exit 1
}

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
    -*)         die "fatal: unknown option '%s'\n" "${1}" ;;
    esac ;;

    *) die "fatal: unknown option '%s'\n" "${1}" ;;

    esac
    shift

  done

  [ -z ${PROMPTLY_HOME} ] \
    && die "fatal: environment variable 'PROMPTLY_HOME' not set\n"

  cmd_version
}

main ${@}

