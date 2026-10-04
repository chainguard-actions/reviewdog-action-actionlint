<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.79.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.79.1** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: The 'Run' step's `run:` block executes `$ACTION_PATH/../entrypoint.sh` with the shell variable `$ACTION_PATH` unquoted. `ACTION_PATH` is set in the `env:` block from `${{ github.action_path }}` (a `github.*` context value), making it workflow-controllable. An unquoted expansion allows the shell to parse metacharacters (`;`, `|`, `&`, whitespace, glob chars, etc.) from the value. The fix is to quote the expansion: `"$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:87`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted `$ACTION_PATH` variable in the 'Run' step's `run:` block in action.yml (line 87). Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to prevent shell metacharacter injection from the `github.action_path` context value.

