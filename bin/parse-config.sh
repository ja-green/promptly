## promptly-parse-config

help_usage="\
usage:
  promptly parse-config

see 'promptly help config' for more information"

from_hex() {
  hex=$1
  
  [[ $hex == "#"* ]] \
    && hex=$(echo $1 | awk '{print substr($0,2)}')

  r=$(printf '0x%0.2s' "$hex")
  g=$(printf '0x%0.2s' ${hex#??})
  b=$(printf '0x%0.2s' ${hex#????})
  
  echo -e $((10#$(printf "%03d" "$(((r<75?0:(r-35)/40)*6*6+(g<75?0:(g-35)/40)*6+(b<75?0:(b-35)/40)+16))")))
}

parse_std() {
  validate \
    && eval "${section}[${key}]=\"${val}\"" \
    || config_err+="  invalid value for key '${key}', line ${nr}\n"
}

parse_opt() {
  validate "true|false" \
    && eval "${section}[${key}]=\"${val}\"" \
    || config_err+="  invalid value for key '${key}', line ${nr}\n"
}

parse_clr() {
  [ "${new_section}" = "1" ] \
    && true $((${section}[compensate]+=6)) \
    && new_section=0

  t256="$(from_hex ${val})"

  case "${key}" in
  *foreground) mode="setaf" ;;
  *background) mode="setab" ;;
  esac

  true $((${section}[compensate]+=$(tput ${mode} "${t256}" | wc -c))) 
  tput_hex="\x01$(tput ${mode} ${t256})\x02"

  validate "[a-fA-F0-9]{6}" \
    && eval "${section}[${key}]=\"${tput_hex}\"" \
    || config_err+="  invalid hex color for key '${key}', line ${nr}\n"

  [ "${key}" = "background" ] || [ "${key}" = "foreground" ] \
    && return

  typeset -n sec=${section}

  true $((${section}[compensate]+=6))

  case "${key}" in
  *background) strip="_background" ;;
  *foreground) strip="_foreground" ;;
  esac

  icon="${sec[${key%%$strip}]}"
  tput_rst="\x01$(tput sgr0)\x02${sec[background]}${sec[foreground]}"
  eval "${section}[${key%%$strip}]=\"${tput_hex}${icon}${tput_rst}\""
}

validate() {
  [[ ${val} =~ ${1:-.} ]] \
    && return 0 \
    || return 1
}

parse_config() {
  local line key val nr=0
  local config_err

  while IFS= read -r line; do
    (( ++nr ))

    [[ -z "$line" || "$line" = '#'* ]] && continue

    line="$(echo ${line} | awk '{$1=$1};1')"

    read -r key <<< "${line%% *}"
    read -r val <<< "${line#* =}"
   
    if [ "${val}" = "\"\"" ] || [ "${val}" = "\'\'" ]; then
      continue
    else
      val="${val%\"}"
      val="${val#\"}"
    fi

    if [ "${key:0:1}" = "[" ] && [ "${key:$((${#key}-1)):1}" = "]" ]; then
      new_section=1
      section="${key#'['}"
      section="${section%']'}"
      declare -gA "${section}"
      eval "${section}[keepalive]=1"
      sections+="${section} "
      continue
    fi

    if [[ -z "${val}" ]]; then
      config_err+="  missing value for key '${key}', line ${nr}\n"
      continue
    fi

    case "${section}" in
           core) case "${key}" in
                 editor)                                parse_std ;;
                 *)					config_err+="  unknown key '${key}', line ${nr}\n" ;;
                 esac ;;
    exit_status) case "${key}" in
		 pass_icon|fail_icon|prefix|suffix)     parse_std ;;
		 show_code)                             parse_opt ;;
                 foreground|background|\
		 pass_icon_background|\
		 pass_icon_foreground|\
		 prefix_background|prefix_foreground|\
		 suffix_background|suffix_foreground)   parse_clr ;;
                 *)					config_err+="  unknown key '${key}', line ${nr}\n" ;;
                 esac ;;

     promptchar) case "${key}" in
                 user_icon|root_icon|prefix|suffix)     parse_std ;;
                 foreground|background|\
		 user_icon_background|\
		 user_icon_foreground|\
		 prefix_background|prefix_foreground|\
		 suffix_background|suffix_foreground)	parse_clr ;;
                 *)					config_err+="  unknown key '${key}', line ${nr}\n" ;;
                 esac ;;

       username) case "${key}" in
                 prefix|suffix)				parse_std ;;
                 foreground|background|\
		 prefix_background|prefix_foreground|\
		 suffix_background|suffix_foreground)	parse_clr ;;
                 *)					config_err+="  unknown key '${key}', line ${nr}\n" ;;
                 esac ;;

       hostname) case "${key}" in
                 prefix|suffix)				parse_std ;;
                 foreground|background|\
		 prefix_background|prefix_foreground|\
		 suffix_background|suffix_foreground)	parse_clr ;;
                 *)					config_err+="  unknown key '${key}', line ${nr}\n" ;;
                 esac ;;

            cwd) case "${key}" in
                 prefix|suffix)				parse_std ;;
                 abbreviate_home|abbreviate_repo)       parse_opt ;;
                 foreground|background|\
		 prefix_background|prefix_foreground|\
		 suffix_background|suffix_foreground)	parse_clr ;;
                 *)					config_err+="  unknown key '${key}', line ${nr}\n" ;;
                 esac ;;

   git_upstream) case "${key}" in
                 prefix|suffix|no_upstream_icon|\
		 equal_icon|ahead_icon|behind_icon|\
		 diverged_icon)                         parse_std ;;
                 foreground|background|\
		 no_upstream_icon_background|\
		 no_upstream_icon_foreground|\
		 equal_icon_background|\
		 equal_icon_foreground|\
		 ahead_icon_background|\
		 ahead_icon_foreground|\
		 behind_icon_background|\
		 behind_icon_foreground|\
		 diverged_icon_background|\
		 diverged_icon_foreground|\
		 prefix_background|prefix_foreground|\
		 suffix_background|suffix_foreground)	parse_clr ;;
                 *)					config_err+="  unknown key '${key}', line ${nr}\n" ;;
                 esac ;;

      git_state) case "${key}" in
                 prefix|suffix|rebase_icon|\
		 merge_icon|cherry_pick_icon|\
		 revert_icon|bisect_icon)               parse_std ;;
                 foreground|background|\
		 rebase_icon_background|\
		 rebase_icon_foreground|\
		 merge_icon_background|\
		 merge_icon_foreground|\
		 cherry_pick_icon_background|\
		 cherry_pick_icon_foreground|\
		 revert_icon_background|\
		 revert_icon_foreground|\
		 bisect_icon_background|\
		 bisect_icon_foreground|\
		 prefix_background|prefix_foreground|\
		 suffix_background|suffix_foreground)	parse_clr ;;
                 *)					config_err+="  unknown key '${key}', line ${nr}\n" ;;
                 esac ;;

     git_branch) case "${key}" in
                 prefix|suffix)                         parse_std ;;
                 foreground|background|\
		 prefix_background|prefix_foreground|\
		 suffix_background|suffix_foreground)	parse_clr ;;
                 *)					config_err+="  unknown key '${key}', line ${nr}\n" ;;
                 esac ;;

     git_status) case "${key}" in
                 prefix|suffix|conflict_icon|\
		 modified_icon|deleted_icon|\
		 untracked_icon|added_icon|\
		 copied_icon|renamed_icon|clean_icon)   parse_std ;;
                 foreground|background|\
		 conflict_icon_background|\
		 conflict_icon_foreground|\
		 modified_icon_background|\
		 modified_icon_foreground|\
		 deleted_icon_background|\
		 deleted_icon_foreground|\
		 untracked_icon_background|\
		 untracked_icon_foreground|\
		 added_icon_background|\
		 added_icon_foreground|\
		 copied_icon_background|\
		 copied_icon_foreground|\
		 renamed_icon_background|\
		 renamed_icon_foreground|\
		 clean_icon_background|\
		 clean_icon_foreground|\
		 prefix_background|prefix_foreground|\
		 suffix_background|suffix_foreground)	parse_clr ;;
                 *)					config_err+="  unknown key '${key}', line ${nr}\n" ;;
                 esac ;;

              *) config_err+="  unknown section '${section}' for key '${key}', line ${nr}\n" ;;
    esac
  done

  if (( ${#config_err[@]} > 0 )); then
    warn "there were errors parsing the config file at '${PROMPTLY_HOME}/config':\n${config_err} \
          \nreverting to previous configuration\n"

    [ -f "/dev/shm/promptly/config_cache" ] \
      && eval "$(cat /dev/shm/promptly/config_cache)" \
      || die "cannot find any previous configuration\n"
  fi
}

cmd_config() {
  [ ! -f "${PROMPTLY_HOME}/config" ] \
    && die "config file not found in '${PROMPTLY_HOME}'\n"

  if [ -f "/dev/shm/promptly/config_checksum" ] && [ -f "/dev/shm/promptly/config_cache" ] \
  && [ "$(cat /dev/shm/promptly/config_checksum)" = "$(crc32 ${PROMPTLY_HOME}/config)" ]; then
    eval "$(cat /dev/shm/promptly/config_cache)"
  
  else
    parse_config < "${PROMPTLY_HOME}/config"

    mkdir -p "/dev/shm/promptly"
    touch "/dev/shm/promptly/config_cache"
    touch "/dev/shm/promptly/config_checksum"

    crc32 "${PROMPTLY_HOME}/config" > "/dev/shm/promptly/config_checksum"

    local config_cache
    for section in ${sections}; do
      config_cache+="$(declare -p ${section})\n"
    done

    echo -e "${config_cache%\n}" | awk '{$2="-g" OFS $2} 1' > "/dev/shm/promptly/config_cache"
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
    -*)         die "unknown option '%s'\n" "${1}" ;;
    esac ;;

    *) die "unknown option '%s'\n" "${1}" ;;

    esac
    shift

  done

  cmd_config
}

main ${@}
