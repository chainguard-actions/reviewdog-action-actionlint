<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.73.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.73.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh downloads a remote script and pipes it directly to bash without first saving it to a file: `curl -sSL https://raw.githubusercontent.com/rhysd/actionlint/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. This allows a compromised or man-in-the-middle remote server to execute arbitrary code on the runner.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh downloads a remote script and pipes it directly to sh without first saving it to a file: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. This allows a compromised or man-in-the-middle remote server to execute arbitrary code on the runner.

Locations:

- `scripts/install-reviewdog.sh:17`

### script-injection (severity: high)

Rule (b) violation: entrypoint.sh expands ${INPUT_ACTIONLINT_FLAGS} and ${INPUT_REVIEWDOG_FLAGS} without double-quoting. Both variables are set from inputs.actionlint_flags and inputs.reviewdog_flags respectively (workflow-controllable inputs) via the env: block in dockerless/action.yml. Unquoted expansion allows shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) embedded in the input values to be interpreted by the shell, enabling command injection. The guarded form `${VAR:+"$VAR"}` or quoted form `"$VAR"` should be used instead. Offending lines: `actionlint -oneline ${INPUT_ACTIONLINT_FLAGS}` (line 34) and `${INPUT_REVIEWDOG_FLAGS}` (line 49).

Locations:

- `entrypoint.sh:34`
- `entrypoint.sh:49`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed three security findings:
1. scripts/install-actionlint.sh (unsafe-shell): Replaced `curl ... | bash` with downloading the script to a mktemp file first (`curl -o $DOWNLOAD_SCRIPT`), then executing it with `bash "$DOWNLOAD_SCRIPT"`, and cleaning up afterward.
2. scripts/install-reviewdog.sh (unsafe-shell): Replaced `curl ... | sh` with downloading the script to a mktemp file first (`curl -o $INSTALL_SCRIPT`), then executing it with `sh "$INSTALL_SCRIPT"`, and cleaning up afterward.
3. entrypoint.sh (script-injection): Replaced unquoted `${INPUT_ACTIONLINT_FLAGS}` (line 34) and `${INPUT_REVIEWDOG_FLAGS}` (line 49) with the safe `${VAR:+"$VAR"}` form. This prevents shell metacharacter injection from workflow-controllable inputs while correctly omitting the argument entirely when the variable is empty (avoiding passing an empty string as an argument).

