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
INSTALL_SCRIPT=$(mktemp)
curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/08bb2c4f0d039744455b87aef1c647fb8b66d37b/scripts/download-actionlint.bash -o "$INSTALL_SCRIPT"
bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"
rm -f "$INSTALL_SCRIPT"
