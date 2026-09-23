<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.76.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.76.1** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: The 'Run' step uses the unquoted shell variable `$ACTION_PATH` in the `run:` command (`run: $ACTION_PATH/../entrypoint.sh`). `ACTION_PATH` is set from `${{ github.action_path }}`, a workflow-controllable context value. If this value contains shell metacharacters (spaces, semicolons, etc.), the shell will parse them before execution. The variable must be double-quoted: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:81`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted $ACTION_PATH variable in the 'Run' step's run command in action.yml (line 81). Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to prevent shell metacharacter interpretation when ACTION_PATH contains special characters.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted variable expansion in the 'Run' step of action.yml. Changed `run: "$ACTION_PATH/../entrypoint.sh"` (YAML-quoted only, shell sees unquoted variable) to a multi-line `run: |` block with `"$ACTION_PATH/../entrypoint.sh"` so the shell receives actual double-quotes around the variable expansion, preventing word-splitting and glob expansion.

