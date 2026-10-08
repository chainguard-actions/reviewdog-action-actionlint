<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.80.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.80.0** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes the output of curl directly to bash without first saving the script to a file and verifying it. Pattern: `curl -sSL https://raw.githubusercontent.com/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. An attacker who can intercept or tamper with the remote URL (e.g. via a MITM or a compromised GitHub raw URL) can execute arbitrary code on the runner.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes the output of curl directly to sh without first saving the script to a file and verifying it. Pattern: `curl -sSL https://raw.githubusercontent.com/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. An attacker who can intercept or tamper with the remote URL can execute arbitrary code on the runner.

Locations:

- `scripts/install-reviewdog.sh:17`

### script-injection (severity: high)

Rule (b): entrypoint.sh uses `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` (line 39) and `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"` (line 54) where INPUT_ACTIONLINT_FLAGS and INPUT_REVIEWDOG_FLAGS are env vars set directly from `inputs.actionlint_flags` and `inputs.reviewdog_flags` in dockerless/action.yml. The variable is expanded unquoted inside the double-quoted eval string, allowing an attacker to inject arbitrary shell commands via the action inputs (e.g. supplying `; malicious_command` as a flag value). The shell expands `${INPUT_ACTIONLINT_FLAGS}` before eval sees it, so shell metacharacters in the input are interpreted.

Locations:

- `entrypoint.sh:39`
- `entrypoint.sh:54`

### script-injection (severity: high)

Rule (b): In dockerless/action.yml, the 'Run' step sets `ACTION_PATH: ${{ github.action_path }}` in its env block and then uses it unquoted in the run command: `run: $ACTION_PATH/../entrypoint.sh`. The env var `$ACTION_PATH` is sourced from the `github.*` context and is not double-quoted in the shell command, violating the requirement that all env vars holding workflow-controllable context values be double-quoted in run blocks.

Locations:

- `dockerless/action.yml:73`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed 4 findings across 4 files:
1. scripts/install-actionlint.sh: Download script to temp file with `curl -o`, then execute with `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"`. Dropped '--' (was shell's option terminator in pipe form).
2. scripts/install-reviewdog.sh: Download script to temp file with `curl -o`, then execute with `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. Dropped '--' (was shell's option terminator in pipe form).
3. entrypoint.sh: Changed shebang from #!/bin/sh to #!/bin/bash (bash is installed in the Alpine Docker image via `apk add bash`). Replaced both `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` and `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"` with safe bash array + xargs NUL-delimited tokenization. Updated reviewdog invocation to use `"${reviewdog_flags[@]}"` instead of `"$@"`.
4. dockerless/action.yml: Quoted `$ACTION_PATH` in the run command: `run: "$ACTION_PATH/../entrypoint.sh"`.

