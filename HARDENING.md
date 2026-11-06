<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.81.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.81.2** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b): the expansion of an env var built from workflow context is not quoted. In the dockerless composite action, the 'Run' step has `run: $ACTION_PATH/../entrypoint.sh`. ACTION_PATH comes from `${{ github.action_path }}` and is used without double quotes, so the shell splits it on whitespace and expands glob characters. Fix: `"$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `dockerless/action.yml:85`

### script-injection (severity: high)

The entrypoint script passes action inputs through eval: `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` (line 39) and `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"` (line 54). Both values come from the actionlint_flags and reviewdog_flags inputs, which the calling workflow controls. Any `$(...)`, backticks, `;` or similar in them runs as shell code. This happens in both the Docker and the dockerless variants, and the REVIEWDOG_GITHUB_API_TOKEN secret is in that shell's environment. Fix: split the flags safely without eval (for example, plain unquoted word-splitting with globbing turned off via set -f, or one flag per line read into the argument list).

Locations:

- `entrypoint.sh:39`
- `entrypoint.sh:54`

### unsafe-shell (severity: high)

A remote script is piped straight to a shell: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74.../install.sh | sh -s -- -b "$INSTALL_DIR" ...`. This script is run by the dockerless composite action and by the Dockerfile build. Download the script to a file, check it, then run it in a separate step.

Locations:

- `scripts/install-reviewdog.sh:17`

### unsafe-shell (severity: high)

A remote script is piped straight to a shell: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/08bb2c4f.../scripts/download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. This script is run by the dockerless composite action and by the Dockerfile build. Download the script to a file, check it, then run it in a separate step.

Locations:

- `scripts/install-actionlint.sh:18`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unsafe-shell

**Notes:**

Edits made; nothing was run or tested.

1. **dockerless/action.yml:** the Run step now quotes the path: `"$ACTION_PATH/../entrypoint.sh"`.

2. **entrypoint.sh:** both `eval "set -- ..."` lines are gone. Each flags input is now split on whitespace only, with globbing turned off (`set -f; set -- ${INPUT_..._FLAGS:-}; set +f`). This works in plain POSIX sh and evaluates nothing, so `$(...)`, backticks and `;` reach the tool as plain text.
   - **Behaviour change:** quoted flag values containing spaces no longer stay together. For example, `-ignore="foo bar"` is now split into two arguments, and the quote marks are passed through as text.

3. **scripts/install-reviewdog.sh and scripts/install-actionlint.sh:** each installer is now downloaded to a temp file with `curl -fsSL -o`. The script stops if that file is empty, then runs it with `sh FILE -b DIR vVER` or `bash FILE VER`. The `-s --` from the pipe form was dropped so the arguments reach the installer in the right positions.
   - **Limit on the check:** it only confirms the file isn't empty. There is no checksum check, because I had no published hash to compare against. The URLs are still pinned to a fixed commit.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

Repaired the corrupted text in entrypoint.sh around line 50. The block now has `exit "${actionlint_exit}"` and the missing `fi`, and the INPUT_REVIEWDOG_FLAGS split (set -f; set -- ${INPUT_REVIEWDOG_FLAGS:-}; set +f) is back in shape. That split feeds "$@" to reviewdog, which still reads stdin as before.

