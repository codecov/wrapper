#!/usr/bin/env bash

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
