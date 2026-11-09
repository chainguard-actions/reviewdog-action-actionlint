<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.75.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.75.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation, unquoted shell variable expansion: the 'Run' step's run line is `run: $ACTION_PATH/../entrypoint.sh`. ACTION_PATH is set from github.action_path (a github.* context), and the expansion is not double-quoted, so the shell will word-split and glob-expand it. Quote it: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:85`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

In action.yml, the Run step now uses `run: '"$ACTION_PATH/../entrypoint.sh"'`. The outer single quotes are YAML quoting, so bash receives the path double-quoted. That stops word-splitting and glob expansion. Nothing else changed.

