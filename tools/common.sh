#!/usr/bin/env bash
# vim: set ai expandtab sw=2 ts=2 sts=2 re=2:
#
# SPDX-FileCopyrightText: 2023 Pablo Hörtner <redtux@pm.me>
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Copyright © 2023 by Pablo Hörtner <redtux@pm.me>. All rights reserved.
# You can find the GPL v3.0 here:  https://www.gnu.org/licenses/gpl-3.0
# Attribution required if you use this file (or parts) in your projects.
#
# ./common.sh -- Common functions

# Enable strict mode
IFS=$'\n\t'
set -euo pipefail

# Set environment variables
set_env_vars() {
  ENV_FILE="${PWD}/.env"
  if [[ ! -f "${ENV_FILE}" ]]; then
    eval "echo \"$(envsubst < example.env)\"" > "${ENV_FILE}"
  fi
  # shellcheck source=/dev/null
  source "${ENV_FILE}"
}

# Set log title color
log_title() {
  local color='\033[1;35m'  # Purple
  local nc='\033[0m'
  printf "%s \n${color}${1}${nc}\n"
}

# Set title color
title() {
  local color='\033[1;34m'  # Light White
  local nc='\033[0m'
  printf "%s \n${color}${1}${nc}\n"
}

# Functions for consistent messaging
build_title() {
  title "==== 🔨 Building Mautic Image · $1 💫 ===="
  echo
}
publish_title() {
  title "==== 📻 Publishing Mautic Image · $1 💫 ===="
  title "Uploading to container registry"
}
registry_title() {
  title "==== 🌐 $1 Registry · Login 💫 ===="
  echo
}

# Function for successful build
build_success() {
  title "✅ Build successful 🙂"
}

# Function for failed build
build_failed() {
  title "❎ Build failed 😵"
  exit 1
}

# Check for Podman
docker() {
  if command -v podman >/dev/null; then
    podman "$@"
  else
    command docker "$@"
  fi
}

# Check for Podman Compose
docker-compose() {
  if command -v podman-compose >/dev/null; then
    podman-compose "$@"
  else
    command docker-compose "$@"
  fi
}
