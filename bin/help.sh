## imported

usage() {
  echo -e "${1}"
}

die() {
  printf "${1}" "${2}" >&2

  exit 1
}

## help

main_usage="\
promptly - customise your bash prompt      \n
                                           \n
commands:                                  \n
  edit            edit your bash prompt    \n
  help            how help information     \n
  show            preview your bash prompt \n
  version         show version information \n
                                           \n
options:                                   \n
  -h, --help      show help information    \n
  -v, --version   show version informtion  \n
                                           \n
see 'promptly help' for help with a        \n
specific command, component or concept     \n"

help_usage="\
usage:                                     \n
  promptly help [options]                  \n
  promptly help [command]                  \n
  promptly help [concept]                  \n
                                           \n
options:                                   \n
  -a, --all   print all available commands \n
  -m, --man   show man page                \n
  -h, --help  show this help screen        \n
"
commands_list="\
commands:                                            \n
  edit      edit your bash prompt                    \n
  help      show help information                    \n
  show      show your bash prompt as it would appear \n
  version   shwo version information                 \n"

cmd_help() {
  if [ -z ${sub_cmd} ]; then
    usage ${main_usage}
  elif [ -z ${all} ]; then
    echo -e "${commands_list}"
  elif [ -z ${man} ]; then
    man promptly

  else
    man "promptly${sub_cmd}" 2>/dev/null     \
    || man "promptly-${sub_cmd}" 2>/dev/null \
    || die "fatal: no help text for '%s'\n" "${sub_cmd}"
  fi
}

main() {
  while [ -n "${1}" ]; do
    case "${1}" in
    --) shift; break;;
    -*) case "${1}" in
    -a|--all)   all=1 ;;
    -m|--man)   man=1 ;;
    -h|--help)  usage ${help_usage} ;;
    -*)         die "fatal: unknown option '%s'\n" "${1}" ;;
    esac ;;

    *) if [ -z ${sub_cmd} ]; then sub_cmd=${1} ;;

    shift

  done

  echo -e "$(cmd_help)"
}

main ${@}

