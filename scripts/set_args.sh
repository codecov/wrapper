#!/bin/sh

CODECOV_CLI_ARGS=""
add_cli_arg "$(k_arg AUTO_LOAD_PARAMS_FROM)"
add_cli_arg "$(v_arg AUTO_LOAD_PARAMS_FROM)"
add_cli_arg "$(k_arg ENTERPRISE_URL)"
add_cli_arg "$(v_arg ENTERPRISE_URL)"

if [ -n "$CODECOV_YML_PATH" ]
then
  add_cli_arg "--codecov-yml-path"
  add_cli_arg "$CODECOV_YML_PATH"
fi

add_cli_arg "$(write_bool_args CODECOV_DISABLE_TELEM)"
add_cli_arg "$(write_bool_args CODECOV_VERBOSE)"

CODECOV_ARGS=""

if [ "$CODECOV_RUN_CMD" = "upload-coverage" ]; then
  . ./set_upload_coverage_args.sh
elif [ "$CODECOV_RUN_CMD" = "empty-upload" ]; then
  . ./set_empty_upload_args.sh
elif [ "$CODECOV_RUN_CMD" = "pr-base-picking" ]; then
  . ./set_pr_base_picking_args.sh
elif [ "$CODECOV_RUN_CMD" = "send-notifications" ]; then
  . ./set_send_notifications_args.sh
else
  exit_if_error "Invalid run command specified: $CODECOV_RUN_CMD"
  exit
fi
