<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.81.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.81.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b) is violated: an env var holding untrusted data is expanded without quotes. In the 'Run' step, ACTION_PATH is set from ${{ github.action_path }} and then used bare: `run: $ACTION_PATH/../entrypoint.sh`. The shell splits that value on whitespace and expands glob characters in it. Fix: quote it, i.e. `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:85`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Quoted the ACTION_PATH expansion in the 'Run' step: run: "$ACTION_PATH/../entrypoint.sh" (shell: bash).

