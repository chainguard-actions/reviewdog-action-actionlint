<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.73.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.73.4** was hardened automatically. 5 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes curl output directly to bash without first saving to a file: `curl -sSL https://raw.githubusercontent.com/rhysd/actionlint/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. This allows a compromised or man-in-the-middle remote server to execute arbitrary code on the runner.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes curl output directly to sh without first saving to a file: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. This allows a compromised or man-in-the-middle remote server to execute arbitrary code on the runner.

Locations:

- `scripts/install-reviewdog.sh:17`

### script-injection (severity: high)

Rule (b): In dockerless/action.yml, the run: block executes `$ACTION_PATH/../entrypoint.sh` where `$ACTION_PATH` is set from `${{ github.action_path }}` (a github.* context value) and is unquoted. An attacker-controlled path containing shell metacharacters could alter command execution.

Locations:

- `dockerless/action.yml:83`

### script-injection (severity: high)

Rule (b): In entrypoint.sh, `${INPUT_ACTIONLINT_FLAGS}` is expanded unquoted in `actionlint -oneline ${INPUT_ACTIONLINT_FLAGS}`. This variable is set from `inputs.actionlint_flags` (a workflow-controllable input) via the env block in dockerless/action.yml. An attacker-supplied value containing shell metacharacters (`;`, `|`, `&`, etc.) could inject arbitrary shell commands. The file has a `# shellcheck disable=SC2086` comment acknowledging the unquoted expansion.

Locations:

- `entrypoint.sh:33`

### script-injection (severity: high)

Rule (b): In entrypoint.sh, `${INPUT_REVIEWDOG_FLAGS}` is expanded unquoted in the reviewdog invocation. This variable is set from `inputs.reviewdog_flags` (a workflow-controllable input) via the env block in dockerless/action.yml. An attacker-supplied value containing shell metacharacters could inject arbitrary shell commands.

Locations:

- `entrypoint.sh:46`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed 5 findings across 4 files:

1. scripts/install-actionlint.sh: Download script to temp file with `curl -o`, then execute `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"`. Dropped '--' (was shell's option terminator for pipe form, not a script argument).

2. scripts/install-reviewdog.sh: Download script to temp file with `curl -o`, then execute `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. Dropped '--' (was shell's option terminator for `sh -s --`, not a script argument).

3. dockerless/action.yml line 83: Quoted `$ACTION_PATH` → `"$ACTION_PATH/../entrypoint.sh"` to prevent shell metacharacter injection from a crafted action_path.

4. entrypoint.sh INPUT_ACTIONLINT_FLAGS: Wrapped in `run_actionlint()` function using POSIX-compatible xargs tokenization (`xargs -n1 printf '%s\n'` + `while IFS= read -r t`) to safely build positional parameters, then calls `actionlint -oneline "$@"`.

5. entrypoint.sh INPUT_REVIEWDOG_FLAGS: Wrapped in `run_reviewdog()` function using same xargs tokenization approach, then calls reviewdog with `"$@"`. Function correctly receives stdin from the pipe since the heredoc only redirects stdin for the while loop, not for reviewdog.

