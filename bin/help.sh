## imported

usage() {
  echo -e "${1}"

  exit 0
}

die() {
  printf "${1}" "${2}" >&2

  exit 1
}

## help

main_usage="\
promptly - customise your bash prompt

usage:
  promptly [options]
  promptly [command] [options]
  promptly [command] [subcommand]

commands:                                 
  apply           apply your changes
  edit            edit your bash prompt   
  help            how help information    
  show            preview your bash prompt
  version         show version information
                                         
options:                                 
  -h, --help      show help information 
  -v, --version   show version informtion
                                       
see 'promptly help' for help with a
specific command, component or concept

see 'promptly help -a' for a list of 
all available commands"

help_usage="\
usage:
  promptly help [options]
  promptly help [command]
  promptly help [concept]
  promptly help [component]

options:
  -a, --all   print all available commands
  -m, --man   show man page
  -h, --help  show this help screen

see 'promptly help help' for more information"

commands_list="\
builtin commands available from '/usr/lib/promptly':
  apply     apply your changes
  edit      edit your bash prompt
  help      show help information
  show      preview your bash prompt
  version   show version information"

list_commands() {
  user_supplied="$(compgen -ac | grep 'promptly-' | sed -e 's/^promptly-//')"

  echo -e "${commands_list}"

  if [ ! -z "${user_supplied}" ]; then
    echo -e "\ncustom commands available from elsewhere in your \$PATH"

    for command in ${user_supplied}; do
      echo "  ${command}"
    done
  fi

  echo -e "\nsee 'promptly help' for help with a specific command, component or concept"

}

cmd_help() {
  if [ ! -z "${all}" ]; then
    list_commands
  elif [ ! -z "${man}" ]; then
    man promptly 2>/dev/null \
    || die "fatal: no help text for promptly\n"
  elif [ -z "${sub_cmd}" ]; then
    usage "${main_usage}"

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
    -h|--help)  usage "${help_usage}" ;;
    -*)         die "fatal: unknown option '%s'\n" "${1}" ;;
    esac ;;

    *) [ -z "${sub_cmd}" ] && sub_cmd="${1}" ;;

    esac
    shift

  done

  source "/usr/lib/promptly/promptly-parse-config"

  cmd_help
}

main ${@}

