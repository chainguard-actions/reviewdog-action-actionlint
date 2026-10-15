<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.80.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.80.2** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes curl output directly to bash without first saving to a file: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. This allows a compromised or man-in-the-middle remote server to execute arbitrary code on the runner.

Locations:

- `scripts/install-actionlint.sh:19`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes curl output directly to sh without first saving to a file: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. This allows a compromised or man-in-the-middle remote server to execute arbitrary code on the runner.

Locations:

- `scripts/install-reviewdog.sh:17`

### script-injection (severity: high)

Rule (b) violation: entrypoint.sh uses `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` where INPUT_ACTIONLINT_FLAGS is set from the user-controlled input `inputs.actionlint_flags` (via the env block in dockerless/action.yml). The variable is expanded unquoted inside eval, allowing an attacker to inject arbitrary shell commands by supplying a crafted value for the actionlint_flags input (e.g. `; malicious_command #`).

Locations:

- `entrypoint.sh:35`
- `dockerless/action.yml:80`

### script-injection (severity: high)

Rule (b) violation: entrypoint.sh uses `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"` where INPUT_REVIEWDOG_FLAGS is set from the user-controlled input `inputs.reviewdog_flags` (via the env block in dockerless/action.yml). The variable is expanded unquoted inside eval, allowing an attacker to inject arbitrary shell commands by supplying a crafted value for the reviewdog_flags input.

Locations:

- `entrypoint.sh:47`
- `dockerless/action.yml:79`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed 4 findings across 3 files:

1. scripts/install-actionlint.sh: Replaced `curl | bash -s -- "$ACTIONLINT_VERSION"` with download-then-execute pattern: curl to temp file, then `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"` (dropped '--' per instructions as it was the shell's option terminator in the pipe form).

2. scripts/install-reviewdog.sh: Replaced `curl | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` with download-then-execute pattern: curl to temp file, then `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` (dropped '--' per instructions).

3. entrypoint.sh: Changed shebang from `#!/bin/sh` to `#!/bin/bash` (bash is installed in the Docker image via `apk add bash`). Replaced both `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` and `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"` with safe xargs-based tokenization into bash arrays (`actionlint_flags` and `reviewdog_flags`), using the guarded xargs loop pattern with `read -d ''`. Updated the actionlint and reviewdog invocations to use `"${actionlint_flags[@]}"` and `"${reviewdog_flags[@]}"` respectively instead of `"$@"`.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script-injection in hardened/action/dockerless/action.yml: changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to properly quote the ACTION_PATH environment variable and prevent shell metacharacter interpretation.

