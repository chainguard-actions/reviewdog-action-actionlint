<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.75.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.75.3** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: The 'Run' step sets ACTION_PATH from the workflow-controllable expression `${{ github.action_path }}` in its env: block, then uses the unquoted shell variable `$ACTION_PATH` directly in the run: command (`run: $ACTION_PATH/../entrypoint.sh`). The variable must be double-quoted to prevent shell metacharacter interpretation: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:79`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed unquoted shell variable in run: command at action.yml line 79. Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to prevent shell metacharacter interpretation of the ACTION_PATH variable, which is set from the workflow-controllable expression `${{ github.action_path }}`.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed the script-injection finding in hardened/action/action.yml at line 87. Changed `run: "$ACTION_PATH/../entrypoint.sh"` (YAML double-quoted string, shell sees unquoted expansion) to a multi-line run block using YAML literal block scalar (`|`) with `"$ACTION_PATH/../entrypoint.sh"` properly shell-double-quoted. This ensures the github.action_path-derived env var $ACTION_PATH is always double-quoted in the shell command.

