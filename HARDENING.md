<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.81.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.81.1** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b), unquoted variable expansion. In dockerless/action.yml the 'Run' step has `run: $ACTION_PATH/../entrypoint.sh`. ACTION_PATH comes from `${{ github.action_path }}`, a workflow-controllable context, and is expanded without double quotes, so the shell splits it on whitespace and expands glob characters. Quote it: `"$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `dockerless/action.yml:90`

### script-injection (severity: high)

entrypoint.sh passes action inputs to eval: `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` (line 39) and `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"` (line 54). Both values come from inputs.actionlint_flags and inputs.reviewdog_flags, which the caller sets. Through eval, any shell metacharacters in them, such as `$(...)`, backticks or `;`, run as commands, and REVIEWDOG_GITHUB_API_TOKEN is already exported in that environment. This is the entrypoint-eval case the scope rules say to report for both the Docker and the composite (dockerless) variants. Split the flags without eval, for example `set -- $VAR` with globbing turned off (set -f), or pass each flag as its own input.

Locations:

- `entrypoint.sh:39`
- `entrypoint.sh:54`

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes remote content straight into a shell: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/08bb2c4f.../scripts/download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. The URL pins a commit, but the script still runs without being saved or checked first. It also comes from a third-party fork (kjanat), not the upstream rhysd/actionlint. Download it to a file, verify a checksum, then run it.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes remote content straight into a shell: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. Download it to a file, verify a checksum, then run it.

Locations:

- `scripts/install-reviewdog.sh:17`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unsafe-shell

**Notes:**

Nothing was run or tested. The checksum step the findings asked for is not added: I could not download the installer scripts to get their hashes.

- dockerless/action.yml: the Run step now quotes the path: "$ACTION_PATH/../entrypoint.sh".
- entrypoint.sh: both `eval "set -- $FLAGS"` lines are gone. A new POSIX-sh helper, split_flags, splits the flags the same quote-aware way, so values like -ignore="foo bar" stay one argument, but nothing in them is run (no $(...), backticks or ;). It uses xargs to split the value and puts one flag per line. It checks for an unmatched quote first and fails if it finds one, and an empty input produces no arguments. The result goes into set -- with globbing off and IFS set to newline. The script stays /bin/sh, so it works in the Alpine image.
  - Small behaviour change: an empty flag like "" is now dropped instead of being passed as an empty argument.
- scripts/install-actionlint.sh and scripts/install-reviewdog.sh: the installer is now saved to a temp file with curl -sSfL. The script fails if the download fails or the file is empty, then runs it with the same arguments as before. The `-s --` from the piped form was dropped, so the arguments still start at $1. The URLs still point to fixed commits.
  - Possible follow-up: the actionlint installer still comes from the kjanat fork, not rhysd/actionlint. I left the source alone because ACTIONLINT_VERSION=1.17.0 seems to be tied to that fork, and switching could break the install.

