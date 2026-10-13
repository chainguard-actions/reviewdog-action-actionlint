<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.80.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.80.1** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b) violation: In the 'Run' step, the env var `ACTION_PATH` is set from `${{ github.action_path }}` (a github.* context value) and then expanded unquoted in the run command: `run: $ACTION_PATH/../entrypoint.sh`. The shell variable must be double-quoted to prevent shell metacharacter interpretation. It should be: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:76`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted shell variable expansion in action.yml line 76. Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to properly double-quote the `$ACTION_PATH` variable (which is set from `${{ github.action_path }}`) and prevent shell metacharacter interpretation.

