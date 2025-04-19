#!/usr/bin/env bash

_x_completions() {
  mapfile -t COMPREPLY < <(compgen -W "boot chart check darwin-check darwin-switch gradle-hash test switch" -- "${COMP_WORDS[1]}")
}

complete -F _x_completions x
