<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.81.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.81.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b): an environment variable is expanded without quotes. In the 'Run' step, ACTION_PATH is set from ${{ github.action_path }} and then used unquoted: `run: $ACTION_PATH/../entrypoint.sh`. Without quotes, the shell splits the value on spaces and expands glob characters. Quote it: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:85`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

In action.yml 'Run' step (shell: bash), changed `run: $ACTION_PATH/../entrypoint.sh` to `run: '"$ACTION_PATH/../entrypoint.sh"'` so the path is double-quoted in the shell, preventing word splitting/globbing.

