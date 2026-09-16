<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.75.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.75.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b): The 'Run' step sets ACTION_PATH from the workflow-controllable context value `${{ github.action_path }}` via the env: block, then uses the unquoted shell expansion `$ACTION_PATH` directly in the run: command (`run: $ACTION_PATH/../entrypoint.sh`). An unquoted variable expansion allows the shell to parse metacharacters (`;`, `|`, `&`, whitespace, etc.) from the value. The fix is to quote the expansion: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:86`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted shell expansion in action.yml line 86. Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"`. The double quotes prevent the shell from interpreting metacharacters (`;`, `|`, `&`, whitespace, etc.) that could be present in the ACTION_PATH value derived from `github.action_path`.

