<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.76.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.76.0** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b): The 'Run' step sets ACTION_PATH from the GitHub Actions expression `${{ github.action_path }}` via the env block, then uses the env var unquoted in the run command: `run: $ACTION_PATH/../entrypoint.sh`. An unquoted shell variable expansion allows shell metacharacters embedded in the value to be interpreted by the shell. The variable should be double-quoted: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:75`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed unquoted shell variable expansion in action.yml line 75: changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"`. The ACTION_PATH env var is set from `${{ github.action_path }}` and must be double-quoted when used in the run command to prevent shell metacharacter interpretation.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script-injection in action.yml line 80: Changed `run: "$ACTION_PATH/../entrypoint.sh"` (YAML double-quoted string, no shell quoting) to a block scalar `run: |` with explicit shell double-quoting `"$ACTION_PATH/../entrypoint.sh"`. This ensures the shell receives the variable expansion properly quoted, preventing shell metacharacter interpretation.

