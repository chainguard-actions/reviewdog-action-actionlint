<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.81.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.81.0** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

entrypoint.sh runs caller-controlled inputs through eval: `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` (line 39) and `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"` (line 54). These values come from inputs.actionlint_flags and inputs.reviewdog_flags, so shell metacharacters such as $(...) or ; in them run as commands.

Locations:

- `entrypoint.sh:39`
- `entrypoint.sh:54`

### script-injection (severity: high)

Sub-rule (b): in dockerless/action.yml, the Run step expands an env var unquoted. The line is `run: $ACTION_PATH/../entrypoint.sh`, and ACTION_PATH is set from github.action_path. It should be quoted.

Locations:

- `dockerless/action.yml:85`

### unsafe-shell (severity: high)

scripts/install-actionlint.sh pipes downloaded content straight into a shell: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/.../download-actionlint.bash | bash -s -- ...`.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

scripts/install-reviewdog.sh pipes downloaded content straight into a shell: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- ...`.

Locations:

- `scripts/install-reviewdog.sh:17`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unsafe-shell

**Notes:**

Fixed all four findings. I have not run the action or any tests, so none of these changes has been tested.

1. **entrypoint.sh (eval of the two flag inputs):** Both `eval "set -- ..."` lines are gone. A new `split_flags` function splits each flag input using shell quoting rules but runs nothing in it. It uses `xargs -r`: one check first rejects an unmatched quote, then the tokens are printed one per line by the shell's built-in printf. The script reads those lines back into the positional parameters with `set -- "$@" "$t"`.
   - **Still plain POSIX sh:** I kept the `#!/bin/sh` shebang and used no bash-only syntax (busybox xargs supports `-r`).
   - **Same results:** quoted values like `-ignore="foo bar"` still come through as one argument, and an empty input gives no arguments.
   - **One behaviour change:** the actionlint flags are now split before `set +e`, so a malformed value (an unmatched quote) stops the script with an error. It is no longer silently ignored.
   - **One limitation:** a flag value containing a line break inside quotes would not survive the split. I think that is very unlikely in practice.

2. **dockerless/action.yml:** The Run step now quotes the path: `"$ACTION_PATH/../entrypoint.sh"`.

3. **scripts/install-actionlint.sh:** The installer is now downloaded to a temporary file with `curl -sSfL` and then run with `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"`. The `-s --` from the piped version is dropped, and a trap deletes the file afterwards.

4. **scripts/install-reviewdog.sh:** Same change: download to a temporary file, then run `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`, with no `-s --` and a trap to delete the file. Adding `-f` to curl in both scripts means a failed download now stops the install instead of running an error page.

