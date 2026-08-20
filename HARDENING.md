<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint/v1.72.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint/v1.72.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The action.yml Docker image reference uses a mutable version tag (`v1.72.0`) instead of an immutable SHA digest. This means the image could be silently replaced with a different (potentially malicious) version without any change to the action definition, creating a supply-chain attack vector. The failing reference is: `image: 'docker://ghcr.io/reviewdog/action-actionlint:v1.72.0'`. It should be replaced with a SHA-pinned reference such as `image: 'docker://ghcr.io/reviewdog/action-actionlint@sha256:<64-hex-char-digest>'`.

Locations:

- `action.yml:56`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses

**Notes:**

Pinned the Docker image reference in action.yml from `docker://ghcr.io/reviewdog/action-actionlint:v1.72.0` to `docker://ghcr.io/reviewdog/action-actionlint:v1.72.0@sha256:918481e3b42182d1671c5807d57ed356203e11e96fa679f4f9a8a7b5a65152d9`. The `docker://` scheme and `:v1.72.0` tag are preserved inline, with the immutable SHA digest appended to prevent supply-chain attacks via mutable tag replacement.

