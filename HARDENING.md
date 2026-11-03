<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.73.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.73.2** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b), unquoted variable expansion. In the 'Run' step of the composite action, the env var ACTION_PATH (set from ${{ github.action_path }}) is expanded without quotes: `run: $ACTION_PATH/../entrypoint.sh`. Without quotes, the shell splits the value on whitespace and expands glob characters. Fix: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `dockerless/action.yml:82`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Quoted $ACTION_PATH in dockerless/action.yml Run step: run: '"$ACTION_PATH/../entrypoint.sh"' (YAML single-quoted so the shell receives the double-quoted path). Shell is bash, so the syntax is valid.

### Iteration 2

**Fixes applied:** unsafe-shell

**Notes:**

Partial fix: both installers no longer pipe a download straight into a shell, but neither checks a checksum, which the finding asked for. I had no way to fetch the commit-pinned scripts and compute their real SHA-256 values, and I wasn't going to guess them. The next analysis pass may raise this again.

What changed in install-actionlint.sh and install-reviewdog.sh:
- Each script now downloads to a temp file with curl -sSfL (-f makes a failed download stop the script).
- A check stops the script if the file is empty or doesn't start with a '#!' line.
- The file is then run with exactly the arguments upstream passed: 'bash "$f" "$ACTIONLINT_VERSION"' (still run from inside INSTALL_DIR) and 'sh "$f" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"'. I dropped the '-s --' from the old pipe form so the version and '-b' still arrive as the scripts' first argument.
- A trap deletes the temp file when the script exits.

Nothing has been run yet, including the Dockerfile build that also uses these scripts.

To finish the fix, add a sha256sum check against known digests of the two pinned files. Compute them from the pinned URLs before publishing.

