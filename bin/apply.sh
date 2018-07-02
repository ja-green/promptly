## promptly-apply

## Copyright (C) 2018 Jack Green (ja-green)
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <https://www.gnu.org/licenses/>.

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
