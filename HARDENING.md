<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.80.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.80.5** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

(b) Unquoted expansion of a workflow-controlled env var in the dockerless composite action. The Run step sets ACTION_PATH from ${{ github.action_path }} and then runs `run: $ACTION_PATH/../entrypoint.sh` without quotes. The shell splits the value on whitespace and expands glob characters. It should be quoted: "$ACTION_PATH/../entrypoint.sh".

Locations:

- `dockerless/action.yml:85`

### script-injection (severity: high)

The action's entrypoint passes user-supplied inputs to eval: `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` (line 39) and `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"` (line 54). The values come from inputs.actionlint_flags and inputs.reviewdog_flags. Any `$(...)`, backticks, `;` or `|` in those inputs runs as shell code. INPUT_REVIEWDOG_FLAGS is evaluated after REVIEWDOG_GITHUB_API_TOKEN has been exported, so injected code can read the token. Either split the flags safely without eval, or check them against a strict allowlist first.

Locations:

- `entrypoint.sh:39`
- `entrypoint.sh:54`

### unsafe-shell (severity: high)

Remote content is piped straight into a shell: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/08bb2c4f.../scripts/download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. The dockerless/action.yml install step runs this script. The script should be downloaded to a file, checked, and then run as a separate step.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

Remote content is piped straight into a shell: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74.../install.sh | sh -s -- -b "$INSTALL_DIR" ...`. The dockerless/action.yml install step runs this script. The script should be downloaded to a file, checked, and then run as a separate step.

Locations:

- `scripts/install-reviewdog.sh:17`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unsafe-shell

**Notes:**

I fixed all four findings by editing the files below. Nothing has been run or tested yet.

- **dockerless/action.yml:** the Run step now quotes the path, so `run: '"$ACTION_PATH/../entrypoint.sh"'` won't split on spaces or expand glob characters.
- **entrypoint.sh (`eval` on the flags):** `actionlint_flags` and `reviewdog_flags` are no longer evaluated as shell code. Each input is split into words by `xargs`, which still honours quotes, so `-ignore="foo bar"` stays one argument. A small `sh -c` helper then wraps each word in single quotes. The `eval "set -- ..."` now only sees those quoted words, so `$(...)`, backticks, `;` and `|` in an input reach the tool as plain text. Both inputs are split before the actionlint run. As a result, an unmatched quote in either one stops the script with an error before actionlint starts.
  - The script stays plain POSIX `sh` with no bash-only syntax. The Docker image is Alpine, and its entrypoint runs under `/bin/sh`.
  - Two small differences from the old `eval`: shell-style escapes and `$VAR` references in the inputs are no longer expanded, and quotes are handled by `xargs`'s rules rather than the shell's.
- **scripts/install-actionlint.sh and scripts/install-reviewdog.sh:** each installer is now saved to a temp file with `curl -fsSL -o`, which fails on HTTP errors. The script stops if the file is empty, then runs it with the same arguments as before (`bash "$f" "$ACTIONLINT_VERSION"`, `sh "$f" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`), minus the `-s --` that only made sense when piping. The temp file is deleted on exit.
  - The only check is that the download isn't empty; the file's contents aren't verified. The installer URLs were already pinned to fixed commits, which is the main protection.

