## promptly-version

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

version=""

version_usage="\
usage:
  promply version

options:
  -h, --help        show this screen
  -n, --no-license  suppress license information

see 'promptly help version' for more information"

license_info="\
copyright (c) 2018 Jack Green (ja-green)

this program comes with absolutely no warranty. this is free 
software, and you are welcome to redistribute it under certain 
conditions. see 'promptly help --license' for more information"

cmd_version() {
  printf "promptly ${version}\n"

  [ -z "${no_license}" ] \
    && printf "\n${license_info}\n"
}

main() {
  while [ -n "${1}" ]; do
    case "${1}" in
    --) shift; break;;
    -*) case "${1}" in
    -h|--help)       usage "${version_usage}" ;;
    -n|--no-license) no_license=1 ;;
    -*)              die "unknown option '%s'\n" "${1}" ;;
    esac ;;

    *) die "unknown option '%s'\n" "${1}" ;;

    esac
    shift

  done

  source "/usr/lib/promptly/promptly-parse-config"

  cmd_version
}

main ${@}
