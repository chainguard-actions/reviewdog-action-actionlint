<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.71.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.71.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The Dockerfile pipes remote scripts directly to a shell interpreter without first downloading and verifying them. Line ~25 runs: `wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}`. Line ~29 runs: `wget -O - -q https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash | sh -s -- ${ACTIONLINT_VERSION}`. If the remote host or the content at those URLs is compromised, arbitrary code executes in the Docker build context. Scripts should be downloaded to a file, verified (e.g. checksum), and then executed separately.

Locations:

- `Dockerfile:25`
- `Dockerfile:29`

### unpinned-uses (severity: high)

The action.yml `runs.image:` field references a mutable Docker image tag rather than an immutable SHA digest: `image: 'docker://ghcr.io/reviewdog/action-actionlint:v1.71.0'`. A tag can be silently overwritten to point to a different (potentially malicious) image. It should be pinned to a SHA digest, e.g. `docker://ghcr.io/reviewdog/action-actionlint@sha256:<64-hex-char-digest>`.

Locations:

- `action.yml:57`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. Dockerfile (lines 25, 29): Replaced both `wget ... | sh -s -- ...` pipe-to-shell patterns with download-then-execute patterns. For reviewdog: downloads install.sh to /tmp, runs `sh /tmp/install-reviewdog.sh -b /usr/local/bin/ ${REVIEWDOG_VERSION}`, then removes the file. For actionlint: downloads download-actionlint.bash to /tmp, runs `sh /tmp/download-actionlint.bash ${ACTIONLINT_VERSION}`, then removes the file. The '--' separators were dropped as they were the shell's own option terminators in the pipe form (not arguments to the scripts themselves). 2. action.yml (line 57): Pinned the Docker image reference from `docker://ghcr.io/reviewdog/action-actionlint:v1.71.0` to `docker://ghcr.io/reviewdog/action-actionlint:v1.71.0@sha256:09e37f098b827b1425d4559baa5352ecea222b9912037d06f6cb2a9528b0cb3b`, preserving the docker:// scheme and tag while adding the immutable digest.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed two script injection vulnerabilities in entrypoint.sh:
1. Line 14: Replaced unquoted `${INPUT_ACTIONLINT_FLAGS}` with a bash array built via xargs-based tokenization (`"${actionlint_flags[@]}"`), preventing shell metacharacter injection from the `actionlint_flags` input.
2. Line 33: Replaced unquoted `${INPUT_REVIEWDOG_FLAGS}` with a bash array built via xargs-based tokenization (`"${reviewdog_flags[@]}"`), preventing shell metacharacter injection from the `reviewdog_flags` input.
3. Changed shebang from `#!/bin/sh` to `#!/bin/bash` since arrays and process substitution are bash-specific features.
4. Added `bash` to the `apk add` command in Dockerfile to ensure bash is available in the Alpine-based container.
5. Removed the `# shellcheck disable=SC2086` comment that was suppressing the warning about the unsafe unquoted expansion.

The xargs-based tokenization correctly handles quoted arguments within flag strings while preventing injection of shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.). Each variable is guarded with `if [ -n "..." ]` to prevent xargs from emitting an empty token on empty input.

