<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.76.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.76.3** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b) violation: The 'Run' step executes `run: $ACTION_PATH/../entrypoint.sh` where `$ACTION_PATH` is an unquoted shell variable holding the value of `${{ github.action_path }}` (set in the env: block). An unquoted variable expansion allows the shell to perform word-splitting and glob expansion on the value before executing it, which can lead to command injection if the path contains shell metacharacters. The fix is to quote the variable: `run: "$ACTION_PATH/../entrypoint.sh"`

Locations:

- `action.yml:86`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted variable expansion in action.yml line 86. Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to prevent word-splitting and glob expansion on the ACTION_PATH variable, which holds the value of `${{ github.action_path }}`.

