#!/usr/bin/env bats

load ${test_root}/helpers.sh
load ${components}/system

@test "cpnt_system_promptchar" {
  run cpnt_system_promptchar
  [ "${status}" -eq 0 ]
  [ "${output}" = "$" ]
}

@test "cpnt_system_user" {
  run cpnt_system_user
  [ "${status}" -eq 0 ]
  [ "${output}" = "$(whoami)" ]
}

@test "cpnt_system_uptime" {
  run cpnt_system_uptime
  [ "${status}" -eq 0 ]
  [ "${output}" =~ "$(uptime)" ]
}

@test "cpnt_system_pwd" {
  run cpnt_system_pwd
  [ "${status}" -eq 0 ]
  [ "${output}" = "${PWD}" ]
}

@test "cpnt_system_shortpwd" {
  run cpnt_system_shortpwd
  [ "${status}" -eq 0 ]
  [ "${output}" = "${PWD/#$HOME/\~}" ]
}

