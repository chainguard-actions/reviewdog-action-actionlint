<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.76.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.76.1** was hardened automatically. 5 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes remote content directly to bash: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/08bb2c4f0d039744455b87aef1c647fb8b66d37b/scripts/download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. This allows a compromised or malicious remote server to execute arbitrary code on the runner.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes remote content directly to sh: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74df59de7ebfd9276afabd62ea2de4d7dd/install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. This allows a compromised or malicious remote server to execute arbitrary code on the runner.

Locations:

- `scripts/install-reviewdog.sh:17`

### script-injection (severity: high)

Rule (b): In dockerless/action.yml, the 'Run' step sets `ACTION_PATH: ${{ github.action_path }}` in its env: block and then uses the unquoted expansion `run: $ACTION_PATH/../entrypoint.sh`. The env var is sourced from the `github.*` context and is not double-quoted in the shell command, allowing shell metacharacters in the value to be interpreted by the shell.

Locations:

- `dockerless/action.yml:82`

### script-injection (severity: high)

Rule (b): In entrypoint.sh, `${INPUT_ACTIONLINT_FLAGS}` (sourced from `inputs.actionlint_flags`) is used unquoted in the shell command `actionlint -oneline ${INPUT_ACTIONLINT_FLAGS}`. The script even has a `# shellcheck disable=SC2086` comment acknowledging the unquoted word-splitting. An attacker-controlled value with shell metacharacters (`;`, `|`, `&`, etc.) could alter command execution.

Locations:

- `entrypoint.sh:32`

### script-injection (severity: high)

Rule (b): In entrypoint.sh, `${INPUT_REVIEWDOG_FLAGS}` (sourced from `inputs.reviewdog_flags`) is used unquoted in the reviewdog invocation: `${INPUT_REVIEWDOG_FLAGS}` as a trailing positional argument. An attacker-controlled value with shell metacharacters could inject additional flags or commands.

Locations:

- `entrypoint.sh:48`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed 5 findings across 4 files:

1. scripts/install-actionlint.sh: Replaced `curl ... | bash -s -- "$ACTIONLINT_VERSION"` with download-then-execute pattern: curl saves to a temp file, then `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"` runs it. The '--' was dropped (it was the shell's stdin-mode option terminator, not the script's argument).

2. scripts/install-reviewdog.sh: Replaced `curl ... | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` with download-then-execute pattern: curl saves to a temp file, then `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` runs it. The '--' was dropped per instructions.

3. dockerless/action.yml: Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to prevent shell metacharacter interpretation of the github.action_path value.

4. entrypoint.sh (both script-injection findings): Changed shebang from #!/bin/sh to #!/bin/bash (bash is confirmed installed in the Docker image via `apk add bash`). Replaced unquoted `${INPUT_ACTIONLINT_FLAGS}` and `${INPUT_REVIEWDOG_FLAGS}` expansions with xargs-based quote-aware tokenization into bash arrays, using the guarded `if [ -n "$VAR" ]` pattern. Arrays are expanded as `"${actionlint_flags[@]}"` and `"${reviewdog_flags[@]}"`. Removed the `# shellcheck disable=SC2086` comment.

