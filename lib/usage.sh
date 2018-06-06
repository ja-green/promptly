main_usage() {
  echo -e "${main}\n \
    \nusage:\
    \n\t${prog_name} [options] \
    \n\t${prog_name} <command> [options] \
    \n\ncommands:                   \
    \n\tedit            ${edit}     \
    \n\thelp            ${help}     \
    \n\tshow            ${show}     \
    \n\tversion         ${version}  \n"

  echo -e "${flags_global}"
  echo -e "${usage_end}"

  exit ${prog_exit}
}

m_cmd_usage() {
  eval m_cmd_arr="(\"\${${m_cmd}[@]}\")"

  about="${m_cmd_arr[0]}"
  flags="${m_cmd_arr[1]}"

  echo -e "${about}\n \
    \nusage: \
    \n\t${prog_name} ${m_cmd} [options] \
    \n\t${prog_name} ${m_cmd} [microservice] [options]\n"

  echo -e "${flags}"
  echo -e "${flags_global}"
  echo -e "${usage_end}"

  exit ${prog_exit}
}

print_version() {
  echo -e "${prog_name} version ${prog_vers}"

  exit ${prog_exit}
}

die() {
  printf "${1}" "${2}" >&2

  if is_m_cmd "${2}" \
  && [[ ${m_cmd} != "help" ]]; then
    m_cmd_usage
  fi

  prog_exit=1
  exit ${prog_exit}
}

