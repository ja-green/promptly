## promptly-apply

apply_usage="\
usage:
  promptly apply

options:
  -h, --help    show this help screen

see 'promptly help apply' for more information"

cmd_apply() {
  prompt_l="$(promptly parse-index --no-resolve --left)"
  prompt_r="$(promptly parse-index --no-resolve --right)"
  prompt_t="$(promptly parse-index --no-resolve --title)"

  # for each line, parse normally and for components do:
  # declare -f ${component} | tail -n +3 | head -n -1 | tr -d '\n' | awk '{$1=$1};1' 

  printf "${prompt_l}\n${prompt_r}\n${prompt_t}" > "${PROMPTLY_HOME}/active"
}

main() {
  while [ -n "${1}" ]; do
    case "${1}" in
    --) shift; break;;
    -*) case "${1}" in
    -h|--help)  usage "${apply_usage}" ;;
    -*)         die "unknown option '%s'\n" "${1}" ;;
    esac ;;

    *) die "unknown option '%s'\n" "${1}" ;;

    esac
    shift

  done

  source "/usr/lib/promptly/promptly-parse-config"

  cmd_apply
}

main ${@}
