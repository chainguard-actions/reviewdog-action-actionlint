<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.80.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.80.3** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run' step, the env var $ACTION_PATH is set from `${{ github.action_path }}` (a github.* context value) and then used **unquoted** in the run command: `run: $ACTION_PATH/../entrypoint.sh`. If the action path contains shell metacharacters (spaces, semicolons, subshell syntax, etc.), the shell will parse them before executing the script path, enabling command injection. The fix is to quote the expansion: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:86`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed script-injection finding in hardened/action/action.yml at line 86: changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"`. The unquoted `$ACTION_PATH` variable (derived from `${{ github.action_path }}`) could allow shell metacharacters in the action path to be interpreted as shell commands. Quoting the expansion ensures the path is treated as a single shell word.

