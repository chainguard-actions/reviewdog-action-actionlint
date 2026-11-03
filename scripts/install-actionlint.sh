#!/bin/bash

set -euo pipefail
if [ -n "${RUNNER_DEBUG:-}" ] ; then
  set -x
fi

ACTIONLINT_VERSION=1.7.12

if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
  INSTALL_DIR=$(mktemp -d)
  echo "$INSTALL_DIR" >> "$GITHUB_PATH"
else
  INSTALL_DIR=/usr/local/bin/
fi

DOWNLOAD_SCRIPT="$(mktemp)"
trap 'rm -f "$DOWNLOAD_SCRIPT"' EXIT
curl -fsSL https://raw.githubusercontent.com/rhysd/actionlint/914e7df21a07ef503a81201c76d2b11c789d3fca/scripts/download-actionlint.bash -o "$DOWNLOAD_SCRIPT"
if [ ! -s "$DOWNLOAD_SCRIPT" ] || [ "$(head -c 2 "$DOWNLOAD_SCRIPT")" != "#!" ]; then
  echo "Downloaded actionlint install script is empty or invalid" >&2
  exit 1
fi

cd "$INSTALL_DIR"
bash "$DOWNLOAD_SCRIPT" "$ACTIONLINT_VERSION"
