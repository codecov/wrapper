#!/usr/bin/env bash

codecov_run_args=()

# Args for create commit
codecov_run_args+=( $(write_truthy_args CODECOV_FAIL_ON_ERROR) )
codecov_run_args+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
codecov_run_args+=( $(k_arg PARENT_SHA) $(v_arg PARENT_SHA))
codecov_run_args+=( $(k_arg PR) $(v_arg PR))
codecov_run_args+=( $(k_arg SHA) $(v_arg SHA))
codecov_run_args+=( $(k_arg SLUG) $(v_arg SLUG))

# Args for create report
codecov_run_args+=( $(k_arg CODE) $(v_arg CODE))

# Args for do upload
codecov_run_args+=( $(k_arg ENV) $(v_arg ENV))

OLDIFS=$IFS;IFS=,

codecov_run_args+=( $(k_arg BRANCH) $(v_arg BRANCH))
codecov_run_args+=( $(k_arg BUILD) $(v_arg BUILD))
codecov_run_args+=( $(k_arg BUILD_URL) $(v_arg BUILD_URL))
codecov_run_args+=( $(k_arg DIR) $(v_arg DIR))
codecov_run_args+=( $(write_truthy_args CODECOV_DISABLE_FILE_FIXES) )
codecov_run_args+=( $(write_truthy_args CODECOV_DISABLE_SEARCH) )
codecov_run_args+=( $(write_truthy_args CODECOV_DRY_RUN) )

if [ -n "$CODECOV_EXCLUDES" ];
then
  for directory in $CODECOV_EXCLUDES; do
    codecov_run_args+=( "--exclude" "$directory" )
  done
fi

if [ -n "$CODECOV_FILES" ];
then
  for file in $CODECOV_FILES; do
    codecov_run_args+=( "--file" "$file" )
  done
fi

if [ -n "$CODECOV_FLAGS" ];
then
  for flag in $CODECOV_FLAGS; do
    codecov_run_args+=( "--flag" "$flag" )
  done
fi

codecov_run_args+=( $(k_arg GCOV_ARGS) $(v_arg GCOV_ARGS))
codecov_run_args+=( $(k_arg GCOV_EXECUTABLE) $(v_arg GCOV_EXECUTABLE))
codecov_run_args+=( $(k_arg GCOV_IGNORE) $(v_arg GCOV_IGNORE))
codecov_run_args+=( $(k_arg GCOV_INCLUDE) $(v_arg GCOV_INCLUDE))
codecov_run_args+=( $(write_truthy_args CODECOV_HANDLE_NO_REPORTS_FOUND) )
codecov_run_args+=( $(k_arg JOB_CODE) $(v_arg JOB_CODE))
codecov_run_args+=( $(write_truthy_args CODECOV_LEGACY) )
if [ -n "$CODECOV_NAME" ];
then
  codecov_run_args+=( "--name" "$CODECOV_NAME" )
fi
codecov_run_args+=( $(k_arg NETWORK_FILTER) $(v_arg NETWORK_FILTER))
codecov_run_args+=( $(k_arg NETWORK_PREFIX) $(v_arg NETWORK_PREFIX))
codecov_run_args+=( $(k_arg NETWORK_ROOT_FOLDER) $(v_arg NETWORK_ROOT_FOLDER))

if [ -n "$CODECOV_PLUGINS" ];
then
  for plugin in $CODECOV_PLUGINS; do
    codecov_run_args+=( "--plugin" "$plugin" )
  done
fi

codecov_run_args+=( $(k_arg REPORT_TYPE) $(v_arg REPORT_TYPE))
codecov_run_args+=( $(k_arg SWIFT_PROJECT) $(v_arg SWIFT_PROJECT))

IFS=$OLDIFS
