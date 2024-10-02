#!/usr/bin/env bash

codecov_do_upload_args=""

$CODECOV_SLUG

OLDIFS=$IFS;IFS=,

if [ -n "$CODECOV_BRANCH" ];
then
  codecov_do_upload_args+=" --branch ${CODECOV_BRANCH}"
fi

if [ -n "$CODECOV_BUILD" ];
then
  codecov_do_upload_args+=" --build ${CODECOV_BUILD}"
fi

if [ -n "$CODECOV_BUILD_URL" ];
then
  codecov_do_upload_args+=" --build-url ${CODECOV_BUILD_URL}"
fi

if [ -n "$CODECOV_CODE" ];
then
  codecov_do_upload_args+=" --code ${CODECOV_CODE}"
fi

if [ "$CODECOV_DISABLE_FILE_FIXES" = "true" ];
then
  codecov_do_upload_args+=" --disable-file-fixes"
fi

if [ "$CODECOV_DISABLE_SEARCH" = "true" ];
then
  codecov_do_upload_args+=" --disable-search"
fi

if [ "$CODECOV_DRY_RUN" = "true" ];
then
  codecov_do_upload_args+=" --dry-run"
fi

if [ -n "$CODECOV_ENV" ];
then
  codecov_do_upload_args+=" --env ${CODECOV_ENV}"
fi

if [ -n "$CODECOV_EXCLUDE_DIRS" ];
then
  for directory in $CODECOV_EXCLUDE_DIRS; do
    codecov_do_upload_args+=" --exclude $directory"
  done
fi

if [ "$CODECOV_FAIL_ON_ERROR" = "true" ];
then
  codecov_do_upload_args+=" --fail-on-error"
fi

if [ -n "$CODECOV_FILES" ];
then
  for file in $CODECOV_FILES; do
    codecov_do_upload_args+=" --file $file"
  done
fi

if [ -n "$CODECOV_FLAGS" ];
then
  for flag in $CODECOV_FLAGS; do
    codecov_do_upload_args+=" --flag $flag"
  done
fi

if [ -n "$CODECOV_GIT_SERVICE" ];
then
  codecov_do_upload_args+=" --git-service ${CODECOV_GIT_SERVICE}"
fi

if [ "$CODECOV_HANDLE_NO_REPORTS_FOUND" = "true" ];
then
  codecov_do_upload_args+=" --handle-no-reports-found"
fi

if [ -n "$CODECOV_JOB_CODE" ];
then
  codecov_do_upload_args+=" --job-code ${CODECOV_JOB_CODE}"
fi

if [ "$CODECOV_LEGACY" = "true" ];
then
  codecov_do_upload_args+=" --legacy"
fi

if [ -n "$CODECOV_NAME" ];
then
  codecov_do_upload_args+=" --name ${CODECOV_NAME}"
fi

if [ -n "$CODECOV_NETWORK_FILTER" ];
then
  codecov_do_upload_args+=" --network-filter ${CODECOV_NETWORK_FILTER}"
fi

if [ -n "$CODECOV_NETWORK_PREFIX" ];
then
  codecov_do_upload_args+=" --network-prefix ${CODECOV_NETWORK_PREFIX}"
fi

if [ -n "$CODECOV_NETWORK_ROOT_FOLDER" ];
then
  codecov_do_upload_args+=" --network-root-folder ${CODECOV_NETWORK_ROOT_FOLDER}"
fi

if [ -n "$CODECOV_PLUGINS" ];
then
  for plugin in $CODECOV_PLUGINS; do
    codecov_do_upload_args+=" --plugin $plugin"
  done
fi

if [ -n "$CODECOV_PULL_REQUEST" ];
then
  codecov_do_upload_args+=" --pr ${CODECOV_PULL_REQUEST}"
fi

if [ -n "$CODECOV_REPORT_TYPE" ];
then
  codecov_do_upload_args+=" --report-type ${CODECOV_REPORT_TYPE}"
fi

if [ -n "$CODECOV_SEARCH_DIR" ];
then
  codecov_do_upload_args+=" --coverage-files-search-root-folder ${CODECOV_SEARCH_DIR}"
fi

if [ -n "$CODECOV_SHA" ];
then
  codecov_do_upload_args+=" --sha ${CODECOV_SHA}"
fi

if [ -n "$CODECOV_SLUG" ];
then
  codecov_do_upload_args+=" --slug ${CODECOV_SLUG}"
fi

IFS=$OLDIFS
