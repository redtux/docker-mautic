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
# ./build.sh -- Build images

# Enable strict mode
IFS=$'\n\t'
set -euo pipefail

# Include common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Set working directory to parent directory of the script
WORKDIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.."
cd "$WORKDIR"

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

# Build Mautic Image - Apache HTTP
build_title "Apache HTTP"
if docker-compose -f apache/compose.yaml build; then
  build_success
else
  build_failed
fi
echo

# Build Mautic Image - PHP FPM
build_title "PHP FPM"
if docker-compose -f fpm/compose.yaml build; then
  build_success
else
  build_failed
fi
echo

# Log end of script
log_title "==== 🌠 Building finished 🎉 ===="
