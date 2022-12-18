#!/usr/bin/env bash

_syncup_completions() {
  [ -n "${LOCAL_SITE_MIRROR}" ] || return 0
  [ "${#COMP_WORDS[@]}" != "2" ] && return
  mapfile -t COMPREPLY < <(compgen -W "$(fd -HI --maxdepth=1 . "$LOCAL_SITE_MIRROR"/ -x echo "{/}")" -- "${COMP_WORDS[1]}")
}

_syncdown_completions() {
  _syncup_completions
}

_x_completions() {
  mapfile -t COMPREPLY < <(compgen -W "githook home-check home-switch install oracle-check oracle-switch server-check server-switch" -- "${COMP_WORDS[1]}")
}

complete -F _syncup_completions syncup
complete -F _syncdown_completions syncdown
complete -F _x_completions x
