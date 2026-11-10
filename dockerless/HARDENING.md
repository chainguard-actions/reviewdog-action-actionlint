<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.84.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.84.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) failure, unquoted expansion of workflow-sourced data. The 'Run' step sets ACTION_PATH from ${{ github.action_path }} in its env: block, then runs `run: $ACTION_PATH/../entrypoint.sh` without quotes. The shell will split the path on whitespace and expand glob characters. Fix: change it to `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:85`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

In action.yml, the Run step now calls the script with quotes: run: '"$ACTION_PATH/../entrypoint.sh"'. Before, it was unquoted, so the path could be split on spaces or expanded as a glob. The step uses shell: bash, so the quoted form works. No other changes.

