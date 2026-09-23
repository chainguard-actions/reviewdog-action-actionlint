<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.75.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.75.2** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b): In the 'Run' step, the env var `ACTION_PATH` is populated from `${{ github.action_path }}` and then used unquoted in the `run:` command: `run: $ACTION_PATH/../entrypoint.sh`. The shell variable `$ACTION_PATH` is not double-quoted, meaning any shell metacharacters in the value would be interpreted by the shell. Per the script-injection check, all env vars holding workflow-controllable context values must be double-quoted in shell expansions. The fix is: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:72`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted `$ACTION_PATH` variable in the 'Run' step's `run:` command in action.yml (line 72). Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to ensure the shell variable is double-quoted, preventing shell metacharacter interpretation.

