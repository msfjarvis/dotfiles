#!/usr/bin/env bash

_x_completions() {
  mapfile -t COMPREPLY < <(compgen -W "crusty-check crusty-switch darwin-check darwin-switch githook home-boot home-check home-switch home-test install server-boot server-check server-switch" -- "${COMP_WORDS[1]}")
}

complete -F _x_completions x
