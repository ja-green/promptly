#!/bin/bash

echo_to_log() {
  echo "${BATS_TEST_NAME}
    ----------
    ${output}
    ----------
    " >> ${test_log}
}

clear_log() {
  echo -n "" > ${test_log}
}

setup() {
  return
}

teardown() {
  clear_log && echo_to_log
}

errecho() {
  echo "${@}" >&2
}
