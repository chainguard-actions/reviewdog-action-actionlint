<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.76.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.76.3** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes the output of a remote curl download directly to bash without first saving to a file: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. This allows a compromised or man-in-the-middle remote server to execute arbitrary code on the runner. The script should be downloaded to a temporary file, its integrity verified (e.g. checksum), and then executed separately.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes the output of a remote curl download directly to sh without first saving to a file: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. This allows a compromised or man-in-the-middle remote server to execute arbitrary code on the runner. The script should be downloaded to a temporary file, its integrity verified (e.g. checksum), and then executed separately.

Locations:

- `scripts/install-reviewdog.sh:17`

### script-injection (severity: high)

Rule (b) violation in dockerless/action.yml: the 'Run' step sets `ACTION_PATH: ${{ github.action_path }}` in its `env:` block and then uses the unquoted shell variable `$ACTION_PATH` directly in the `run:` command (`run: $ACTION_PATH/../entrypoint.sh`). Although `github.action_path` is system-controlled, routing any `github.*` context value through an env var and expanding it unquoted in a `run:` block allows shell metacharacters in the value to be interpreted by the shell. The value should be double-quoted: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `dockerless/action.yml:76`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed three security findings: (1) scripts/install-actionlint.sh: replaced `curl ... | bash -s -- "$ACTIONLINT_VERSION"` with downloading to a mktemp file then executing `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"` — dropped the `--` since it was the shell's option terminator for the pipe form, not the script's argument; (2) scripts/install-reviewdog.sh: replaced `curl ... | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` with downloading to a mktemp file then executing `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` — again dropped the `--` for the same reason; (3) dockerless/action.yml line 76: quoted the unquoted `$ACTION_PATH` expansion to `"$ACTION_PATH/../entrypoint.sh"` to prevent shell metacharacter interpretation.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed two eval-based script injection vulnerabilities in entrypoint.sh (lines ~39 and ~50). Replaced `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` and `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"` with safe xargs-based tokenization using bash arrays and NUL-delimited read loops. Changed shebang from #!/bin/sh to #!/bin/bash (bash is available in the container via Dockerfile's `apk add bash`). Each flags variable is guarded with `if [ -n "${VAR}" ]` to prevent xargs from emitting an empty token on empty input. Command invocations updated to use `"${actionlint_flags[@]}"` and `"${reviewdog_flags[@]}"` instead of `"$@"`.

