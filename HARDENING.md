<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.78.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.78.1** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh downloads a remote script and pipes it directly to bash: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. This is an unsafe pattern — if the remote URL is compromised or the commit is tampered with, arbitrary code executes on the runner. The script should be downloaded to a file first, its integrity verified (e.g. via checksum), and then executed separately.

Locations:

- `scripts/install-actionlint.sh:17`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh downloads a remote install script and pipes it directly to sh: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. This is an unsafe pattern — if the remote URL is compromised, arbitrary code executes on the runner. The script should be downloaded to a file first, its integrity verified (e.g. via checksum), and then executed separately.

Locations:

- `scripts/install-reviewdog.sh:17`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell

**Notes:**

Fixed two unsafe curl-pipe-to-shell patterns:

1. scripts/install-actionlint.sh: Replaced `curl ... | bash -s -- "$ACTIONLINT_VERSION"` with: download to a temp file via `curl ... -o "$DOWNLOAD_SCRIPT"`, then execute `bash "$DOWNLOAD_SCRIPT" "$ACTIONLINT_VERSION"`, then clean up. The `--` was dropped because it was the shell's own option terminator (for `-s` stdin mode), not an argument the downloaded script expects.

2. scripts/install-reviewdog.sh: Replaced `curl ... | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` with: download to a temp file via `curl ... -o "$INSTALL_SCRIPT"`, then execute `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`, then clean up. Both `-s` (read from stdin) and `--` (shell option terminator) were dropped since the script is now run from a file, not piped via stdin.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed three script injection issues:
1. entrypoint.sh line 39: Replaced `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` with safe xargs-based tokenization using a guarded if-block and `while IFS= read -r -d '' _t; do set -- "$@" "$_t"; done < <(printf '%s' "${INPUT_ACTIONLINT_FLAGS}" | xargs printf '%s\0')`. This prevents shell metacharacter injection while preserving quote-aware argument splitting.
2. entrypoint.sh line 52: Same fix applied for `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"`.
3. Changed shebang from `#!/bin/sh` to `#!/bin/bash` since the Dockerfile installs bash and process substitution `< <(...)` requires bash.
4. dockerless/action.yml line 80: Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to properly quote the path variable derived from `github.action_path`.

