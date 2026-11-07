<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.83.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.83.0** was hardened automatically. 5 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

(b) In the composite 'Run' step, the env var ACTION_PATH (set from github.action_path) is expanded without quotes: `run: $ACTION_PATH/../entrypoint.sh`. It should be `"$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `dockerless/action.yml:85`

### script-injection (severity: high)

The entrypoint script runs a workflow-controlled input through eval: `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"`. The value comes from inputs.actionlint_flags, so shell metacharacters such as $(...), ; or backticks in it run as commands.

Locations:

- `entrypoint.sh:39`

### script-injection (severity: high)

The entrypoint script runs a workflow-controlled input through eval: `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"`. The value comes from inputs.reviewdog_flags, so this allows arbitrary command execution.

Locations:

- `entrypoint.sh:54`

### unsafe-shell (severity: high)

Remote content is piped straight into a shell: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/08bb2c4f.../scripts/download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. The script should be downloaded to a file, checked, and then run.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

Remote content is piped straight into a shell: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74.../install.sh | sh -s -- -b "$INSTALL_DIR" ...`. The script should be downloaded to a file, checked, and then run.

Locations:

- `scripts/install-reviewdog.sh:17`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unsafe-shell

**Notes:**

dockerless/action.yml: the Run step now executes '"$ACTION_PATH/../entrypoint.sh"', with the path quoted. entrypoint.sh: removed both `eval "set -- ..."` calls. A POSIX-sh helper, split_flags, now splits the flags quote-aware with xargs without evaluating anything. It first runs 'xargs -r true' so an unmatched quote fails the script. It then writes one token per line to a temp file, and set -- rebuilds the positional args from that file. The shebang is still /bin/sh and no arrays are used. Quoted flag values like -ignore="foo bar" still come through as a single argument. scripts/install-actionlint.sh and scripts/install-reviewdog.sh: each installer is now downloaded to a mktemp file with 'curl -f', checked to be non-empty, and then run. The '-s --' was dropped, so the arguments reach the scripts unchanged (bash script VERSION; sh script -b DIR vVERSION).

