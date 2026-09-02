<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.73.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.73.3** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b) violation: In the 'Run' step, the env var ACTION_PATH (set from ${{ github.action_path }}, a workflow-controllable value) is used unquoted in the run command: `run: $ACTION_PATH/../entrypoint.sh`. An unquoted shell variable expansion allows the shell to parse metacharacters out of the value. It should be quoted: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:75`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted $ACTION_PATH variable in the 'Run' step's run command. Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to prevent shell metacharacter interpretation from the ACTION_PATH environment variable (which is set from ${{ github.action_path }}, a workflow-controllable value).

