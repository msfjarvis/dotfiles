#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <me@msfjarvis.dev>
# SPDX-License-Identifier: GPL-3.0-only

set -euo pipefail

echoText "Setting app switcher to current workspace only"
gsettings set org.gnome.shell.app-switcher current-workspace-only true
