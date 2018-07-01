## imported

usage() {
  echo -e "${1}"

  exit 0
}

die() {
  printf "${1}" "${2}" >&2

  exit 1
}

## promptly-apply

apply_usage="\
usage:
  promply apply

see 'promptly help apply' for more information"

cmd_apply() {
  prompt_l="$(promptly parse-index --no-resolve --left)"
  prompt_r="$(promptly parse-index --no-resolve --right)"
  prompt_t="$(promptly parse-index --no-resolve --title)"

  # for each line, parse normally and for components do:
  # declare -f ${component} | tail -n +3 | head -n -1 | tr -d '\n' | awk '{$1=$1};1' 

  echo -e "${prompt_l}\n${prompt_r}\n${prompt_t}" > "${PROMPTLY_HOME}/active"
}

main() {
  while [ -n "${1}" ]; do
    case "${1}" in
    --) shift; break;;
    -*) case "${1}" in
    -h|--help)  usage "${apply_usage}" ;;
    -*)         die "fatal: unknown option '%s'\n" "${1}" ;;
    esac ;;

    *) die "fatal: unknown option '%s'\n" "${1}" ;;

    esac
    shift

  done

  [ -z ${PROMPTLY_HOME} ] \
    && die "fatal: environment variable 'PROMPTLY_HOME' not set\n"

  source "/usr/lib/promptly/promptly-parse-config"

  cmd_apply
}

main ${@}

