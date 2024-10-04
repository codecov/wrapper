#!/usr/bin/env bash

codecov_du_args=()

OLDIFS=$IFS;IFS=,

codecov_du_args+=( $(write_existing_args CODECOV_BRANCH) )
codecov_du_args+=( $(write_existing_args CODECOV_BUILD) )
codecov_du_args+=( $(write_existing_args CODECOV_BUILD_URL) )
codecov_du_args+=( $(write_existing_args CODECOV_CODE) )
codecov_du_args+=( $(write_existing_args CODECOV_DIR) )
codecov_du_args+=( $(write_truthy_args CODECOV_DISABLE_FILE_FIXES) )
codecov_du_args+=( $(write_truthy_args CODECOV_DISABLE_SEARCH) )
codecov_du_args+=( $(write_truthy_args CODECOV_DRY_RUN) )
codecov_du_args+=( $(write_existing_args CODECOV_ENV) )

if [ -n "$CODECOV_EXCLUDES" ];
then
  for directory in $CODECOV_EXCLUDES; do
    codecov_du_args+=( " --exclude " "$directory" )
  done
fi

codecov_du_args+=( $(write_truthy_args CODECOV_FAIL_ON_ERROR) )

if [ -n "$CODECOV_FILES" ];
then
  for file in $CODECOV_FILES; do
    codecov_du_args+=( " --file " "$file" )
  done
fi

if [ -n "$CODECOV_FLAGS" ];
then
  for flag in $CODECOV_FLAGS; do
    codecov_du_args+=( " --flag " "$flag" )
  done
fi

codecov_du_args+=( $(write_existing_args CODECOV_GIT_SERVICE) )
codecov_du_args+=( $(write_truthy_args CODECOV_HANDLE_NO_REPORTS_FOUND) )
codecov_du_args+=( $(write_existing_args CODECOV_JOB_CODE) )
codecov_du_args+=( $(write_truthy_args CODECOV_LEGACY) )
codecov_du_args+=( $(write_existing_args CODECOV_NAME) )
codecov_du_args+=( $(write_existing_args CODECOV_NETWORK_FILTER) )
codecov_du_args+=( $(write_existing_args CODECOV_NETWORK_PREFIX) )
codecov_du_args+=( $(write_existing_args CODECOV_NETWORK_ROOT_FOLDER) )

if [ -n "$CODECOV_PLUGINS" ];
then
  for plugin in $CODECOV_PLUGINS; do
    codecov_du_args+=( " --plugin " "$plugin" )
  done
fi

codecov_du_args+=( $(write_existing_args CODECOV_PR) )
codecov_du_args+=( $(write_existing_args CODECOV_REPORT_TYPE) )
codecov_du_args+=( $(write_existing_args CODECOV_SHA) )
codecov_du_args+=( $(write_existing_args CODECOV_SLUG) )

IFS=$OLDIFS
