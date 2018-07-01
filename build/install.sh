#!/bin/bash

topl="$(git rev-parse --show-toplevel || echo "${PWD}/..")"
cmds="${topl}/bin"
libs="${topl}/lib"
cpnt="${topl}/component.d"
home="${HOME}/.promptly"
user="$(who | awk 'NR==1{print $1}')"

indx="# this is your promptly prompt.
# components are added by typing their name between brackets.
# for a list of all available components, see 'promptly help components'

welcome to promptly, (username)! (pwd) (promptchar) 
"
actv="welcome to promptly, (cpnt_username)! (cpnt_pwd) (cpnt_promptchar)

"

version="$(git describe --tags --always --dirty || echo 'unversioned build')"

check_priv() {
  [ "$EUID" -ne 0 ] \
    && echo "fatal: install must be run as root" \
    && exit 1
}

inject_version() {
  sed -i -e "s/version=\"\"/version=\"${version}\"/g" "/usr/lib/promptly/promptly-version"
}

ensure_dirs() {
  mkdir -p "/usr/lib/promptly"
  mkdir -p "/dev/shm/promptly"
  mkdir -p "${home}"

  touch /dev/shm/promptly/config_{cache,checksum}

  chown -R ${user}:${user} "${home}"
  chown -R ${user}:${user} /dev/shm/promptly # config_{cache,checksum}
}

rename_builtins() {
  for cmd in "${cmds}"/*; do
    cmd_name="${cmd%.*}"
    cmd_name="${cmd_name##*/}"

    cp "${cmd}" "/usr/lib/promptly/promptly-${cmd_name}"
  done
}

copy_components() {
  cp -r "${cpnt}" "/usr/lib/promptly"
}

copy_main() {
  cp "${topl}/promptly" "/usr/local/bin"
}

create_home() {
  [ ! -f  "${home}/config" ] \
    && cp "${topl}/config" "${home}"

  [ ! -f  "${home}/index" ] \
    && touch "${home}/index" \
    && echo "${indx}" > "${home}/index"

  [ ! -f  "${home}/active" ] \
    && touch "${home}/active" \
    && echo "${actv}" > "${home}/active"

  chown -R ${user}:${user} "${home}/index"
  chown -R ${user}:${user} "${home}/active"
  chown -R ${user}:${user} "${home}/config"
}

inject_bashrc() {
  grep -Fxq "export PROMPTLY_HOME=\"\$HOME/.promptly\"" ~/.bashrc \
    || echo "export PROMPTLY_HOME=\"\$HOME/.promptly\"" >> "${HOME}/.bashrc"

  grep -Fxq "export PS1='\$(promptly parse-active --format)'" ~/.bashrc \
    || echo "export PS1='\$(promptly parse-active --format)'" >> "${HOME}/.bashrc"
}

main() {
  check_priv
  ensure_dirs
  rename_builtins
  copy_components
  copy_main
  inject_version
  create_home
  inject_bashrc
}

main

