#!/usr/bin/env bash

if [ -n "$CODECOV_REPORT_TYPE" ];
then
  CODECOV_ARGS+=( "--report-type" "$CODECOV_REPORT_TYPE" )
fi

CODECOV_ARGS+=( $(k_arg BASE_SHA) $(v_arg BASE_SHA))
CODECOV_ARGS+=( $(k_arg BINARY) $(v_arg BINARY))
CODECOV_ARGS+=( $(k_arg PARENT_SHA) $(v_arg PARENT_SHA))
CODECOV_ARGS+=( $(k_arg DIR) $(v_arg DIR))
CODECOV_ARGS+=( $(write_bool_args CODECOV_DISABLE_SEARCH) )
CODECOV_ARGS+=( $(write_bool_args CODECOV_DISABLE_SAFE_DIRECTORY) )
CODECOV_ARGS+=( $(write_bool_args CODECOV_DRY_RUN) )

if [ -n "$CODECOV_EXCLUDES" ];
then
  for directory in $CODECOV_EXCLUDES; do
    CODECOV_ARGS+=( "--exclude" "$directory" )
  done
fi

CODECOV_ARGS+=( $(write_bool_args CODECOV_FAIL_ON_ERROR) )

if [ -n "$CODECOV_FILES" ];
then
  for file in $CODECOV_FILES; do
    CODECOV_ARGS+=( "--file" "$file" )
  done
fi

CODECOV_ARGS+=( $(write_bool_args CODECOV_FORCE) )
CODECOV_ARGS+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
CODECOV_ARGS+=( $(write_bool_args CODECOV_HANDLE_NO_REPORTS_FOUND) )
CODECOV_ARGS+=( $(k_arg NAME) $(v_arg NAME) )
CODECOV_ARGS+=( $(k_arg NETWORK_FILTER) $(v_arg NETWORK_FILTER))
CODECOV_ARGS+=( $(k_arg NETWORK_PREFIX) $(v_arg NETWORK_PREFIX))
CODECOV_ARGS+=( $(k_arg NETWORK_ROOT_FOLDER) $(v_arg NETWORK_ROOT_FOLDER))
CODECOV_ARGS+=( $(k_arg OS) $(v_arg OS))
CODECOV_ARGS+=( $(k_arg BRANCH) $(v_arg BRANCH))
CODECOV_ARGS+=( $(k_arg BUILD) $(v_arg BUILD))
CODECOV_ARGS+=( $(k_arg BUILD_URL) $(v_arg BUILD_URL))
CODECOV_ARGS+=( $(k_arg SHA) $(v_arg SHA))
CODECOV_ARGS+=( $(k_arg PR) $(v_arg PR))
CODECOV_ARGS+=( $(write_bool_args CODECOV_RECURSE_SUBMODULES) )
CODECOV_ARGS+=( $(write_bool_args CODECOV_SKIP_VALIDATION) )
CODECOV_ARGS+=( $(k_arg SLUG) $(v_arg SLUG))
CODECOV_ARGS+=( $(write_bool_args CODECOV_USE_PYPI) )
CODECOV_ARGS+=( $(k_arg VERSION) $(v_arg VERSION))
