<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.76.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.76.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes remote content directly to bash without first downloading and verifying it: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. If the remote URL is compromised or the content is tampered with in transit, arbitrary code will execute on the runner.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes remote content directly to sh without first downloading and verifying it: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. If the remote URL is compromised or the content is tampered with in transit, arbitrary code will execute on the runner.

Locations:

- `scripts/install-reviewdog.sh:17`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell

**Notes:**

Fixed two unsafe-shell findings:
1. scripts/install-actionlint.sh: Replaced `curl ... | bash -s -- "$ACTIONLINT_VERSION"` with download-then-execute: curl downloads to a temp file, then `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"` executes it. The '--' was dropped as it was the shell's option terminator, not an argument to the downloaded script.
2. scripts/install-reviewdog.sh: Replaced `curl ... | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` with download-then-execute: curl downloads to a temp file, then `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` executes it. The '--' was dropped for the same reason. Both temp files are cleaned up after execution.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed two locations:
1. hardened/action/dockerless/action.yml line 83: Quoted `$ACTION_PATH` in the run command: changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to prevent shell metacharacter interpretation.
2. hardened/action/entrypoint.sh lines 34 and 56: Replaced unquoted `${INPUT_ACTIONLINT_FLAGS}` and `${INPUT_REVIEWDOG_FLAGS}` expansions (which had `# shellcheck disable=SC2086` acknowledging the injection risk) with safe POSIX-compatible tokenization using xargs. For actionlint flags: `printf '%s' "${INPUT_ACTIONLINT_FLAGS}" | xargs actionlint -oneline` — xargs handles quote-aware tokenization. For reviewdog flags: used `set --` with a `while read` loop over `xargs -n1` output to build positional parameters, then passed as `"$@"` to reviewdog. Both approaches prevent shell injection from attacker-controlled values containing metacharacters.

