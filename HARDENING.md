<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.73.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.73.2** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes remote content directly to bash: `curl -sSL https://raw.githubusercontent.com/rhysd/actionlint/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. If the remote URL is compromised or the content is tampered with in transit, arbitrary code executes on the runner. The script should be downloaded to a file first, its integrity verified (e.g. checksum), and then executed separately.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes remote content directly to sh: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. If the remote URL is compromised or the content is tampered with in transit, arbitrary code executes on the runner. The script should be downloaded to a file first, its integrity verified (e.g. checksum), and then executed separately.

Locations:

- `scripts/install-reviewdog.sh:17`

### script-injection (severity: high)

Rule (b) violation: In entrypoint.sh, the shell variable `${INPUT_ACTIONLINT_FLAGS}` is expanded unquoted in the command `actionlint -oneline ${INPUT_ACTIONLINT_FLAGS}`. This variable is set from `inputs.actionlint_flags` (a workflow-controllable input) via the env block in dockerless/action.yml. An attacker-controlled value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) would be interpreted by the shell, enabling command injection. It should be quoted: `"${INPUT_ACTIONLINT_FLAGS}"` (or handled via an array if word-splitting is intentional).

Locations:

- `entrypoint.sh:30`
- `dockerless/action.yml:79`

### script-injection (severity: high)

Rule (b) violation: In entrypoint.sh, the shell variable `${INPUT_REVIEWDOG_FLAGS}` is expanded unquoted as a positional argument to reviewdog: `${INPUT_REVIEWDOG_FLAGS}`. This variable is set from `inputs.reviewdog_flags` (a workflow-controllable input) via the env block in dockerless/action.yml. An attacker-controlled value containing shell metacharacters would be interpreted by the shell, enabling command injection. It should be quoted: `"${INPUT_REVIEWDOG_FLAGS}"` (or handled via an array if word-splitting is intentional).

Locations:

- `entrypoint.sh:47`
- `dockerless/action.yml:78`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed 4 findings across 3 files:
1. scripts/install-actionlint.sh: Replaced `curl ... | bash -s -- "$ACTIONLINT_VERSION"` with download-to-tempfile then `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"`. Dropped '--' per instructions (it was the shell's stdin option terminator, not the script's argument).
2. scripts/install-reviewdog.sh: Replaced `curl ... | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` with download-to-tempfile then `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. Dropped '--' per instructions.
3. entrypoint.sh: Changed shebang from #!/bin/sh to #!/bin/bash to support arrays. Replaced unquoted `${INPUT_ACTIONLINT_FLAGS}` and `${INPUT_REVIEWDOG_FLAGS}` expansions with safe xargs-based tokenization into bash arrays (`actionlint_flags` and `reviewdog_flags`), then expanded them as `"${actionlint_flags[@]}"` and `"${reviewdog_flags[@]}"`. This prevents shell metacharacter injection while correctly handling multi-token flag lists.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed unquoted env var in dockerless/action.yml line 84: changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"`. The ACTION_PATH variable holds a github.action_path value and must be double-quoted in run: blocks per the security rules.

