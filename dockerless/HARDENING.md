<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.75.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.75.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run' step, the env var ACTION_PATH is set from `${{ github.action_path }}` (a github.* context value) and then used unquoted in the run: command as `run: $ACTION_PATH/../entrypoint.sh`. An unquoted shell variable expansion of a workflow-controllable value allows shell metacharacter injection. The fix is to quote the variable: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:82`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted shell variable expansion in action.yml line 82. Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to prevent shell metacharacter injection from the workflow-controllable ACTION_PATH environment variable (set from `${{ github.action_path }}`).

