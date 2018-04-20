#!/bin/bash

test_root=$(cd "$(dirname "${0}")" && pwd)
test_log="${test_root}/logs/bats.log"
components="${test_root}/../component.d"

set -e

run_bats() {
  for test in $(find "$1" -name \*.bats); do
    echo "=> $(basename ${test})"

    set +e
    bats "${test}"
    if [[ ${?} -ne 0 ]]; then
        exit=1
    fi
    set -e

    echo
  done
}

exit=0
export test_file="${1}"

if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "fatal: bash 4.1 or later is required to run these tests"
    exit 1
fi

if [ "${BASH_VERSINFO[0]}" -eq 4 ] && [ "${BASH_VERSINFO[1]}" -lt 1 ]; then
    echo "fatal: bash 4.1 or later is required to run these tests"
    exit 1
fi

if [[ -z "${test_file}" ]]; then
    test_file="${test_root}/core/"
fi

if [[ ! -e "${test_file}" ]]; then
    echo "fatal: bats file or directory not found: ${test_file}"
    exit 1
fi

export test_root
export components
export test_log

> "${test_log}"

run_bats "${test_file}"

exit ${exit}

