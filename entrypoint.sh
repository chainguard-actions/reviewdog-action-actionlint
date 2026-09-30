#!/bin/sh

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

# Tokenize list-style flag inputs safely to avoid shell injection.
# xargs handles quoted values; -n1 emits one token per line.
# We use a temp file so that the while-read loop does not consume stdin.
_al_flags_file=$(mktemp)
_rd_flags_file=$(mktemp)

if [ -n "${INPUT_ACTIONLINT_FLAGS}" ]; then
  printf '%s' "${INPUT_ACTIONLINT_FLAGS}" | xargs -n1 > "$_al_flags_file"
fi
if [ -n "${INPUT_REVIEWDOG_FLAGS}" ]; then
  printf '%s' "${INPUT_REVIEWDOG_FLAGS}" | xargs -n1 > "$_rd_flags_file"
fi

# Build positional parameters for actionlint from the temp file.
set --
while IFS= read -r _t; do
  set -- "$@" "$_t"
done < "$_al_flags_file"
rm -f "$_al_flags_file"

actionlint -oneline "$@" | while read -r r; do
  shellcheck_output=" shellcheck reported issue in this script: "
  severity=e

  # Parse the severity if the output is from shellcheck
  if echo "${r}" | grep "${shellcheck_output}"; then
    s="$(echo "${r}" | sed -e "s/^.*${shellcheck_output}[^:]*:\\([^:]\\).*$/\\1/g")"
    if [ "${s}" = 'e' ] || [ "${s}" = 'w' ] || [ "${s}" = 'i' ] || [ "${s}" = 'n' ]; then
      severity="${s}"
    fi
  fi

  echo "${severity}:${r}"
done \
    | {
        # Build positional parameters for reviewdog from the temp file.
        # The subshell's stdin is the pipe from actionlint; the temp file
        # is a separate file descriptor so stdin is not consumed here.
        set --
        while IFS= read -r _t; do
          set -- "$@" "$_t"
        done < "$_rd_flags_file"
        rm -f "$_rd_flags_file"
        reviewdog \
            -efm="%t:%f:%l:%c: %m" \
            -name="${INPUT_TOOL_NAME}" \
            -reporter="${INPUT_REPORTER}" \
            -filter-mode="${INPUT_FILTER_MODE}" \
            -fail-level="${INPUT_FAIL_LEVEL}" \
            -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
            -level="${INPUT_LEVEL}" \
            "$@"
      }
exit_code=$?

exit $exit_code
