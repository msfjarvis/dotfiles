#!/usr/bin/env bash

_x_completions() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local cmd=${COMP_WORDS[1]}
  local commands="boot chart check gradle-hash test switch"

  if [[ $COMP_CWORD -eq 1 ]]; then
    mapfile -t COMPREPLY < <(compgen -W "$commands" -- "$cur")
    return 0
  fi

  case $cmd in
  check)
    if [[ $cur == -* ]]; then
      mapfile -t COMPREPLY < <(compgen -W "--local" -- "$cur")
    fi
    ;;
  gradle-hash)
    # No specific completions for gradle version
    ;;
  *) ;;
  esac
}

# Register completion
if [[ -n ${BASH_VERSION:-} ]]; then
  complete -F _x_completions x
fi
