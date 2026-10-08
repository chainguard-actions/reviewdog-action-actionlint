<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.80.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.80.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b) violation: In the 'Run' step, the env var `$ACTION_PATH` (set to `${{ github.action_path }}`) is expanded unquoted in the `run:` shell command: `run: $ACTION_PATH/../entrypoint.sh`. Any env var holding a `${{ ... }}` expression value must be double-quoted to prevent shell metacharacter interpretation. Fix: `run: "$ACTION_PATH/../entrypoint.sh"`

Locations:

- `action.yml:82`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted `$ACTION_PATH` variable in the `run:` command at line 82 of action.yml. Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to ensure the environment variable holding the `${{ github.action_path }}` value is double-quoted, preventing shell metacharacter interpretation.

