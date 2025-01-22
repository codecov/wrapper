#!/usr/bin/env bash

if [ "$CODECOV_RUN_COMMAND" == "upload-coverage" ]; then
  . ./set_upload_coverage_args.sh
elif [ "$CODECOV_RUN_COMMAND" == "empty-upload" ]; then
  . ./set_empty_upload_args.sh
elif [ "$CODECOV_RUN_COMMAND" == "pr-base-picking" ]; then
  . ./set_pr_base_picking_args.sh
elif [ "$CODECOV_RUN_COMMAND" == "send-notifications" ]; then
  . ./set_send_notifications_args.sh
else
  exit_if_error "Invalid run command specified: $CODECOV_RUN_COMMAND"
  exit
fi

unset NODE_OPTIONS
# See https://github.com/codecov/uploader/issues/475

chmod +x "$codecov_command"

say "$g==>$x Running $CODECOV_RUN_COMMAND"
say "      $b$codecov_command $(echo "${codecov_cli_args[@]}")$CODECOV_RUN_COMMAND$token_str $(echo "${codecov_args[@]}")$x"
if ! $codecov_command \
  ${codecov_cli_args[*]} \
  ${CODECOV_RUN_COMMAND} \
  ${token_arg[*]} \
  "${codecov_args[@]}";
then
  exit_if_error "Failed to run $CODECOV_RUN_COMMAND"
fi
