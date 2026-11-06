<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.81.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.81.0** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

(b) The Run step in dockerless/action.yml has an unquoted expansion of an env var set from github.action_path: `run: $ACTION_PATH/../entrypoint.sh`. It should be `"$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `dockerless/action.yml:85`

### script-injection (severity: high)

The entrypoint script runs input-derived values through eval: `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` (line 39) and `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"` (line 54). These values come from inputs.actionlint_flags and inputs.reviewdog_flags. If either contains shell metacharacters such as $(...), backticks or ;, the code runs with access to REVIEWDOG_GITHUB_API_TOKEN.

Locations:

- `entrypoint.sh:39`
- `entrypoint.sh:54`

### unsafe-shell (severity: high)

A remote script is piped straight into a shell: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/08bb2c4.../scripts/download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. The commit-pinned URL comes from a third-party fork.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

A remote script is piped straight into a shell: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed7.../install.sh | sh -s -- -b "$INSTALL_DIR" ...`.

Locations:

- `scripts/install-reviewdog.sh:17`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unsafe-shell

**Notes:**

- dockerless/action.yml: the Run step now quotes the path: run: '"$ACTION_PATH/../entrypoint.sh"'.
- entrypoint.sh: removed both `eval "set -- ..."` lines. actionlint_flags and reviewdog_flags are now split into bash arrays with the quote-aware xargs method, so quoted values such as -ignore="foo bar" still arrive as one argument but nothing in them is run. Each split is skipped when its input is empty. An unmatched quote now stops the script early. The arrays are expanded as ${arr[@]+"${arr[@]}"} so the empty case also works under set -u on bash 3.2. reviewdog still reads its input on stdin. The shebang is now #!/bin/bash because the script uses arrays; the Dockerfile installs bash and runners have it. The docker action (action.yml) runs a prebuilt image, so this change only takes effect for the dockerless action or a rebuilt image.
- scripts/install-actionlint.sh and scripts/install-reviewdog.sh: each remote script is now downloaded to a temp file with curl -f, the script stops if the file is empty, then it runs as a separate command. The `-s --` from the piped form is dropped, so the arguments reach the script as before: `bash "$DOWNLOAD_SCRIPT" "$ACTIONLINT_VERSION"` and `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`.
- Not fixed: the actionlint download script still comes from the third-party fork kjanat/actionlint at the same pinned commit, as upstream had it. I couldn't find a matching official script to switch to (rhysd/actionlint has no version 1.17.0), and there is no known checksum, so the download is not verified.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

entrypoint.sh: I removed the bash arrays (actionlint_args, reviewdog_args), the process substitution and the array expansions, none of which work in POSIX sh. The flags now go back to upstream's form: actionlint -oneline ${INPUT_ACTIONLINT_FLAGS:-} and ${INPUT_REVIEWDOG_FLAGS:-} on the reviewdog call. These come in as environment variables and are left unquoted on purpose, so the shell splits them on whitespace and nothing in them gets run. That makes them safe from injection, and it keeps upstream's behaviour. reviewdog still reads actionlint's output from stdin. I left the shebang, the Dockerfile and action.yml unchanged.

