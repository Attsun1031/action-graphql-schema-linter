#!/bin/sh
set -e

cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit
echo "$(pwd)"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

echo '::group:: Installing graphql-schema-linter ...  https://github.com/cjoudrey/graphql-schema-linter'
npm install graphql-schema-linter@"${INPUT_GRAPHQL_SCHEMA_LINTER_VERSION}"
"$(npm root)"/.bin/graphql-schema-linter --version
echo '::endgroup::'

# shellcheck disable=SC2086
"$(npm root)"/.bin/graphql-schema-linter "${INPUT_GRAPHQL_SCHEMA_LINTER_FLAGS}" \
  | reviewdog -efm="%f:%l:%c: %m" \
      -name="graphql-schema-linter" \
      -reporter="${INPUT_REPORTER:-github-pr-check}" \
      -filter-mode="${INPUT_FILTER_MODE}" \
      -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
      -level="${INPUT_LEVEL}" \
      ${INPUT_REVIEWDOG_FLAGS}
