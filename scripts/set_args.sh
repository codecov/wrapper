#!/usr/bin/env bash

CODECOV_CLI_ARGS=()

CODECOV_CLI_ARGS+=( $(k_arg AUTO_LOAD_PARAMS_FROM) $(v_arg AUTO_LOAD_PARAMS_FROM))
CODECOV_CLI_ARGS+=( $(k_arg ENTERPRISE_URL) $(v_arg ENTERPRISE_URL))
if [ -n "$CODECOV_YML_PATH" ]
then
  CODECOV_CLI_ARGS+=( "--codecov-yml-path" )
  CODECOV_CLI_ARGS+=( "$CODECOV_YML_PATH" )
fi
CODECOV_CLI_ARGS+=( $(write_bool_args CODECOV_DISABLE_TELEM) )
CODECOV_CLI_ARGS+=( $(write_bool_args CODECOV_VERBOSE) )

CODECOV_ARGS=()

if [ "$CODECOV_CLI_TYPE" == "sentry-prevent-cli" ]; then
  if [ "$CODECOV_RUN_CMD" == "upload" ]; then
    . ./set_upload_args.sh
  else
    exit_if_error "Invalid run command for sentry-prevent-cli: $CODECOV_RUN_CMD. Only 'upload' is supported."
    exit
  fi
elif [ "$CODECOV_CLI_TYPE" == "codecov-cli" ]; then
  if [ "$CODECOV_RUN_CMD" == "upload-coverage" ]; then
    . ./set_upload_coverage_args.sh
  elif [ "$CODECOV_RUN_CMD" == "empty-upload" ]; then
    . ./set_empty_upload_args.sh
  elif [ "$CODECOV_RUN_CMD" == "pr-base-picking" ]; then
    . ./set_pr_base_picking_args.sh
  elif [ "$CODECOV_RUN_CMD" == "send-notifications" ]; then
    . ./set_send_notifications_args.sh
  else
    exit_if_error "Invalid run command for codecov-cli: $CODECOV_RUN_CMD. Supported commands: upload-coverage, empty-upload, pr-base-picking, send-notifications."
    exit
  fi
else
  exit_if_error "Invalid CLI type: $CODECOV_CLI_TYPE"
  exit
fi
