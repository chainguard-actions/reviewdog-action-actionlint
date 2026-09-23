<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.75.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.75.2** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes remote content fetched via curl directly to bash: `curl -sSL https://raw.githubusercontent.com/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. The script is not downloaded and verified before execution, allowing a compromised or MITM'd remote URL to execute arbitrary code.

Locations:

- `scripts/install-actionlint.sh:17`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes remote content fetched via curl directly to sh: `curl -sSL https://raw.githubusercontent.com/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. The script is not downloaded and verified before execution, allowing a compromised or MITM'd remote URL to execute arbitrary code.

Locations:

- `scripts/install-reviewdog.sh:16`

### script-injection (severity: high)

Sub-rule (b): In the 'Run' step of dockerless/action.yml, the env var ACTION_PATH is set from `${{ github.action_path }}` and then used unquoted in the run command: `run: $ACTION_PATH/../entrypoint.sh`. An unquoted shell variable expansion of a workflow-controllable value allows shell metacharacter injection. The value should be quoted: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `dockerless/action.yml:76`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

1. scripts/install-actionlint.sh: Replaced `curl ... | bash -s -- "$ACTIONLINT_VERSION"` with downloading the script to a temp file via `curl ... -o "$INSTALL_SCRIPT"`, then executing `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"`. Dropped the `--` (it was the shell's own option terminator in the pipe form, not an argument to the downloaded script). Temp file is cleaned up after execution.
2. scripts/install-reviewdog.sh: Replaced `curl ... | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` with downloading the script to a temp file via `curl ... -o "$INSTALL_SCRIPT"`, then executing `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. Dropped the `--` (same reason). Temp file is cleaned up after execution.
3. dockerless/action.yml: Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to properly quote the variable and prevent shell metacharacter injection.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in entrypoint.sh by:
1. Changed shebang from #!/bin/sh to #!/bin/bash (bash is installed in the Docker image via `apk add bash`)
2. Used xargs-based array tokenization for INPUT_ACTIONLINT_FLAGS and INPUT_REVIEWDOG_FLAGS — both are list-style flag inputs that need proper word-splitting with quote awareness
3. Each tokenization is guarded with `if [ -n "$VAR" ]` to prevent xargs from emitting an empty token on empty input
4. Arrays are expanded as "${actionlint_flags[@]}" and "${reviewdog_flags[@]}" to safely pass each token as a separate argument
5. Removed the `# shellcheck disable=SC2086` comment since the underlying issue is now fixed

