#!/bin/bash

set -euo pipefail
if [ -n "${RUNNER_DEBUG:-}" ] ; then
  set -x
fi

REVIEWDOG_VERSION=0.21.2

if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
  INSTALL_DIR=$(mktemp -d)
  echo "$INSTALL_DIR" >> "$GITHUB_PATH"
else
  INSTALL_DIR=/usr/local/bin/
fi

INSTALL_SCRIPT="$(mktemp)"
trap 'rm -f "$INSTALL_SCRIPT"' EXIT
# Script is pinned to an immutable commit SHA.
curl -sSfL -o "$INSTALL_SCRIPT" https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74df59de7ebfd9276afabd62ea2de4d7dd/install.sh
if [ ! -s "$INSTALL_SCRIPT" ]; then
  echo "failed to download reviewdog installer" >&2
  exit 1
fi
sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"
