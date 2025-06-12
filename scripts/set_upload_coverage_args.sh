#!/bin/sh

add_arg "$(write_bool_args CODECOV_FAIL_ON_ERROR)"
add_arg "$(k_arg GIT_SERVICE)"
add_arg "$(v_arg GIT_SERVICE)"
add_arg "$(k_arg PARENT_SHA)"
add_arg "$(v_arg PARENT_SHA)"
add_arg "$(k_arg PR)"
add_arg "$(v_arg PR)"
add_arg "$(k_arg SHA)"
add_arg "$(v_arg SHA)"
add_arg "$(k_arg SLUG)"
add_arg "$(v_arg SLUG)"

add_arg "$(k_arg CODE)"
add_arg "$(v_arg CODE)"

add_arg "$(k_arg ENV)"
add_arg "$(v_arg ENV)"

OLDIFS=$IFS;IFS=,

add_arg "$(k_arg BRANCH)"
add_arg "$(v_arg BRANCH)"
add_arg "$(k_arg BUILD)"
add_arg "$(v_arg BUILD)"
add_arg "$(k_arg BUILD_URL)"
add_arg "$(v_arg BUILD_URL)"
add_arg "$(k_arg DIR)"
add_arg "$(v_arg DIR)"
add_arg "$(write_bool_args CODECOV_DISABLE_FILE_FIXES)"
add_arg "$(write_bool_args CODECOV_DISABLE_SEARCH)"
add_arg "$(write_bool_args CODECOV_DRY_RUN)"

if [ -n "$CODECOV_EXCLUDES" ];
then
  for directory in $CODECOV_EXCLUDES; do
    add_arg "--exclude"
    add_arg "$directory"
  done
fi

if [ -n "$CODECOV_FILES" ];
then
  for file in $CODECOV_FILES; do
    add_arg "--file"
    add_arg "$file"
  done
fi

if [ -n "$CODECOV_FLAGS" ];
then
  for flag in $CODECOV_FLAGS; do
    add_arg "--flag"
    add_arg "$flag"
  done
fi

add_arg "$(k_arg GCOV_ARGS)"
add_arg "$(v_arg GCOV_ARGS)"
add_arg "$(k_arg GCOV_EXECUTABLE)"
add_arg "$(v_arg GCOV_EXECUTABLE)"
add_arg "$(k_arg GCOV_IGNORE)"
add_arg "$(v_arg GCOV_IGNORE)"
add_arg "$(k_arg GCOV_INCLUDE)"
add_arg "$(v_arg GCOV_INCLUDE)"
add_arg "$(write_bool_args CODECOV_HANDLE_NO_REPORTS_FOUND)"
add_arg "$(write_bool_args CODECOV_RECURSE_SUBMODULES)"
add_arg "$(k_arg JOB_CODE)"
add_arg "$(v_arg JOB_CODE)"
add_arg "$(write_bool_args CODECOV_LEGACY)"

if [ -n "$CODECOV_NAME" ];
then
  add_arg "--name"
  add_arg "$CODECOV_NAME"
fi

add_arg "$(k_arg NETWORK_FILTER)"
add_arg "$(v_arg NETWORK_FILTER)"
add_arg "$(k_arg NETWORK_PREFIX)"
add_arg "$(v_arg NETWORK_PREFIX)"
add_arg "$(k_arg NETWORK_ROOT_FOLDER)"
add_arg "$(v_arg NETWORK_ROOT_FOLDER)"

if [ -n "$CODECOV_PLUGINS" ];
then
  for plugin in $CODECOV_PLUGINS; do
    add_arg "--plugin"
    add_arg "$plugin"
  done
fi

add_arg "$(k_arg REPORT_TYPE)"
add_arg "$(v_arg REPORT_TYPE)"
add_arg "$(k_arg SWIFT_PROJECT)"
add_arg "$(v_arg SWIFT_PROJECT)"

IFS=$OLDIFS
