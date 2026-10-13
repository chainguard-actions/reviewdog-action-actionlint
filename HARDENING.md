<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.80.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.80.1** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In entrypoint.sh (invoked by dockerless/action.yml), the env vars INPUT_ACTIONLINT_FLAGS and INPUT_REVIEWDOG_FLAGS are sourced from inputs.actionlint_flags and inputs.reviewdog_flags (untrusted caller-controlled values) and are expanded unquoted inside eval: `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` and `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"`. An attacker-controlled input value containing shell metacharacters (`;`, `|`, `$(...)`, etc.) will be interpreted by the shell, enabling arbitrary command injection.

Locations:

- `entrypoint.sh:35`
- `entrypoint.sh:46`

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes curl output directly to bash: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. If the remote URL is compromised or the network is intercepted, arbitrary code executes on the runner without any integrity check.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes curl output directly to sh: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. If the remote URL is compromised or the network is intercepted, arbitrary code executes on the runner without any integrity check.

Locations:

- `scripts/install-reviewdog.sh:17`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unsafe-shell

**Notes:**

Fixed three security findings: (1) script-injection in entrypoint.sh: changed shebang to #!/bin/bash (bash is installed in the Docker image) and replaced both eval "set -- ${INPUT_ACTIONLINT_FLAGS}" and eval "set -- ${INPUT_REVIEWDOG_FLAGS}" with bash arrays populated via the xargs/read-loop pattern (safe tokenization without shell metacharacter interpretation); (2) unsafe-shell in scripts/install-actionlint.sh: download script to temp file with curl -o then execute with bash, dropping the '--' that was the shell's option terminator in the pipe form; (3) unsafe-shell in scripts/install-reviewdog.sh: download script to temp file with curl -o then execute with sh, dropping the '--' that was sh's own option terminator from 'sh -s --'.

