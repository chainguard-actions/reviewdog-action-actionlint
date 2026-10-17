<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.80.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.80.3** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes curl output directly to bash without first downloading to a file: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. This allows a compromised or man-in-the-middle remote script to execute arbitrary code on the runner.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes curl output directly to sh without first downloading to a file: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. This allows a compromised or man-in-the-middle remote script to execute arbitrary code on the runner.

Locations:

- `scripts/install-reviewdog.sh:18`

### script-injection (severity: high)

Sub-rule (b): In the 'Run' step of dockerless/action.yml, the run: block executes `$ACTION_PATH/../entrypoint.sh` where `$ACTION_PATH` is an unquoted shell variable expansion. `ACTION_PATH` is set in the env: block to `${{ github.action_path }}` (a github.* context value). Unquoted expansion of a workflow-controllable env var inside a run: block allows shell metacharacter injection. The variable should be double-quoted: `"$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `dockerless/action.yml:73`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed three findings: (1) scripts/install-actionlint.sh: replaced `curl ... | bash -s -- "$ACTIONLINT_VERSION"` with downloading to a temp file via `-o "$INSTALL_SCRIPT"` then executing `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"` — dropped the `--` since it was the shell's own option terminator for `-s`, not an argument to the downloaded script; (2) scripts/install-reviewdog.sh: replaced `curl ... | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` with downloading to a temp file then executing `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` — dropped the `--` for the same reason; (3) dockerless/action.yml line 73: quoted the unquoted `$ACTION_PATH/../entrypoint.sh` to `"$ACTION_PATH/../entrypoint.sh"` to prevent shell metacharacter injection from the github.action_path-derived env var.

