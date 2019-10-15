#!/usr/bin/env bash

_wgup_completions()
{
  mapfile -t COMPREPLY < <(compgen -W "$(cd ~/wireguard || exit; fd -tf  \\.conf$ -X echo | sed -e 's/mullvad-//g' -e 's/\.conf//g')" -- "${COMP_WORDS[1]}")
}

_wgdown_completions()
{
  mapfile -t COMPREPLY < <(compgen -W "$(wg show interfaces | sed 's/mullvad-//g')")
}

complete -F _wgup_completions wgup
complete -F _wgdown_completions wgdown
