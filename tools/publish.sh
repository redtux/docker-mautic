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
# ./publish.sh -- Publish images

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

if [ -z "${MAUTIC_VERSION:-}" ]; then
  latest_api_url="https://api.github.com/repos/mautic/mautic/releases/latest"
  MAUTIC_VERSION=$(curl -Ls "$latest_api_url" | jq -r '.name | sub("Mautic Community "; "")')
fi

# Log start of script
clear
log_title "==== 🎬 Starting publish script 🚀 ===="
echo

# Check for registry login
if command -v podman >/dev/null; then
  registry_auth_file="/run/user/$(id -u)/containers/auth.json"
else
  registry_auth_file="$HOME/.docker/config.json"
fi

# Login to GitHub registry
registry_title "GitHub"
if grep -l -q -E 'ghcr.io' "$registry_auth_file"; then
  docker login ghcr.io
else
  if [ -n "${GITHUB_USER:-}" ] && [ -n "${GITHUB_TOKEN:-}" ]; then
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_USER" --password-stdin
  else
    title "W: GITHUB_TOKEN and GITHUB_USER need to be set."
    title "W: Skipping login to GitHub registry..."
  fi
fi

# Login to Docker Hub registry
registry_title "Docker Hub"
if grep -l -q -E 'docker.io' "$registry_auth_file"; then
  docker login
else
  if [ -n "${DOCKERHUB_USER:-}" ] && [ -n "${DOCKERHUB_TOKEN:-}" ]; then
    echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USER" --password-stdin
  else
    title "W: DOCKERHUB_TOKEN and DOCKERHUB_USER need to be set."
    title "W: Skipping login to Docker Hub registry..."
  fi
fi

# Define image variables
image_flavor=apache
imageid_local="localhost/${image_flavor}_mautic:latest"

# Define function for image pushing
push_images() {
  local registry_name="$1"
  local registry_user_var="$2"
  local registry_token_var="$3"
  local registry="$4"

  # Check if the required variables are set
  if [ -n "${!registry_user_var:-}" ] && [ -n "${!registry_token_var:-}" ]; then
    title "Pushing images to $registry_name registry"

    for tag in "${MAUTIC_VERSION}" "latest" "${MAUTIC_VERSION}-${image_flavor}" "${image_flavor}"; do
      imageid_target="$registry/${!registry_user_var}/mautic:${tag}"
      title "Image tag: ${imageid_target}"
      docker tag "$imageid_local" "${imageid_target}"
      docker push "${imageid_target}"
    done
  else
    title "$registry_user_var not defined. Skipping upload to $registry_name registry."
  fi
}

# Publish Mautic Image - Apache HTTP
publish_title "Apache HTTP to GitHub"
push_images "GitHub" "GITHUB_USER" "GITHUB_TOKEN" "ghcr.io"
publish_title "Apache HTTP to Docker Hub"
push_images "Docker Hub" "DOCKERHUB_USER" "DOCKERHUB_TOKEN" "docker.io"

# Publish Mautic Image - PHP FPM
image_flavor=fpm
publish_title "PHP FPM to GitHub"
push_images "GitHub" "GITHUB_USER" "GITHUB_TOKEN" "ghcr.io"
publish_title "PHP FPM to Docker Hub"
push_images "Docker Hub" "DOCKERHUB_USER" "DOCKERHUB_TOKEN" "docker.io"

# Log end of script
log_title "==== 🌠 Uploading finished 🎉 ===="
