#!/usr/bin/env bash

_wgup_completions() {
  [ "${#COMP_WORDS[@]}" != "2" ] && return
  mapfile -t COMPREPLY < <(compgen -W "$(fd -tf \\.conf$ ~/wireguard/ -X echo '{/.}' | sed 's/mullvad-//g')" -- "${COMP_WORDS[1]}")
}

_wgdown_completions() {
  [ "${#COMP_WORDS[@]}" != "2" ] && return
  mapfile -t COMPREPLY < <(compgen -W "$(wg show interfaces | sed 's/mullvad-//g')" -- "${COMP_WORDS[1]}")
}

_syncup_completions() {
  [ -n "${LOCAL_SITE_MIRROR}" ] || return 0
  [ "${#COMP_WORDS[@]}" != "2" ] && return
  mapfile -t COMPREPLY < <(compgen -W "$(fd -HI --maxdepth=1 . "$LOCAL_SITE_MIRROR"/ -x echo "{/}")" -- "${COMP_WORDS[1]}")
}

_syncdown_completions() {
  _syncup_completions
}

complete -F _wgup_completions wgup
complete -F _wgdown_completions wgdown
complete -F _wgdown_completions wgcycle
complete -F _syncup_completions syncup
complete -F _syncdown_completions syncdown
