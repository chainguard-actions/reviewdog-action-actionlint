#!/bin/bash

set -euo pipefail
if [ -n "${RUNNER_DEBUG:-}" ] ; then
  set -x
fi

REVIEWDOG_VERSION=0.21.0

if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
  INSTALL_DIR=$(mktemp -d)
  echo "$INSTALL_DIR" >> "$GITHUB_PATH"
else
  INSTALL_DIR=/usr/local/bin/
fi

INSTALL_SCRIPT=$(mktemp)
curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74df59de7ebfd9276afabd62ea2de4d7dd/install.sh -o "$INSTALL_SCRIPT"
sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"
rm -f "$INSTALL_SCRIPT"
