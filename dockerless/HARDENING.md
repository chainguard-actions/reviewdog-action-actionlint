<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.77.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.77.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b) violation: In the 'Run' step, the env var `$ACTION_PATH` (sourced from `${{ github.action_path }}`) is used unquoted in the `run:` shell command: `run: $ACTION_PATH/../entrypoint.sh`. Any shell expansion of an env var holding a `${{ }}` value must be double-quoted to prevent shell metacharacter interpretation. Fix: change to `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:85`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted `$ACTION_PATH` variable in the 'Run' step's `run:` command in action.yml (line 85). Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to ensure the environment variable is double-quoted, preventing shell metacharacter interpretation.

