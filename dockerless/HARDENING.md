<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.80.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.80.6** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b), unquoted shell variable expansion. The 'Run' step sets ACTION_PATH from ${{ github.action_path }} in its env: block, then expands it without quotes: `run: $ACTION_PATH/../entrypoint.sh`. Without quotes, the shell splits the value on spaces and expands glob characters before running it. Fix: quote it as `"$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:85`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Quoted $ACTION_PATH in the Run step (shell: bash): run: '"$ACTION_PATH/../entrypoint.sh"' so the path is not word-split or globbed.

