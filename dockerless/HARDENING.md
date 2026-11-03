<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.73.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.73.2** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b), unquoted shell variable expansion. The 'Run' step sets ACTION_PATH from ${{ github.action_path }} in its env: block, then expands it without double quotes: `run: $ACTION_PATH/../entrypoint.sh`. The shell therefore applies word-splitting and glob expansion to the value. Fix: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:86`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Quoted $ACTION_PATH in the Run step of action.yml. It now reads run: '"$ACTION_PATH/../entrypoint.sh"' (YAML single quotes around the shell double quotes). The step uses shell: bash, so the $VAR syntax is correct.

