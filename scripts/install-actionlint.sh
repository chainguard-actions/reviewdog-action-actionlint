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

cd "$INSTALL_DIR"
INSTALL_SCRIPT=$(mktemp)
curl -sSL https://raw.githubusercontent.com/rhysd/actionlint/914e7df21a07ef503a81201c76d2b11c789d3fca/scripts/download-actionlint.bash -o "$INSTALL_SCRIPT"
bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"
rm -f "$INSTALL_SCRIPT"
