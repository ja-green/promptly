## promptly-parse-active

parse_active_usage="\
usage:
  promptly parse-active <options>

options:
  -l, --left    parse left prompt only
  -r, --right   parse right prompt only
  -t, --title   parse window title only
  -f, --format  format prompt for PS1
  -h, --help    show this help screen

see 'promptly help parse-active' for more information"

parse_any() {
  echo "${line:$i:1}"

  return 0
}

parse_esc() {
  true $((i++))
  echo ${line:$i:1}

  return 0
}

parse_cmd() {
  cmd=${line:$((i+1))}
  cmd=${cmd%%\)*}
  
  typeset -n section="${cmd#cpnt_}"
  
  [ ! -z "${section[background]}" ] && printf "${section[background]}"
  [ ! -z "${section[foreground]}" ] && printf "${section[foreground]}"

  printf "$(eval "${cmd}" 2>/dev/null)"
  
  [ ! -z "${section[background]}" ] || [ ! -z "${section[foreground]}" ] \
    && printf "\x01$(tput sgr0)\x02"

  return $((${#cmd}+1))
}

esclen() {
  cmd=${line:$((i+1))}
  cmd=${cmd%%\)*}
 
  typeset -n section="${cmd#cpnt_}"
  echo -e ${section[compensate]:-0}
}

cmd_parse_active() {
  [ ! -f "${PROMPTLY_HOME}/active" ] \
    && die "cannot find active prompt file\n"

  # TODO to make function parsing fast - try declare -f $func; remove declaration; replace all newlines with nothing. this means you have to code semicolons in components
  # see promptly-apply - semicolons seem to be accounted for automatically
  
  prompt_l=""
  prompt_r=""
  prompt_t=""
  alignment=-1

  line="$(sed '1q;d' ${PROMPTLY_HOME}/active)"
  for (( i=0; i<${#line}; i++ )); do
    case "${line:$i:1}" in
    \() prompt_l+="$(parse_cmd)" ;;
    \\) prompt_l+="$(parse_esc)" ;;
     *) prompt_l+="$(parse_any)" ;;
    esac

    true $((i+=${?}))
  done

  line="$(sed '2q;d' ${PROMPTLY_HOME}/active)"
  for (( i=0; i<${#line}; i++ )); do
    case "${line:$i:1}" in
    \() true $((alignment+=$(esclen)))
        prompt_r+="$(parse_cmd)" ;;
    \\) prompt_r+="$(parse_esc)" ;;
     *) prompt_r+="$(parse_any)" ;;
    esac 

    true $((i+=${?}))
  done
 
  line="$(sed '3q;d' ${PROMPTLY_HOME}/active)"
  for (( i=0; i<${#line}; i++ )); do
    case "${line:$i:1}" in
    \() prompt_t+="$(parse_cmd)" ;;
    \\) prompt_t+="$(parse_esc)" ;;
     *) prompt_t+="$(parse_any)" ;;
    esac 
    
    true $((i+=${?}))
  done

  if [ ! -z "${format}" ]; then
    [ ! -z "${prompt_r}" ] \
      && prompt_r="$(printf "${prompt_r}" | tr -d '\001\002')"

    [ ! -z "${prompt_r}" ] && printf "\x01$(tput sc)%$(($(tput cols)+${alignment}))s$(tput rc)\x02" "${prompt_r}"
    [ ! -z "${prompt_l}" ] && printf "%s" "${prompt_l}"
    [ ! -z "${prompt_t}" ] && printf "\x01\033]0;%s\007\x02" "${prompt_t}"

  else
    if   [ ! -z "${t_only}" ]; then
      echo -e "${prompt_t}"
    elif [ ! -z "${l_only}" ]; then
      echo -e "${prompt_l}"
    elif [ ! -z "${r_only}" ]; then
      echo -e "${prompt_r}"
    fi
  fi
}

main() {
  while [ -n "${1}" ]; do
    case "${1}" in
    --) shift; break;;
    -*) case "${1}" in
    -l|--left)   l_only=1 ;;
    -r|--right)  r_only=1 ;;
    -t|--title)  t_only=1 ;;
    -f|--format) format=1 ;;
    -h|--help)   usage "${parse_apply_usage}" ;;
    -*)          die "unknown option '%s'\n" "${1}" ;;
    esac ;;

    *) die "unknown option '%s'\n" "${1}" ;;

    esac
    shift

  done

  source "/usr/lib/promptly/component.d/git"
  source "/usr/lib/promptly/component.d/system"
  source "/usr/lib/promptly/promptly-parse-config"

  cmd_parse_active
}

main ${@}
