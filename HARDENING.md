<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.73.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.73.1** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes remote content fetched via curl directly to bash: `curl -sSL https://raw.githubusercontent.com/rhysd/actionlint/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. If the remote URL is compromised or the content is tampered with in transit, arbitrary code will execute on the runner.

Locations:

- `scripts/install-actionlint.sh:17`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes remote content fetched via curl directly to sh: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. If the remote URL is compromised or the content is tampered with in transit, arbitrary code will execute on the runner.

Locations:

- `scripts/install-reviewdog.sh:17`

### script-injection (severity: high)

Rule (b) violation: In entrypoint.sh, the shell variables ${INPUT_ACTIONLINT_FLAGS} and ${INPUT_REVIEWDOG_FLAGS} — which are set from the workflow-controllable inputs `inputs.actionlint_flags` and `inputs.reviewdog_flags` in dockerless/action.yml — are expanded unquoted in shell commands. Specifically: `actionlint -oneline ${INPUT_ACTIONLINT_FLAGS}` (line 32) and `${INPUT_REVIEWDOG_FLAGS}` as a trailing unquoted argument to reviewdog (line 48). An attacker who controls these inputs can inject shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) to execute arbitrary commands on the runner.

Locations:

- `entrypoint.sh:32`
- `entrypoint.sh:48`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed 3 findings across 3 files:

1. scripts/install-actionlint.sh: Replaced `curl ... | bash -s -- "$ACTIONLINT_VERSION"` with download-then-execute pattern. Script is saved to a mktemp file, executed as `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"` (dropping the '--' which was the shell's option terminator in the pipe form), then cleaned up.

2. scripts/install-reviewdog.sh: Replaced `curl ... | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` with download-then-execute pattern. Script is saved to a mktemp file, executed as `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` (dropping the '--'), then cleaned up.

3. entrypoint.sh: Changed shebang from #!/bin/sh to #!/bin/bash to enable array support. Both INPUT_ACTIONLINT_FLAGS and INPUT_REVIEWDOG_FLAGS are now tokenized into bash arrays using the xargs/NUL-delimited pattern with guards (preventing injection of shell metacharacters). Arrays are expanded with proper double-quoting: `"${actionlint_flags[@]}"` and `"${reviewdog_flags[@]}"`.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed `hardened/action/dockerless/action.yml` line 86: changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to properly double-quote the ACTION_PATH environment variable (which is sourced from `${{ github.action_path }}`) when it is expanded in the run: shell script.

