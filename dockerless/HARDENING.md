<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.80.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.80.5** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b), unquoted shell variable expansion: the 'Run' step uses `run: $ACTION_PATH/../entrypoint.sh`. ACTION_PATH is set from ${{ github.action_path }} through env: but is expanded without double quotes, so the shell will split it on whitespace and expand glob characters. It should be quoted: `"$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:85`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Quoted $ACTION_PATH in the 'Run' step: run: '"$ACTION_PATH/../entrypoint.sh"' (bash shell), so the path no longer word-splits or globs.

