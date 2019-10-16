#!/usr/bin/env bash

_wgup_completions()
{
  mapfile -t COMPREPLY < <(compgen -W "$(fd -tf \\.conf$ ~/wireguard/ -X echo '{/.}' | sed 's/mullvad-//g')" -- "${COMP_WORDS[1]}")
}

_wgdown_completions()
{
  mapfile -t COMPREPLY < <(compgen -W "$(wg show interfaces | sed 's/mullvad-//g')" -- "${COMP_WORDS[1]}")
}

complete -F _wgup_completions wgup
complete -F _wgdown_completions wgdown
