#!/usr/bin/env bash

_x_completions() {
  mapfile -t COMPREPLY < <(compgen -W "darwin-check darwin-switch githook home-check home-switch install oracle-check oracle-switch" -- "${COMP_WORDS[1]}")
}

complete -F _x_completions x
