<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.73.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.73.3** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b) violation: The `run:` line `run: $ACTION_PATH/../entrypoint.sh` expands the env var `$ACTION_PATH` without double-quoting it. `ACTION_PATH` is set from `${{ github.action_path }}`, a `github.*` context value. An unquoted shell expansion allows the shell to parse metacharacters (`;`, `|`, `&`, whitespace, glob chars, etc.) out of the value before executing it. The fix is to quote the expansion: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:79`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed unquoted shell expansion in action.yml line 79. Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to prevent shell metacharacter interpretation of the ACTION_PATH variable, which is derived from `github.action_path`.

