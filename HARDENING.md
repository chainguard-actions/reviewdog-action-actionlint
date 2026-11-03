<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.73.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.73.1** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b) failed: an unquoted shell variable holds workflow-controllable data. In the dockerless composite action's 'Run' step, ACTION_PATH is set from ${{ github.action_path }} and expanded without quotes: `run: $ACTION_PATH/../entrypoint.sh`. If the path contains whitespace or glob characters, the shell splits or expands it. Fix: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `dockerless/action.yml:85`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

dockerless/action.yml: changed run to '"$ACTION_PATH/../entrypoint.sh"' (YAML single-quoted so the shell receives the double-quoted path).

### Iteration 2

**Fixes applied:** unsafe-shell

**Notes:**

I changed both install scripts so they stop piping a remote script into a shell. Each one now downloads the script to a temp file first. It uses curl -f, so an HTTP error stops the install. The script is then checked and run as a separate step, and the temp file is deleted when the script exits. I haven't run either script after the change.

The check is weak: it only confirms the file isn't empty and starts with '#!'. That catches a failed or truncated download but wouldn't catch altered content. I didn't add a checksum because I couldn't download the files to get their real hashes, and I wasn't going to guess them. The URLs are still pinned to specific commits. For a real integrity check, add a sha256 comparison against a hash taken from the files at those commits.

- **install-actionlint.sh:** runs `bash "$DOWNLOAD_SCRIPT" "$ACTIONLINT_VERSION"` from inside INSTALL_DIR, as before, because the upstream script downloads into the current directory. The temp file is created outside INSTALL_DIR so it doesn't land in a directory that's on PATH.
- **install-reviewdog.sh:** runs `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`.

In both, I removed the `-s --` from the old pipe form, so each installer still gets its arguments in the same order, starting at $1.

