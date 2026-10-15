<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.80.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.80.2** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b) violation: The 'Run' step uses an unquoted shell variable expansion `$ACTION_PATH` in the `run:` command (`run: $ACTION_PATH/../entrypoint.sh`). The variable `ACTION_PATH` is sourced from `${{ github.action_path }}` in the `env:` block — a workflow-controllable context value. Without double-quoting, any shell metacharacters (spaces, semicolons, etc.) in the value would be interpreted by the shell, enabling command injection. The fix is to quote the expansion: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:90`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed unquoted shell variable expansion in action.yml line 90. Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to prevent shell metacharacter interpretation of the ACTION_PATH variable, which is sourced from the workflow-controllable `github.action_path` context value.

