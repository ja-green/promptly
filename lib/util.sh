is_m_cmd() {
  if [[ -z $(printf '%s\n' "${m_cmds[@]}" | grep -w ${1//-}) ]]; then
    return 1
  fi
}

is_m_cmd_set() {
  if [[ ! ${m_cmd+x} ]]; then
    return 1
  fi
}

set_m_cmd() {
  if ! is_m_cmd_set; then
    echo -e "${1}"
  fi
}

is_s_cmd() {
  if [[ -z $(printf '%s\n' "${s_cmds[@]}" | grep -w ${1//-}) ]]; then
    return 1
  fi
}

is_s_cmd_set() {
  if [[ ! ${s_cmd+x} ]]; then
    return 1
  fi
}

set_s_cmd() {
  if ! is_s_cmd_set; then
    echo -e "${1}"
  fi
}

is_component() {
  if [[ -z $(printf '%s\n' "${components[@]}" | grep -w ${1//-}) ]]; then
    return 1
  fi
}

