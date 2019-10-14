#!/usr/bin/env bash

_wg_completions()
{
  mapfile -t COMPREPLY < <(compgen -W "$(cd ~/wireguard || exit; fd -tf  \\.conf$ -X echo | sed -e 's/mullvad-//g' -e 's/\.conf//g')" -- "${COMP_WORDS[1]}")
}

complete -F _wg_completions wgup
complete -F _wg_completions wgdown
