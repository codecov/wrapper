#!/usr/bin/env bash

codecov_args=()
if [ "$CODECOV_RUN_CMD" == "upload-coverage" ]; then
  . ./set_upload_coverage_args.sh
elif [ "$CODECOV_RUN_CMD" == "empty-upload" ]; then
  . ./set_empty_upload_args.sh
elif [ "$CODECOV_RUN_CMD" == "pr-base-picking" ]; then
  . ./set_pr_base_picking_args.sh
elif [ "$CODECOV_RUN_CMD" == "send-notifications" ]; then
  . ./set_send_notifications_args.sh
else
  exit_if_error "Invalid run command specified: $CODECOV_RUN_CMD"
  exit
fi

unset NODE_OPTIONS
# github.com/codecov/uploader/issues/475

say "$g==>$x Running $CODECOV_RUN_CMD"
say "      $b$codecov_command $(echo "${codecov_cli_args[@]}") $CODECOV_RUN_CMD$token_str $(echo "${codecov_args[@]}")$x"
if ! $codecov_command \
  ${codecov_cli_args[*]} \
  ${CODECOV_RUN_CMD} \
  ${token_arg[*]} \
  "${codecov_args[@]}";
then
  exit_if_error "Failed to run $CODECOV_RUN_CMD"
fi
