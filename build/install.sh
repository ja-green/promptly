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

welcome to promptly, (username)! (shortpwd) (promptchar)
"

version="$(git describe --tags --always --dirty || echo 'unversioned build')"

inject_version() {
  sed -i -e "s/version=\"\"/version=\"${version}\"/g" "/usr/lib/promptly/promptly-version"
}

ensure_dirs() {
  mkdir -p "/usr/lib/promptly"
  mkdir -p "${home}"

  chown -R ${user}:${user} "${home}"
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
  cp "${topl}/config" "${home}"

  touch "${home}/index"
  touch "${home}/active"
  echo "${indx}" > "${home}/index"
  echo "${indx}" > "${home}/active"

  chown -R ${user}:${user} "${home}/index"
  chown -R ${user}:${user} "${home}/active"
  chown -R ${user}:${user} "${home}/config"
}

inject_bashrc() {
  echo "export PROMPTLY_HOME=\"\$HOME/.promptly\"
export PS1='\$(promptly parse-active --format)'" >> "${HOME}/.bashrc"
}

main() {
  ensure_dirs
  rename_builtins
  copy_components
  copy_main
  inject_version
  create_home
  inject_bashrc
}

main

