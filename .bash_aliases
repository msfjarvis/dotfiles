#!/usr/bin/env bash

alias nano='nano -L'
if command -v hub >/dev/null; then
    alias git=hub
fi
