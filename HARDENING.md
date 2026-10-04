<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.79.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.79.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

Remote content is piped directly to a shell interpreter without first downloading to a file. In scripts/install-actionlint.sh, a script is fetched from raw.githubusercontent.com and piped to `bash`. In scripts/install-reviewdog.sh, a script is fetched from raw.githubusercontent.com and piped to `sh`. If the remote URL is compromised or the network is intercepted, arbitrary code executes immediately with no opportunity for inspection.

Locations:

- `scripts/install-actionlint.sh:18`
- `scripts/install-reviewdog.sh:17`

### script-injection (severity: high)

Sub-rule (b): Unquoted shell variable expansion of workflow-controlled data. (1) In entrypoint.sh, `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` expands the env var INPUT_ACTIONLINT_FLAGS (sourced from `inputs.actionlint_flags` via the env: block in dockerless/action.yml) without quoting, allowing an attacker-supplied value containing shell metacharacters (`;`, `|`, `$(...)`, etc.) to inject arbitrary shell commands. The same issue exists for `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"` (sourced from `inputs.reviewdog_flags`). (2) In dockerless/action.yml, the run: step executes `$ACTION_PATH/../entrypoint.sh` with the variable unquoted; ACTION_PATH is set from `${{ github.action_path }}` and should be double-quoted to prevent word-splitting and glob expansion.

Locations:

- `entrypoint.sh:37`
- `entrypoint.sh:50`
- `dockerless/action.yml:88`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed all four locations across three files:

1. scripts/install-actionlint.sh: Download script to temp file first, then execute with `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"` (dropped `--` which was the shell's option terminator in the piped form, not an argument to the downloaded script).

2. scripts/install-reviewdog.sh: Download script to temp file first, then execute with `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` (dropped `--` for the same reason).

3. entrypoint.sh: Changed shebang from `#!/bin/sh` to `#!/bin/bash` (bash is installed in the Docker image). Replaced both `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` and `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"` with safe xargs-based tokenization into bash arrays, guarded by `if [ -n "$VAR" ]` to prevent empty-value issues. Updated reviewdog invocation to use `"${reviewdog_flags[@]}"` instead of `"$@"`.

4. dockerless/action.yml: Quoted `$ACTION_PATH` in the run step to prevent word-splitting and glob expansion.

