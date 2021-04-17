#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <me@msfjarvis.dev>
# SPDX-License-Identifier: MIT

set -euo pipefail

echoText "Setting app switcher to current workspace only"
gsettings set org.gnome.shell.app-switcher current-workspace-only true
