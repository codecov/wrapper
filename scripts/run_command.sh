#!/bin/sh

unset NODE_OPTIONS
# github.com/codecov/uploader/issues/475

if [ -n "$CODECOV_TOKEN_VAR" ];
then
  token="$(eval echo \$$CODECOV_TOKEN_VAR)"
else
  token="$(eval echo $CODECOV_TOKEN)"
fi
say "$g ->$x Token length: ${#token}"
token_str=""
token_arg=""
if [ -n "$token" ];
then
  token_str=" -t <redacted>"
  token_arg=" -t $token"
fi

say "$g==>$x Running $CODECOV_RUN_CMD"
say "      $b$CODECOV_COMMAND $CODECOV_CLI_ARGS $CODECOV_RUN_CMD$token_str $CODECOV_ARGS$x"

if [ -n "$token" ]; then
  eval "$CODECOV_COMMAND $CODECOV_CLI_ARGS $CODECOV_RUN_CMD $token_arg $CODECOV_ARGS"
else
  eval "$CODECOV_COMMAND $CODECOV_CLI_ARGS $CODECOV_RUN_CMD $CODECOV_ARGS"
fi

if [ $? -ne 0 ]; then
  exit_if_error "Failed to run $CODECOV_RUN_CMD"
fi
