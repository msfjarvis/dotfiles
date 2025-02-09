#!/usr/bin/env bash

jq -c '.nodes.root.inputs | {flake: keys}' flake.lock | jq -r .flake[] | while read -r input; do
  nix flake update "${input}"
  nh os build || {
    echo "${input} failed to compile"
    exit 1
  }
  git checkout ./flake.lock
done
