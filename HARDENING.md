<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.80.8

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.80.8** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

The entrypoint script runs action inputs through eval. Line 39 has `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` and line 54 has `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"`. These values come from inputs.actionlint_flags and inputs.reviewdog_flags, which reach the script as INPUT_* env vars in both the docker and composite (dockerless) variants. A value containing `$(...)`, backticks or `;` will be run as shell code. Instead, pass the flags to the commands without eval: split them on whitespace or read them as a safe list, and never re-parse them with eval.

Locations:

- `entrypoint.sh:39`
- `entrypoint.sh:54`

### script-injection (severity: high)

Rule (b), unquoted expansion. The composite step 'Run' sets ACTION_PATH from `${{ github.action_path }}` and then runs `run: $ACTION_PATH/../entrypoint.sh` without double quotes, so the shell will split the path on spaces and expand glob characters. Change it to `"$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `dockerless/action.yml:86`

### unsafe-shell (severity: high)

This supporting script, run by the dockerless composite action, downloads a remote script and pipes it straight into bash: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/08bb2c4f.../scripts/download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. Download the script to a file first, check it, then run it as a separate step.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

This supporting script, run by the dockerless composite action, downloads a remote script and pipes it straight into sh: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74.../install.sh | sh -s -- -b "$INSTALL_DIR" ...`. Download the script to a file first, check it, then run it as a separate step.

Locations:

- `scripts/install-reviewdog.sh:17`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unsafe-shell

**Notes:**

entrypoint.sh: took out both `eval "set -- $FLAGS"` lines. The flags are now split with a quote-aware xargs pass. A first `xargs -r true` makes the script fail on an unmatched quote. The tokens are then read into positional parameters with `set --`, so the script stays POSIX sh, which the Alpine/busybox image needs. Quoted values like -ignore="foo bar" still come through as one argument, and $(...), backticks and ';' are passed as plain text instead of being run. An empty input adds no arguments. dockerless/action.yml: the entrypoint path is now double-quoted ("$ACTION_PATH/../entrypoint.sh"). install-actionlint.sh and install-reviewdog.sh: each installer is now downloaded to a temp file with curl -f, checked to be non-empty, then run separately. I dropped the '-s --' from the old pipe form and kept the arguments exactly as upstream passed them. I didn't run any of these changes.

