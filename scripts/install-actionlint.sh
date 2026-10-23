#!/bin/bash

set -euo pipefail
if [ -n "${RUNNER_DEBUG:-}" ] ; then
  set -x
fi

ACTIONLINT_VERSION=1.17.0

if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
  INSTALL_DIR=$(mktemp -d)
  echo "$INSTALL_DIR" >> "$GITHUB_PATH"
else
  INSTALL_DIR=/usr/local/bin/
fi

cd "$INSTALL_DIR"
DOWNLOAD_SCRIPT="$(mktemp)"
trap 'rm -f "$DOWNLOAD_SCRIPT"' EXIT
# Script is pinned to an immutable commit SHA.
curl -sSfL -o "$DOWNLOAD_SCRIPT" https://raw.githubusercontent.com/kjanat/actionlint/08bb2c4f0d039744455b87aef1c647fb8b66d37b/scripts/download-actionlint.bash
if [ ! -s "$DOWNLOAD_SCRIPT" ]; then
  echo "failed to download actionlint installer" >&2
  exit 1
fi
bash "$DOWNLOAD_SCRIPT" "$ACTIONLINT_VERSION"
