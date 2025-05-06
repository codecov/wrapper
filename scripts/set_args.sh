#!/usr/bin/env bash

codecov_cli_args=()

codecov_cli_args+=( $(k_arg AUTO_LOAD_PARAMS_FROM) $(v_arg AUTO_LOAD_PARAMS_FROM))
codecov_cli_args+=( $(k_arg ENTERPRISE_URL) $(v_arg ENTERPRISE_URL))
if [ -n "$CODECOV_YML_PATH" ]
then
  codecov_cli_args+=( "--codecov-yml-path" )
  codecov_cli_args+=( "$CODECOV_YML_PATH" )
fi
codecov_cli_args+=( $(write_bool_args CODECOV_DISABLE_TELEM) )
codecov_cli_args+=( $(write_bool_args CODECOV_VERBOSE) )

if [ -n "$CODECOV_TOKEN_VAR" ];
then
  token="$(eval echo \$$CODECOV_TOKEN_VAR)"
else
  token="$(eval echo $CODECOV_TOKEN)"
fi
say "$g ->$x Token length: ${#token}"
token_str=""
token_arg=()
if [ -n "$token" ];
then
  token_str+=" -t <redacted>"
  token_arg+=( " -t " "$token")
fi

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
