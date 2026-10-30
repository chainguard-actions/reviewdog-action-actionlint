<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.81.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.81.1** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b), unquoted shell variable expansion. The 'Run' step sets ACTION_PATH from ${{ github.action_path }} through env:, then expands it without quotes: `run: $ACTION_PATH/../entrypoint.sh`. Because it is unquoted, the shell splits the value on whitespace and expands globs. Quote it: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:85`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

In action.yml, the 'Run' step ran $ACTION_PATH/../entrypoint.sh without quotes. It is now "$ACTION_PATH/../entrypoint.sh" in double quotes. The run: value is wrapped in single quotes so the YAML parser keeps the double quotes as part of the command. The step runs under shell: bash.

