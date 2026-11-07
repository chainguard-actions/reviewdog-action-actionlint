<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.80.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.80.2** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b): the 'Run' step in the dockerless composite action expands an env var without quotes. ACTION_PATH is set from ${{ github.action_path }} and used as `run: $ACTION_PATH/../entrypoint.sh`, so the shell splits and globs the value. Quote it: "$ACTION_PATH/../entrypoint.sh".

Locations:

- `dockerless/action.yml:85`

### script-injection (severity: high)

The entrypoint script passes user inputs to eval: `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` (line 39) and `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"` (line 54). These values come from inputs.actionlint_flags and inputs.reviewdog_flags. Shell metacharacters in them, such as `$(...)`, `;` or backticks, run as commands. This affects the Docker action and the dockerless action.

Locations:

- `entrypoint.sh:39`
- `entrypoint.sh:54`

### unsafe-shell (severity: high)

A remote script is piped straight into a shell: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/08bb2c4f.../scripts/download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. Download the script to a file first, check it, then run it.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

A remote script is piped straight into a shell: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74.../install.sh | sh -s -- -b "$INSTALL_DIR" ...`. Download the script to a file first, check it, then run it.

Locations:

- `scripts/install-reviewdog.sh:17`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unsafe-shell

**Notes:**

- dockerless/action.yml: the Run step now quotes the path: run: '"$ACTION_PATH/../entrypoint.sh"'.
- entrypoint.sh: removed both `eval "set -- ${INPUT_*_FLAGS}"` lines. The flags are now split by a `split_flags` helper. It respects quotes the same way eval did (so `-ignore="foo bar"` stays one argument) but never runs anything in the value. It uses the quote-aware xargs split, with the guard for empty input, the `xargs -r true` check that fails on an unmatched quote, and the shell's built-in printf with the trailing `sh`. The results go into arrays, which are expanded in a form that is safe under `set -u` on bash 3.2. The reviewdog flags are still split after the actionlint exit-code check, as upstream did, and reviewdog still reads its input from the pipe. I changed the shebang to #!/bin/bash because the script now uses arrays and process substitution. The Dockerfile already installs bash (`apk add ... bash`), and the dockerless runners have bash.
- scripts/install-actionlint.sh and scripts/install-reviewdog.sh: each installer is now downloaded to a mktemp file with `curl -sSfL -o`, checked to be non-empty, then run as `bash "$f" "$ACTIONLINT_VERSION"` / `sh "$f" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. I dropped the `-s --` from the old pipe form, so the arguments reach the installers unchanged.
- action.yml (the Docker action) runs upstream's prebuilt image, so the entrypoint.sh changes only take effect in the dockerless action and in images built from the Dockerfile.
- No tests were run.

