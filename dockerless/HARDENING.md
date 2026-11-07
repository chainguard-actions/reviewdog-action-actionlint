<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.80.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.80.2** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b), unquoted shell expansion: in the 'Run' step, the env var ACTION_PATH is set from ${{ github.action_path }}, a github.* context value. It is expanded without double quotes in `run: $ACTION_PATH/../entrypoint.sh`. Without quotes, the shell will split the value on whitespace and expand glob characters. Quote it: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:87`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Quoted $ACTION_PATH in the Run step of action.yml: run: '"$ACTION_PATH/../entrypoint.sh"' (bash shell).

