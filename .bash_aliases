#!/usr/bin/env bash

alias nano='nano -L'
hub_path=$(which hub)
if (( $+commands[hub] ))
then
  alias git=$hub_path
fi
