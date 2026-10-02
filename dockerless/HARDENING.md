<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.78.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.78.1** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b) violation: In the 'Run' step, the env var ACTION_PATH (set from `${{ github.action_path }}`, a github.* context value) is used unquoted in the run: command: `run: $ACTION_PATH/../entrypoint.sh`. An unquoted shell variable expansion allows shell metacharacters in the value to be interpreted by the shell. The value should be quoted: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:79`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted variable expansion in the 'Run' step's run command. Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` in hardened/action/action.yml at line 79. This prevents shell metacharacters in the ACTION_PATH value (derived from github.action_path) from being interpreted by the shell.

