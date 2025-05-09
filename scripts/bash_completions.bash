#!/usr/bin/env bash

_x_completions() {
  local words cword
  _init_completion || return

  mapfile -t COMPREPLY < <(COMP_WORDS="${words[*]}" COMP_CWORD=$cword "${SCRIPT_DIR}/../x" --bash-completion "${words[@]:1}")
  return 0
}
complete -F _x_completions ./x
