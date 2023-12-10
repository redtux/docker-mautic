#!/usr/bin/env bash
# vim: set ai expandtab sw=2 ts=2 sts=2 re=2:
#
# SPDX-FileCopyrightText: 2023 Pablo Hörtner <redtux@pm.me>
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Copyright © 2023 by Pablo Hörtner <redtux@pm.me>. All rights reserved.
# You can find the AGPL v3.0 here: https://www.gnu.org/licenses/agpl-3.0
# Attribution required if you use this file (or parts) in your projects.
#
# ./build.sh -- Build images

# Enable strict mode
IFS=$'\n\t'
set -euo pipefail

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

# Function for consistent messaging
heading_msg() {
  title "==== 🔨 Building Mautic Image · $1 💫 ===="
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

# Set environment variables
ENV_FILE="${PWD}/.env"
if [[ ! -f "${ENV_FILE}" ]]; then
  cp -a example.env "${ENV_FILE}"
fi

# Source environment variables
# shellcheck source=/dev/null
source "${ENV_FILE}"

# Log start of script
clear
log_title "==== 🎬 Starting update script 🚀 ===="
echo
./update.sh
# Log end of update script
log_title "==== 🌠 Updating sources finished 🎉 ===="

# Check for Podman Compose
docker-compose() {
  if command -v podman-compose >/dev/null; then
    podman-compose "$@"
  else
    command docker-compose "$@"
  fi
}

# Build Mautic Image - Apache HTTP
heading_msg "Apache HTTP"
if docker-compose -f apache/compose.yaml build; then
  build_success
else
  build_failed
fi
echo

# Build Mautic Image - PHP FPM
heading_msg "PHP FPM"
if docker-compose -f fpm/compose.yaml build; then
  build_success
else
  build_failed
fi
echo

# Log end of script
log_title "==== 🌠 Building finished 🎉 ===="
