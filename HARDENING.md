<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.75.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.75.3** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes the output of curl directly to bash without first saving to a file: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. If the remote URL is compromised or the network is intercepted, arbitrary code executes immediately with no opportunity to inspect the downloaded content.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes the output of curl directly to sh without first saving to a file: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. If the remote URL is compromised or the network is intercepted, arbitrary code executes immediately with no opportunity to inspect the downloaded content.

Locations:

- `scripts/install-reviewdog.sh:18`

### script-injection (severity: high)

Rule (b) violation in entrypoint.sh: the env vars INPUT_ACTIONLINT_FLAGS and INPUT_REVIEWDOG_FLAGS — sourced from inputs.actionlint_flags and inputs.reviewdog_flags in dockerless/action.yml — are expanded **unquoted** in shell commands. The script even suppresses the shellcheck warning with `# shellcheck disable=SC2086`. An attacker-controlled input value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) can break out of the intended command and execute arbitrary shell code. Offending lines: `actionlint -oneline ${INPUT_ACTIONLINT_FLAGS} | while read -r r; do` and `${INPUT_REVIEWDOG_FLAGS}` at the end of the reviewdog invocation.

Locations:

- `entrypoint.sh:33`
- `entrypoint.sh:51`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed 3 findings across 3 files:

1. scripts/install-actionlint.sh (unsafe-shell): Replaced `curl ... | bash -s -- "$ACTIONLINT_VERSION"` with download-then-execute pattern: curl to a mktemp file, then `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"`. Dropped the '--' per instructions (it was the shell's option terminator, not the script's argument).

2. scripts/install-reviewdog.sh (unsafe-shell): Replaced `curl ... | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` with download-then-execute pattern: curl to a mktemp file, then `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. Dropped the '--' per instructions.

3. entrypoint.sh (script-injection): Changed shebang from #!/bin/sh to #!/bin/bash (bash is installed in the Docker image via apk). Replaced unquoted `${INPUT_ACTIONLINT_FLAGS}` and `${INPUT_REVIEWDOG_FLAGS}` expansions with xargs-based array tokenization using the guarded while/read/-d'' pattern. Arrays are expanded as `"${actionlint_flags[@]}"` and `"${reviewdog_flags[@]}"` to preserve argument boundaries and prevent shell metacharacter injection. Removed the `# shellcheck disable=SC2086` suppression comment.

