#!/usr/bin/env bash
# vim: set ai expandtab sw=2 ts=2 sts=2 re=2:
#
# SPDX-FileCopyrightText: 2015 Michael Babker <michael.babker@mautic.org>
# SPDX-FileCopyrightText: 2023 Pablo Hörtner <redtux@pm.me>
# SPDX-License-Identifier: GPL-3.0-or-later
# You can find the GPL v3.0 here:  https://www.gnu.org/licenses/gpl-3.0
#
# ./update.sh -- Update image sources

# Enable strict mode
IFS=$'\n\t'
set -euo pipefail

# Set working directory to parent directory of the script
WORKDIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.."
cd "$WORKDIR"

if [ -z "$MAUTIC_VERSION" ]; then
  latest_api_url="https://api.github.com/repos/mautic/mautic/releases/latest"
  current=$(curl -Ls "$latest_api_url" | jq -r '.name | sub("Mautic Community "; "")')
else
  current="$MAUTIC_VERSION"
fi

# TODO - Expose SHA signatures for the packages somewhere
wget -O mautic.zip https://github.com/mautic/mautic/releases/download/$current/$current.zip
sha1="$(sha1sum mautic.zip | sed -r 's/ .*//')"

for variant in apache fpm; do
  (
    set -x
  
    sed -ri '
      s/^(ENV MAUTIC_VERSION) .*/\1 '"$current"'/;
      s/^(ENV MAUTIC_SHA1) .*/\1 '"$sha1"'/;
    ' "$variant/Dockerfile"
  
        # To make management easier, we use these files for all variants
    cp common/* "$variant"/
  )
done

rm mautic.zip
