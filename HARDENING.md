<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.74.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.74.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes remote content fetched via curl directly to bash without first saving to a file: `curl -sSL https://raw.githubusercontent.com/rhysd/actionlint/914e7df21a07ef503a81201c76d2b11c789d3fca/scripts/download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. This allows a compromised or man-in-the-middle remote server to execute arbitrary code on the runner.

Locations:

- `scripts/install-actionlint.sh:17`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes remote content fetched via curl directly to sh without first saving to a file: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74df59de7ebfd9276afabd62ea2de4d7dd/install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. This allows a compromised or man-in-the-middle remote server to execute arbitrary code on the runner.

Locations:

- `scripts/install-reviewdog.sh:17`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell

**Notes:**

Fixed both unsafe-shell findings by replacing curl-pipe-to-shell patterns with download-then-execute patterns:

1. scripts/install-actionlint.sh: Changed `curl ... | bash -s -- "$ACTIONLINT_VERSION"` to download the script to a mktemp file, then run `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"`. Dropped '--' (was the shell's option terminator for -s, not a script argument).

2. scripts/install-reviewdog.sh: Changed `curl ... | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` to download the script to a mktemp file, then run `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. Dropped '--' (same reason). Both temp files are cleaned up with `rm -f` after execution.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed all three script-injection findings:

1. entrypoint.sh line 32 (INPUT_ACTIONLINT_FLAGS): Replaced unquoted `${INPUT_ACTIONLINT_FLAGS}` with a bash array tokenized via xargs (quote-aware, NUL-delimited). Guarded with `[ -n ... ]` to avoid empty-arg issues. Expanded as `"${actionlint_args[@]}"`.

2. entrypoint.sh line 50 (INPUT_REVIEWDOG_FLAGS): Replaced unquoted `${INPUT_REVIEWDOG_FLAGS}` with a bash array tokenized via xargs. Built before the pipe so reviewdog's stdin remains available from the pipe chain. Expanded as `"${reviewdog_args[@]}"`.

3. dockerless/action.yml line 82 ($ACTION_PATH): Quoted the run command as `"$ACTION_PATH/../entrypoint.sh"` to prevent word splitting.

Changed shebang from `#!/bin/sh` to `#!/bin/bash` to enable bash arrays and process substitution required for the safe tokenization pattern. Removed the `# shellcheck disable=SC2086` comment that acknowledged the previous unsafe expansion.

