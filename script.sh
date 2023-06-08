#!/bin/sh
set -e

if [ -n "${GITHUB_WORKSPACE}" ] ; then
  cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit
  git config --global --add safe.directory "${GITHUB_WORKSPACE}" || exit 1
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
echo '::endgroup::'

echo '::group:: Installing graphql-schema-linter ...  https://github.com/cjoudrey/graphql-schema-linter'
npm install graphql-schema-linter:"${INPUT_GRAPHQL_SCHEMA_LINTER_VERSION}" --global
graphql-schema-linter --version
echo '::endgroup::'


graphql-schema-linter "${INPUT_GRAPHQL_SCHEMA_LINTER_FLAGS}" \
  | reviewdog -efm="%f:%l:%c: %m" \
      -name="graphql-schema-linter" \
      -reporter="${INPUT_REPORTER:-github-pr-check}" \
      -filter-mode="${INPUT_FILTER_MODE}" \
      -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
      -level="${INPUT_LEVEL}" \
      ${INPUT_REVIEWDOG_FLAGS}
