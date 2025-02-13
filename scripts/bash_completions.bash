#!/usr/bin/env bash

_x_completions() {
  mapfile -t COMPREPLY < <(compgen -W "chart darwin-check darwin-switch gradle-hash home-boot home-check home-switch home-test melody-check melody-switch server-boot server-check server-switch" -- "${COMP_WORDS[1]}")
}

complete -F _x_completions x
