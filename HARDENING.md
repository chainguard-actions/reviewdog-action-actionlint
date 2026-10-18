<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.80.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.80.4** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes remote content directly to bash without first downloading to a file: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. If the remote URL is compromised or the content is tampered with in transit, arbitrary code executes immediately on the runner.

Locations:

- `scripts/install-actionlint.sh:17`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes remote content directly to sh without first downloading to a file: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. If the remote URL is compromised or the content is tampered with in transit, arbitrary code executes immediately on the runner.

Locations:

- `scripts/install-reviewdog.sh:17`

### script-injection (severity: high)

Sub-rule (b): In the 'Run' step of dockerless/action.yml, the run: block executes `$ACTION_PATH/../entrypoint.sh` with `$ACTION_PATH` unquoted. The env var ACTION_PATH is set from `${{ github.action_path }}`, a workflow-controllable context value. An unquoted shell expansion allows shell metacharacters in the value to be interpreted by the shell. The variable must be double-quoted: `"$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `dockerless/action.yml:75`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed three security findings:
1. scripts/install-actionlint.sh (unsafe-shell): Replaced `curl ... | bash -s -- "$ACTIONLINT_VERSION"` with downloading the script to a mktemp file first, then running `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"`. Dropped `-s` and `--` as they were shell stdin-reading and option-termination flags, not arguments to the downloaded script.
2. scripts/install-reviewdog.sh (unsafe-shell): Replaced `curl ... | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` with downloading to a mktemp file first, then running `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. Dropped `-s` and `--` for the same reason.
3. dockerless/action.yml (script-injection): Quoted the unquoted `$ACTION_PATH/../entrypoint.sh` run command as `"$ACTION_PATH/../entrypoint.sh"` to prevent shell metacharacter interpretation of the github.action_path-derived value.

