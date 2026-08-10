<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.73.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.73.0** was hardened automatically. 5 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b): Unquoted shell variable expansion of untrusted data. In entrypoint.sh line 34, `${INPUT_ACTIONLINT_FLAGS}` is expanded without double-quotes. This variable is set from `inputs.actionlint_flags` (an attacker-controllable composite action input) via the env block in dockerless/action.yml. An attacker can inject shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) through this input. The `# shellcheck disable=SC2086` comment confirms the intentional word-splitting, but this does not mitigate the injection risk. Offending line: `actionlint -oneline ${INPUT_ACTIONLINT_FLAGS} | while read -r r; do`

Locations:

- `entrypoint.sh:34`
- `dockerless/action.yml:73`

### script-injection (severity: high)

Sub-rule (b): Unquoted shell variable expansion of untrusted data. In entrypoint.sh line 44, `${INPUT_REVIEWDOG_FLAGS}` is expanded without double-quotes. This variable is set from `inputs.reviewdog_flags` (an attacker-controllable composite action input) via the env block in dockerless/action.yml. An attacker can inject shell metacharacters through this input. Offending line: `        ${INPUT_REVIEWDOG_FLAGS}`

Locations:

- `entrypoint.sh:44`
- `dockerless/action.yml:73`

### script-injection (severity: high)

Sub-rule (b): Unquoted shell variable expansion of a workflow-controllable env var. In dockerless/action.yml, the Run step sets `ACTION_PATH: ${{ github.action_path }}` in its env block and then uses it unquoted in the run command: `run: $ACTION_PATH/../entrypoint.sh`. Per the script-injection rules, any env var holding a `${{ ... }}` expression value must be double-quoted in run blocks. Offending line: `run: $ACTION_PATH/../entrypoint.sh`

Locations:

- `dockerless/action.yml:82`

### unsafe-shell (severity: high)

Remote content is piped directly to bash without first being saved to a file and verified. `curl -sSL https://raw.githubusercontent.com/rhysd/actionlint/.../download-actionlint.bash | bash -s -- "$ACTIONLINT_VERSION"` fetches and immediately executes a remote script. If the remote URL is compromised or subject to a MITM attack, arbitrary code would execute on the runner.

Locations:

- `scripts/install-actionlint.sh:18`

### unsafe-shell (severity: high)

Remote content is piped directly to sh without first being saved to a file and verified. `curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` fetches and immediately executes a remote script. If the remote URL is compromised or subject to a MITM attack, arbitrary code would execute on the runner.

Locations:

- `scripts/install-reviewdog.sh:17`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unsafe-shell

**Notes:**

Fixed 5 findings across 4 files:

1. entrypoint.sh: Changed shebang from #!/bin/sh to #!/bin/bash to support arrays and process substitution. Replaced unquoted ${INPUT_ACTIONLINT_FLAGS} and ${INPUT_REVIEWDOG_FLAGS} with xargs-based array tokenization (guarded by emptiness checks) to safely handle list-type flag inputs without shell injection. Removed the '# shellcheck disable=SC2086' comment that was masking the issue.

2. dockerless/action.yml: Quoted $ACTION_PATH in the run command: changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"`.

3. scripts/install-actionlint.sh: Replaced unsafe `curl ... | bash -s -- "$ACTIONLINT_VERSION"` with download-then-execute pattern: curl to temp file, then `bash "$INSTALL_SCRIPT" "$ACTIONLINT_VERSION"` (dropped '--' which was the shell's option terminator, not the script's argument).

4. scripts/install-reviewdog.sh: Replaced unsafe `curl ... | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` with download-then-execute pattern: curl to temp file, then `sh "$INSTALL_SCRIPT" -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"` (dropped '--' which was the shell's option terminator).

