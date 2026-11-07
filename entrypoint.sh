#!/bin/bash

set -eu

if [ "${RUNNER_DEBUG:-}" = "1" ] ; then
  set -x
fi

if [ -n "${GITHUB_WORKSPACE}" ] ; then
  cd "${GITHUB_WORKSPACE}" || exit
  git config --global --add safe.directory "${GITHUB_WORKSPACE}" || exit 1
fi

# show versions of tools
echo "::group:: pyflakes version"
pyflakes --version
echo "::endgroup::"

echo "::group:: shellcheck version"
shellcheck --version
echo "::endgroup::"

echo "::group:: actionlint version"
actionlint --version
echo "::endgroup::"

echo "::group:: reviewdog version"
reviewdog --version
echo "::endgroup::"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

actionlint_out="$(mktemp)"
trap 'rm -f "${actionlint_out}"' EXIT

# Split a flags string following shell quoting rules (without evaluating it)
# into the global array SPLIT_ARGS, so that flag values containing spaces
# (e.g. -ignore="foo bar") survive intact.
split_flags() {
  SPLIT_ARGS=()
  if [ -n "$1" ]; then
    printf '%s' "$1" | xargs -r true >/dev/null   # fails on an unmatched quote
    while IFS= read -r -d '' t; do SPLIT_ARGS+=("$t"); done \
      < <(printf '%s' "$1" | xargs -r sh -c 'printf "%s\0" "$@"' sh)
  fi
}

split_flags "${INPUT_ACTIONLINT_FLAGS:-}"
actionlint_args=(${SPLIT_ARGS[@]+"${SPLIT_ARGS[@]}"})

set +e
actionlint -oneline ${actionlint_args[@]+"${actionlint_args[@]}"} > "${actionlint_out}"
actionlint_exit=$?
set -e

# actionlint exit codes: 0=no problem, 1=problems found, 2=invalid command
# line option, 3=fatal error while checking. 2 and 3 are operational
# failures of actionlint itself and must not be swallowed by reviewdog.
if [ "${actionlint_exit}" -ge 2 ]; then
  cat "${actionlint_out}"
  exit "${actionlint_exit}"
fi

# Split INPUT_REVIEWDOG_FLAGS following shell quoting rules (no evaluation) so
# that flag values containing spaces (e.g. -diff="git diff main") survive intact.
split_flags "${INPUT_REVIEWDOG_FLAGS:-}"
reviewdog_args=(${SPLIT_ARGS[@]+"${SPLIT_ARGS[@]}"})

while read -r r; do
  shellcheck_output=" shellcheck reported issue in this script: "
  severity=e

  # Parse the severity if the output is from shellcheck
  if echo "${r}" | grep "${shellcheck_output}"; then
    s="$(echo "${r}" | sed -e "s/^.*${shellcheck_output}[^:]*:\([^:]\).*$/\1/g")"
    if [ "${s}" = 'e' ] || [ "${s}" = 'w' ] || [ "${s}" = 'i' ] || [ "${s}" = 'n' ]; then
      severity="${s}"
    fi
  fi

  echo "${severity}:${r}"
done < "${actionlint_out}" \
    | reviewdog \
        -efm="%t:%f:%l:%c: %m" \
        -name="${INPUT_TOOL_NAME}" \
        -reporter="${INPUT_REPORTER}" \
        -filter-mode="${INPUT_FILTER_MODE}" \
        -fail-level="${INPUT_FAIL_LEVEL}" \
        -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
        -level="${INPUT_LEVEL}" \
        ${reviewdog_args[@]+"${reviewdog_args[@]}"}
exit_code=$?

exit "${exit_code}"
