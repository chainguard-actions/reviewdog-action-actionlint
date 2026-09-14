<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.74.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.74.0** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes remote content directly to bash via `curl -sSL https://raw.githubusercontent.com/rhysd/actionlint/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. This executes arbitrary remote code without first downloading and verifying the script.

Locations:

- `scripts/install-actionlint.sh:17`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes remote content directly to sh via `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. This executes arbitrary remote code without first downloading and verifying the script.

Locations:

- `scripts/install-reviewdog.sh:17`

### script-injection (severity: high)

Rule (b) violation: entrypoint.sh expands `${INPUT_ACTIONLINT_FLAGS}` unquoted in the shell command `actionlint -oneline ${INPUT_ACTIONLINT_FLAGS}`. This variable is sourced from `inputs.actionlint_flags` (set via env: in dockerless/action.yml) and is workflow-controllable. An attacker-supplied value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) would be interpreted by the shell, enabling command injection.

Locations:

- `entrypoint.sh:33`

### script-injection (severity: high)

Rule (b) violation: entrypoint.sh expands `${INPUT_REVIEWDOG_FLAGS}` unquoted at the end of the reviewdog invocation (`${INPUT_REVIEWDOG_FLAGS}` with no surrounding quotes). This variable is sourced from `inputs.reviewdog_flags` (set via env: in dockerless/action.yml) and is workflow-controllable. An attacker-supplied value containing shell metacharacters would be interpreted by the shell, enabling command injection.

Locations:

- `entrypoint.sh:50`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed 4 findings across 3 files:

1. scripts/install-actionlint.sh (unsafe-shell): Replaced `curl ... | bash -s -- "$ACTIONLINT_VERSION"` with downloading the script to a temp file via `curl ... -o "$INSTALL_SCRIPT"`, then executing `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"`. Dropped the `--` (it was the shell's option terminator in the pipe form, not the script's argument).

2. scripts/install-reviewdog.sh (unsafe-shell): Replaced `curl ... | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` with downloading to a temp file then executing `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. Dropped the `--` for the same reason.

3. entrypoint.sh (script-injection x2): Changed shebang from `#!/bin/sh` to `#!/bin/bash` (bash is installed in the Docker image via `apk add bash`). Tokenized `INPUT_ACTIONLINT_FLAGS` and `INPUT_REVIEWDOG_FLAGS` (both are flag-list inputs) using xargs into bash arrays with the guarded xargs/read-loop pattern, then expanded them as `"${actionlint_flags[@]}"` and `"${reviewdog_flags[@]}"` respectively. This prevents shell metacharacters in these inputs from being interpreted as shell commands.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in hardened/action/dockerless/action.yml at line 75. Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to properly quote the shell variable, preventing shell metacharacters in the ACTION_PATH value from being interpreted as shell commands.

