<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.73.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.73.3** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes remote content directly to bash without first saving to a file: `curl -sSL https://raw.githubusercontent.com/rhysd/actionlint/914e7df21a07ef503a81201c76d2b11c789d3fca/scripts/download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. If the remote URL is compromised or the commit is reused with different content, arbitrary code executes immediately.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes remote content directly to sh without first saving to a file: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74df59de7ebfd9276afabd62ea2de4d7dd/install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. If the remote URL is compromised, arbitrary code executes immediately.

Locations:

- `scripts/install-reviewdog.sh:18`

### script-injection (severity: high)

Rule (b) violation: entrypoint.sh uses unquoted shell variable expansions of workflow-controllable inputs. Line 32: `actionlint -oneline ${INPUT_ACTIONLINT_FLAGS}` — INPUT_ACTIONLINT_FLAGS is set from `inputs.actionlint_flags` (via the composite action's env block). Line 46: `${INPUT_REVIEWDOG_FLAGS}` — INPUT_REVIEWDOG_FLAGS is set from `inputs.reviewdog_flags`. Both are unquoted, allowing an attacker-supplied value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) to break out of the intended argument context and inject arbitrary shell commands.

Locations:

- `entrypoint.sh:32`
- `entrypoint.sh:46`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed 3 findings across 3 files:

1. scripts/install-actionlint.sh: Replaced `curl ... | bash -s -- "$VERSION"` with download-then-execute pattern. Script is saved to a mktemp file, executed as `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"` (dropping the '--' which was the shell's option terminator, not the script's argument), then cleaned up.

2. scripts/install-reviewdog.sh: Replaced `curl ... | sh -s -- -b "$INSTALL_DIR" "v$VERSION"` with download-then-execute pattern. Script is saved to a mktemp file, executed as `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` (dropping the '--'), then cleaned up.

3. entrypoint.sh: Fixed script-injection for both INPUT_ACTIONLINT_FLAGS (line 32) and INPUT_REVIEWDOG_FLAGS (line 46). Both are list-style inputs tokenized safely using `xargs -n1` into temp files, then read line-by-line into positional parameters via `set --`. This is POSIX sh compatible. For reviewdog (which reads stdin from the actionlint pipe), the flags are built inside a subshell group reading from a temp file (separate fd from stdin), preserving the pipe's stdin for reviewdog's input.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in hardened/action/dockerless/action.yml: quoted the unquoted `$ACTION_PATH` variable in the 'Run' step's run command. Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to prevent shell metacharacters in the workflow-controllable `github.action_path` value from being interpreted by the shell.

