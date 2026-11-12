<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.84.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.84.1** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b): in dockerless/action.yml, the 'Run' step expands ACTION_PATH without quotes: `run: $ACTION_PATH/../entrypoint.sh`. ACTION_PATH comes from github.action_path, which the workflow controls, so the shell splits it on whitespace and expands globs. Quote it: `"$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `dockerless/action.yml:86`

### script-injection (severity: high)

entrypoint.sh passes action inputs to eval: `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` (line 39) and `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"` (line 54). The values come from inputs.actionlint_flags and inputs.reviewdog_flags. eval reparses them as shell code, so anything like `;`, `$(...)` or backticks in the input runs as a command. That is command injection in both the Docker and the dockerless (composite) action.

Locations:

- `entrypoint.sh:39`
- `entrypoint.sh:54`

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes remote content straight into a shell: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/<sha>/scripts/download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. The URL is pinned to a commit, but nothing checks the script before it runs. Download it to a file, verify it, then run it as a separate step.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes remote content straight into a shell: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/<sha>/install.sh | sh -s -- -b "$INSTALL_DIR" ...`. Download it to a file, verify it, then run it as a separate step.

Locations:

- `scripts/install-reviewdog.sh:17`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unsafe-shell

**Notes:**

I fixed all four findings. Nothing has been run or tested.

- **dockerless/action.yml:** the Run step now quotes the path: `"$ACTION_PATH/../entrypoint.sh"`.
- **entrypoint.sh:** I removed both `eval "set -- ..."` lines. The actionlint_flags and reviewdog_flags inputs are now split with xargs, which still honours quotes as eval did, so a value like `-ignore="foo bar"` stays one argument. Nothing in the value is executed any more. A check runs first (`xargs -r true`) so an unmatched quote stops the script instead of silently dropping arguments. Each list goes into a bash array, and the expansion is written so an empty array also works on macOS's older bash 3.2.
- **Shebang change:** this needs bash, so I changed entrypoint.sh's first line from `#!/bin/sh` to `#!/bin/bash`. The Dockerfile already installs bash (`apk add bash`), and the dockerless version runs on GitHub runners, which have bash.
- **scripts/install-actionlint.sh and scripts/install-reviewdog.sh:** each downloads its installer to a temp file with `curl -f`, then runs it as a separate command. I dropped the `-s --` from the old pipe form, so the arguments reach the installer unchanged: `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"` and `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`.
- **Verification is weak:** it only checks that the file isn't empty and starts with a `#!` line. Neither installer has a published checksum, and I couldn't download them here to work one out. The real protection is still the commit-pinned URLs. Adding a sha256 check would need someone to fetch those two files and record their hashes.

