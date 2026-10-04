<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.79.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.79.1** was hardened automatically. 2 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes remote content directly to bash without first downloading to a file: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. Even though the URL uses a pinned commit SHA, the content is executed immediately from the network without integrity verification.

Locations:

- `scripts/install-actionlint.sh:17`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes remote content directly to sh without first downloading to a file: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. Even though the URL uses a pinned commit SHA, the content is executed immediately from the network without integrity verification.

Locations:

- `scripts/install-reviewdog.sh:17`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell

**Notes:**

Fixed both unsafe-shell findings by replacing pipe-to-shell patterns with download-then-execute patterns:

1. scripts/install-actionlint.sh: Replaced `curl ... | bash -s -- "$ACTIONLINT_VERSION"` with downloading to a mktemp file, then running `bash "$DOWNLOAD_SCRIPT" "$ACTIONLINT_VERSION"`. Dropped `--` (it was the shell's option terminator, not a script argument).

2. scripts/install-reviewdog.sh: Replaced `curl ... | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` with downloading to a mktemp file, then running `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. Dropped both `-s` (stdin flag) and `--` (shell option terminator) since the script is now run from a file, not stdin.

Both scripts clean up the temp files after execution.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed two unsafe eval calls in entrypoint.sh (lines 39 and 54) that expanded user-controlled INPUT_ACTIONLINT_FLAGS and INPUT_REVIEWDOG_FLAGS without protection against shell metacharacter injection. Replaced both with safe xargs-based tokenization into bash arrays (actionlint_flags and reviewdog_flags). Changed shebang from #!/bin/sh to #!/bin/bash since bash is installed in the Docker image (via 'apk add bash' in the Dockerfile). Each tokenization block is guarded with 'if [ -n ... ]' to prevent xargs from emitting an empty token on empty input. Updated the tool invocations to use the named arrays instead of $@.

### Iteration 3

**Fixes applied:** script-injection

**Notes:**

Fixed hardened/action/dockerless/action.yml line 92: changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to prevent shell metacharacter injection from the unquoted `$ACTION_PATH` variable (sourced from `github.action_path` context).

