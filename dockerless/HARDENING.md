<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-actionlint--dockerless/v1.78.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-actionlint--dockerless/v1.78.0** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b) violation: In the 'Run' step, the env var `ACTION_PATH` is set from `${{ github.action_path }}` (a github.* context value) and then used unquoted in the `run:` block as `run: $ACTION_PATH/../entrypoint.sh`. The shell expansion of `$ACTION_PATH` is unquoted, which allows shell metacharacters in the value to be interpreted by the shell. The fix is to quote the expansion: `run: "$ACTION_PATH/../entrypoint.sh"`.

Locations:

- `action.yml:85`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted shell variable expansion in action.yml at line 85. Changed `run: $ACTION_PATH/../entrypoint.sh` to `run: "$ACTION_PATH/../entrypoint.sh"` to properly quote the ACTION_PATH variable (which is set from `${{ github.action_path }}`). This prevents shell metacharacters in the value from being interpreted by the shell.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Removed the `ACTION_PATH` env var (which was set from `${{ github.action_path }}`) from the 'Run' step's env block, and replaced its usage in the `run:` command with `$GITHUB_ACTION_PATH` — the pre-set GitHub Actions environment variable provided by the runner. This eliminates the script-injection risk since `$GITHUB_ACTION_PATH` is not derived from a `${{ ... }}` expression and is already properly quoted in the run command.

