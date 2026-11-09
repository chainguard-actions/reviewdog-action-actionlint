<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.75.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.75.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b): in the dockerless composite action's 'Run' step, the env var ACTION_PATH (set from ${{ github.action_path }}) is expanded without quotes as the command path: `run: $ACTION_PATH/../entrypoint.sh`. Quote it: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `dockerless/action.yml:85`

### unsafe-shell (severity: high)

Remote content is piped straight into a shell: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/08bb2c4f.../scripts/download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. Download the script to a file first, check it, then run it.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

Remote content is piped straight into a shell: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. Download the script to a file first, check it, then run it.

Locations:

- `scripts/install-reviewdog.sh:17`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unsafe-shell

**Notes:**

I fixed all three findings, but I haven't run anything to test the changes.

- **`dockerless/action.yml` (script-injection):** the Run step now quotes the path it runs: `"$ACTION_PATH/../entrypoint.sh"`.
- **`scripts/install-actionlint.sh` (unsafe-shell):** the installer is downloaded to a temp file first. The script stops if the download fails or the file is empty, and deletes the file when it exits. It then runs `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"`. I dropped the `-s --` that only made sense when the script came in through the pipe. The script still changes into the install directory before running the installer, because the installer saves actionlint into the current directory.
- **`scripts/install-reviewdog.sh` (unsafe-shell):** same download-then-run pattern, followed by `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`, again without the `-s --`.

One behaviour change: both downloads now use `curl -f`, so a failed download (such as a 404) stops the step with an error. Before, curl would hand the error page to the shell instead.

