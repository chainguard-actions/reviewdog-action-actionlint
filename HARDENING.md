<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.80.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.80.6** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

The entrypoint script passes action inputs to eval. Line 39 has `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` and line 54 has `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"`. Both values come from the inputs actionlint_flags and reviewdog_flags. Because eval runs the string through the shell, a value like `$(cmd)`, backticks or `;` in either input would run as a command. This happens in both the Docker action and the dockerless composite action.

Locations:

- `entrypoint.sh:39`
- `entrypoint.sh:54`

### script-injection (severity: high)

Rule (b), unquoted expansion: in the composite step 'Run', the line `run: $ACTION_PATH/../entrypoint.sh` expands ACTION_PATH without double quotes. ACTION_PATH is set from `${{ github.action_path }}`. Quote it: `"$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `dockerless/action.yml:85`

### unsafe-shell (severity: high)

This script pipes a remote download straight into a shell: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/08bb2c4f.../scripts/download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. The dockerless action and the Dockerfile both run this script. Download the file first, check its checksum, then run it.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

This script pipes a remote download straight into a shell: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74.../install.sh | sh -s -- -b "$INSTALL_DIR" ...`. The dockerless action and the Dockerfile both run this script. Download the file first, check its checksum, then run it.

Locations:

- `scripts/install-reviewdog.sh:17`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unsafe-shell

**Notes:**

I fixed all four findings. Nothing was run, and I couldn't compute the checksums the finding asked for (see the last point).

- **entrypoint.sh (`eval`)**: both `eval "set -- ..."` lines are gone. A new POSIX-sh helper, `split_flags`, splits each flag string with `xargs`, which still honours quotes. `-ignore="foo bar"` stays one argument, as before. `$(...)`, backticks and `;` now reach actionlint or reviewdog as plain text and are never run. If a flag string has an unmatched quote, the helper prints an error and the step fails. An empty input adds no arguments. The tokens are read back into `set --` with a here-doc loop, so the script stays `#!/bin/sh` with no arrays. One difference from `eval`: a single flag value that contains a newline would now be split into two arguments.
- **dockerless/action.yml**: the Run step now quotes the path: `"$ACTION_PATH/../entrypoint.sh"`.
- **install-actionlint.sh / install-reviewdog.sh**: each installer is now downloaded to a temp file (`curl -f`, so HTTP errors fail the script), checked to be non-empty, then run with the same arguments as before. I dropped the `-s --` from the old pipe form, so the scripts still get their arguments starting at `$1`.
- **Checksums not added**: there's no hash check because I couldn't fetch the scripts to compute one, and a made-up value would break every install. Both URLs point at a fixed commit, which limits what can change, but a real checksum still needs to be added by someone who can download the files.

