<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.81.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.81.2** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b), unquoted shell variable expansion: the composite 'Run' step sets ACTION_PATH from ${{ github.action_path }} and then expands it without quotes in `run: $ACTION_PATH/../entrypoint.sh`. Without quotes, the shell splits the value on whitespace and expands glob characters. Fix: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:85`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Quoted the $ACTION_PATH expansion in the 'Run' step: run: '"$ACTION_PATH/../entrypoint.sh"'. bash stays the shell, and the path value is still set through env, so the step behaves the same.

