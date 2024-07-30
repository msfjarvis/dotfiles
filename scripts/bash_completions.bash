#!/usr/bin/env bash

_x_completions() {
  mapfile -t COMPREPLY < <(compgen -W "matara-check matara-switch darwin-check darwin-switch home-boot home-check home-switch home-test server-boot server-check server-switch" -- "${COMP_WORDS[1]}")
}

complete -F _x_completions x
