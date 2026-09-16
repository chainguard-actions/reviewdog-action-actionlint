<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.75.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.75.0** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes remote content directly to bash: `curl -sSL https://raw.githubusercontent.com/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. Even though the URL is pinned to a commit SHA, piping remote content directly to a shell interpreter is an unsafe pattern — the script should be downloaded to a file first, verified, and then executed separately.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes remote content directly to sh: `curl -sSL https://raw.githubusercontent.com/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. Even though the URL is pinned to a commit SHA, piping remote content directly to a shell interpreter is an unsafe pattern — the script should be downloaded to a file first, verified, and then executed separately.

Locations:

- `scripts/install-reviewdog.sh:17`

### script-injection (severity: high)

Rule (b) violation: entrypoint.sh expands `${INPUT_ACTIONLINT_FLAGS}` unquoted on line 33 (`actionlint -oneline ${INPUT_ACTIONLINT_FLAGS}`). This env var is sourced from `inputs.actionlint_flags` (set in dockerless/action.yml via `INPUT_ACTIONLINT_FLAGS: ${{ inputs.actionlint_flags }}`), making it workflow-controllable. An unquoted expansion allows shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) in the input value to be interpreted by the shell, enabling command injection. The `# shellcheck disable=SC2086` comment confirms the unquoted expansion is intentional but does not mitigate the injection risk.

Locations:

- `entrypoint.sh:33`
- `dockerless/action.yml:82`

### script-injection (severity: high)

Rule (b) violation: entrypoint.sh expands `${INPUT_REVIEWDOG_FLAGS}` unquoted on the last argument of the reviewdog invocation (`${INPUT_REVIEWDOG_FLAGS}` without quotes). This env var is sourced from `inputs.reviewdog_flags` (set in dockerless/action.yml via `INPUT_REVIEWDOG_FLAGS: ${{ inputs.reviewdog_flags }}`), making it workflow-controllable. An unquoted expansion allows shell metacharacters in the input value to be interpreted by the shell, enabling command injection.

Locations:

- `entrypoint.sh:47`
- `dockerless/action.yml:81`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed 4 findings across 3 files:

1. scripts/install-actionlint.sh (unsafe-shell): Replaced `curl ... | bash -s -- "$ACTIONLINT_VERSION"` with downloading to a temp file via `-o`, then executing `bash "$DOWNLOAD_SCRIPT" "$ACTIONLINT_VERSION"`. Dropped the `--` (it was the shell's stdin-mode option terminator, not the script's argument).

2. scripts/install-reviewdog.sh (unsafe-shell): Replaced `curl ... | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` with downloading to a temp file via `-o`, then executing `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. Dropped the `--` (it was the shell's -s option terminator, not the script's argument).

3. entrypoint.sh (script-injection, INPUT_ACTIONLINT_FLAGS): Replaced unquoted `${INPUT_ACTIONLINT_FLAGS}` expansion with POSIX-compatible safe tokenization using `xargs -n1` and `set --` to build positional parameters, then passed as `"$@"` to actionlint.

4. entrypoint.sh (script-injection, INPUT_REVIEWDOG_FLAGS): Replaced unquoted `${INPUT_REVIEWDOG_FLAGS}` expansion with the same POSIX-compatible safe tokenization pattern inside a subshell group piped from the while loop, then passed as `"$@"` to reviewdog.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted $ACTION_PATH variable in dockerless/action.yml. Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` so the shell variable is properly double-quoted, preventing potential shell metacharacter interpretation.

