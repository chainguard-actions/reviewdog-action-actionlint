<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.74.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.74.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run' step, the env var `$ACTION_PATH` (set from `${{ github.action_path }}`) is used unquoted in the `run:` command: `run: $ACTION_PATH/../entrypoint.sh`. Even though `github.action_path` is GitHub-controlled rather than directly attacker-supplied, any `${{ ... }}` value routed through an env var must be double-quoted when expanded in a shell command to prevent shell metacharacter interpretation. The correct form is: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:83`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted `$ACTION_PATH` variable expansion in the 'Run' step of action.yml. Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to ensure the variable is properly double-quoted, preventing potential shell metacharacter interpretation.

