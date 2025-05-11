#!/usr/bin/env bash

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
token_arg=()
if [ -n "$token" ];
then
  token_str+=" -t <redacted>"
  token_arg+=( " -t " "$token")
fi

say "$g==>$x Running $CODECOV_RUN_CMD"
say "      $b$CODECOV_COMMAND $(echo "${CODECOV_CLI_ARGS[@]}") $CODECOV_RUN_CMD$token_str $(echo "${CODECOV_ARGS[@]}")$x"
if ! $CODECOV_COMMAND \
  ${CODECOV_CLI_ARGS[*]} \
  ${CODECOV_RUN_CMD} \
  ${token_arg[*]} \
  "${CODECOV_ARGS[@]}";
then
  exit_if_error "Failed to run $CODECOV_RUN_CMD"
fi
