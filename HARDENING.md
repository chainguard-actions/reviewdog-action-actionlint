<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.78.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.78.0** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run' step of dockerless/action.yml, the env var ACTION_PATH is set from ${{ github.action_path }} (a github.* context value) and then used unquoted in the run: block as `run: $ACTION_PATH/../entrypoint.sh`. Per the script-injection check, env vars holding values sourced from github.* must be double-quoted in run: scripts to prevent shell metacharacter interpretation. The correct form would be `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `dockerless/action.yml:76`

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes a remote curl download directly to bash: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. This script is invoked directly from a run: block in dockerless/action.yml. If the remote URL is compromised or the content is tampered with in transit, arbitrary code executes on the runner.

Locations:

- `scripts/install-actionlint.sh:17`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes a remote curl download directly to sh: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. This script is invoked directly from a run: block in dockerless/action.yml. If the remote URL is compromised or the content is tampered with in transit, arbitrary code executes on the runner.

Locations:

- `scripts/install-reviewdog.sh:17`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unsafe-shell

**Notes:**

Fixed 3 findings: (1) script-injection in dockerless/action.yml line 76: quoted `$ACTION_PATH` in the run: block as `"$ACTION_PATH/../entrypoint.sh"`; (2) unsafe-shell in scripts/install-actionlint.sh: replaced `curl ... | bash -s -- "$ACTIONLINT_VERSION"` with download-then-execute pattern (dropped `--` per rules); (3) unsafe-shell in scripts/install-reviewdog.sh: replaced `curl ... | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` with download-then-execute pattern (dropped `--` per rules).

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script-injection vulnerability in entrypoint.sh at lines 39 and 49. Changed shebang from #!/bin/sh to #!/bin/bash (bash is installed in the Dockerfile). Replaced both `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` and `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"` with safe xargs-based tokenization into bash arrays (actionlint_flags and reviewdog_flags respectively). Updated the reviewdog invocation to use "${reviewdog_flags[@]}" instead of "$@". The xargs approach honors shell quoting for proper word-splitting while preventing injection of shell metacharacters.

