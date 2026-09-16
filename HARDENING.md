<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.75.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.75.0** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes remote content directly to bash without first saving to a file: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. If the remote URL is compromised or the content is tampered with in transit, arbitrary code executes immediately on the runner.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes remote content directly to sh without first saving to a file: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. If the remote URL is compromised or the content is tampered with in transit, arbitrary code executes immediately on the runner.

Locations:

- `scripts/install-reviewdog.sh:17`

### script-injection (severity: high)

Rule (b): In entrypoint.sh, the env var ${INPUT_ACTIONLINT_FLAGS} (sourced from inputs.actionlint_flags in dockerless/action.yml) is expanded unquoted in the shell command: `actionlint -oneline ${INPUT_ACTIONLINT_FLAGS} | while read -r r; do`. An attacker-controlled input value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) can break out of the intended command and inject arbitrary shell commands.

Locations:

- `entrypoint.sh:32`

### script-injection (severity: high)

Rule (b): In entrypoint.sh, the env var ${INPUT_REVIEWDOG_FLAGS} (sourced from inputs.reviewdog_flags in dockerless/action.yml) is expanded unquoted in the shell command: `${INPUT_REVIEWDOG_FLAGS}` as the last argument to the reviewdog invocation. An attacker-controlled input value containing shell metacharacters can inject additional flags or arbitrary shell commands.

Locations:

- `entrypoint.sh:50`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed 4 findings across 3 files:

1. scripts/install-actionlint.sh (unsafe-shell): Replaced `curl ... | bash -s -- "$ACTIONLINT_VERSION"` with downloading the script to a temp file via `curl ... -o "$INSTALL_SCRIPT"`, then executing `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"`. Dropped the `--` as it was the shell's option terminator for the pipe form, not an argument to the downloaded script.

2. scripts/install-reviewdog.sh (unsafe-shell): Replaced `curl ... | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` with downloading to a temp file, then executing `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. Dropped the `--` for the same reason.

3. entrypoint.sh (script-injection, INPUT_ACTIONLINT_FLAGS and INPUT_REVIEWDOG_FLAGS): Changed shebang from `#!/bin/sh` to `#!/bin/bash` (bash is installed in the Docker image via `apk add bash`). Replaced unquoted `${INPUT_ACTIONLINT_FLAGS}` and `${INPUT_REVIEWDOG_FLAGS}` expansions with xargs-based tokenization into bash arrays, using the guarded `if [ -n "$VAR" ]` pattern and `while IFS= read -r -d '' t` loop to safely handle list-style flag inputs without shell injection risk.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted variable expansion in hardened/action/dockerless/action.yml. Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to ensure the shell variable is double-quoted, preventing shell metacharacters in the ACTION_PATH value from being interpreted by the shell.

