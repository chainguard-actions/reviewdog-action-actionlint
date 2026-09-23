<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.77.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.77.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes remote content directly to bash: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/08bb2c4f0d039744455b87aef1c647fb8b66d37b/scripts/download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. The script is not downloaded to a file first and verified before execution, allowing a compromised or man-in-the-middle response to execute arbitrary code.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes remote content directly to sh: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74df59de7ebfd9276afabd62ea2de4d7dd/install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. The script is not downloaded to a file first and verified before execution, allowing a compromised or man-in-the-middle response to execute arbitrary code.

Locations:

- `scripts/install-reviewdog.sh:17`

### script-injection (severity: high)

Rule (b) violation in dockerless/action.yml: the `run:` block executes `$ACTION_PATH/../entrypoint.sh` where `$ACTION_PATH` is an unquoted shell variable expansion. `ACTION_PATH` is set from `${{ github.action_path }}` (a `github.*` context value) in the `env:` block of the same step. Unquoted expansion allows shell metacharacters in the value to be interpreted by the shell. The variable should be double-quoted: `"$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `dockerless/action.yml:82`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed three security findings: (1) scripts/install-actionlint.sh: replaced 'curl ... | bash -s -- "$ACTIONLINT_VERSION"' with downloading to a mktemp file then executing 'bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"' (dropped the '--' which was the shell's option terminator, not a script argument); (2) scripts/install-reviewdog.sh: replaced 'curl ... | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"' with downloading to a mktemp file then executing 'sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"' (dropped the '--' which was the shell's option terminator); (3) dockerless/action.yml line 82: added double-quotes around '$ACTION_PATH/../entrypoint.sh' to prevent shell metacharacter interpretation of the ACTION_PATH variable.

