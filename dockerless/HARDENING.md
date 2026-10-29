<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.81.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.81.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b): the 'Run' step expands an env var holding workflow context data without quotes. ACTION_PATH is set from ${{ github.action_path }} and is then used as `run: $ACTION_PATH/../entrypoint.sh`. Because it is unquoted, the shell splits the path on spaces and expands glob characters in it. Fix: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:85`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the one script-injection finding in `action.yml`. The "Run" step called `$ACTION_PATH/../entrypoint.sh` without quotes. `ACTION_PATH` is set from `${{ github.action_path }}`, so the shell would split that path on spaces and expand any glob characters in it. The step now runs `"$ACTION_PATH/../entrypoint.sh"`, written as a block scalar so the quotes stay part of the shell command instead of being read as YAML quoting. This is the only change. The step uses bash, so the `$VAR` syntax is correct.

