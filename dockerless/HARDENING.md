<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.73.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.73.1** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) is broken: a shell variable holding untrusted data is expanded without quotes. In the 'Run' step, `run: $ACTION_PATH/../entrypoint.sh` uses ACTION_PATH without double quotes. ACTION_PATH is set from ${{ github.action_path }}, a github.* context value. Without quotes, the shell splits the path on whitespace and expands glob characters before running it. Fix: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:85`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Quoted $ACTION_PATH in the 'Run' step of action.yml (bash shell): run: "$ACTION_PATH/../entrypoint.sh".

