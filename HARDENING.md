<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.75.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.75.0** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes remote content directly to bash: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. The script is fetched and executed in one step without any integrity verification, allowing a compromised upstream URL to execute arbitrary code on the runner.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes remote content directly to sh: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. The script is fetched and executed in one step without any integrity verification, allowing a compromised upstream URL to execute arbitrary code on the runner.

Locations:

- `scripts/install-reviewdog.sh:17`

### script-injection (severity: high)

Rule (b) violation: entrypoint.sh expands `${INPUT_ACTIONLINT_FLAGS}` (line 32) and `${INPUT_REVIEWDOG_FLAGS}` (line 44) without double-quoting. Both variables are set from caller-controlled inputs (`inputs.actionlint_flags` and `inputs.reviewdog_flags` in dockerless/action.yml). An attacker can inject shell metacharacters (`;`, `|`, `$(...)`, etc.) through these inputs to achieve command injection. The `# shellcheck disable=SC2086` comment confirms the intentional unquoting, but this does not mitigate the security risk.

Locations:

- `entrypoint.sh:32`
- `entrypoint.sh:44`

### script-injection (severity: high)

Rule (b) violation: In dockerless/action.yml, the 'Run' step uses `run: $ACTION_PATH/../entrypoint.sh` where `$ACTION_PATH` is unquoted and is set from `${{ github.action_path }}` (a github.* context value) in the env block. Per the security rules, github.* values are untrusted and shell variable expansions derived from them must be double-quoted to prevent word-splitting and glob expansion.

Locations:

- `dockerless/action.yml:84`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed 4 findings across 4 files:
1. scripts/install-actionlint.sh: Replaced `curl ... | bash -s -- "$VERSION"` with download-to-tempfile then `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"` (dropped '--' per instructions — it was the shell's option terminator, not the script's).
2. scripts/install-reviewdog.sh: Replaced `curl ... | sh -s -- -b "$DIR" "v$VER"` with download-to-tempfile then `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` (dropped '--' per instructions).
3. entrypoint.sh: Changed shebang to #!/bin/bash (bash is installed in the Alpine Docker image via `apk add bash`). Replaced unquoted `${INPUT_ACTIONLINT_FLAGS}` and `${INPUT_REVIEWDOG_FLAGS}` with xargs-tokenized bash arrays using the guarded while/IFS/read -d '' pattern. reviewdog reads from stdin (the actionlint pipe) so flags are tokenized separately and expanded as `"${reviewdog_flags[@]}"`.
4. dockerless/action.yml: Quoted `$ACTION_PATH/../entrypoint.sh` as `"$ACTION_PATH/../entrypoint.sh"` to prevent word-splitting/glob expansion from the github.action_path context value.

