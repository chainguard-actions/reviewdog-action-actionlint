<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.81.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.81.0** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b): in the 'Run' step of dockerless/action.yml, the env var ACTION_PATH (set from ${{ github.action_path }}) is expanded without quotes: `run: $ACTION_PATH/../entrypoint.sh`. The shell can split the value on whitespace and expand glob characters. It should be written as "$ACTION_PATH/../entrypoint.sh".

Locations:

- `dockerless/action.yml:85`

### script-injection (severity: high)

The entrypoint script runs action inputs through eval: `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` (line 39) and `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"` (line 54). These values come from inputs.actionlint_flags and inputs.reviewdog_flags. Because eval re-parses them as shell code, a value such as `$(cmd)` or `; cmd` runs arbitrary commands with the GitHub token available in the environment.

Locations:

- `entrypoint.sh:39`
- `entrypoint.sh:54`

### unsafe-shell (severity: high)

Remote content is piped straight into a shell: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/08bb2c4f.../scripts/download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. The script should be downloaded to a file, checked, and then run as a separate step.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

Remote content is piped straight into a shell: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. The script should be downloaded to a file, checked, and then run as a separate step.

Locations:

- `scripts/install-reviewdog.sh:17`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unsafe-shell

**Notes:**

- dockerless/action.yml: the Run step now calls the entrypoint with the path in double quotes, as "$ACTION_PATH/../entrypoint.sh".
- entrypoint.sh: removed both `eval "set -- ..."` lines. The actionlint and reviewdog flag inputs are now split by xargs, which respects quotes like upstream's eval but never runs anything. Each input is checked separately: it is skipped if empty, and the script fails if it has an unmatched quote. The flags are passed as `${arr[@]+"${arr[@]}"}`, which works with `set -u` on macOS's bash 3.2.
- The entrypoint's first line changed from #!/bin/sh to #!/bin/bash, because the fix uses bash arrays. The Dockerfile already installs bash (`apk add ... bash`), and the dockerless variant runs on GitHub runners, which have bash.
- install-actionlint.sh and install-reviewdog.sh: each installer is now downloaded to a temporary file first (curl -f, with a check that the file is not empty), then run. I removed the `-s --` from the old piped form, so reviewdog's installer still sees -b as its first argument. Every other argument is the same as upstream.

