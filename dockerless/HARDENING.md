<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.83.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.83.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b): an environment variable that holds workflow-controlled data is expanded without double quotes. The 'Run' step sets ACTION_PATH from the github.action_path context and runs it unquoted: `run: $ACTION_PATH/../entrypoint.sh`. Because it is unquoted, the shell applies word splitting and glob expansion to the value. Fix: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:85`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

In the 'Run' step of action.yml, put double quotes around the entrypoint invocation: "$ACTION_PATH/../entrypoint.sh". The step uses shell: bash, so the quoted form works.

