#!/usr/bin/env bash

unset NODE_OPTIONS
# See https://github.com/codecov/uploader/issues/475

chmod +x $codecov_command

if [ -n "$CODECOV_TOKEN_VAR" ];
then
  token="$(eval echo \$$CODECOV_TOKEN_VAR)"
else
  token="$(eval echo $CODECOV_TOKEN)"
fi

say "$g ->$x Token of length ${#token} detected"
token_str=""
token_arg=()
if [ -n "$token" ];
then
  token_str+=" -t <redacted>"
  token_arg+=( " -t " "$token")
fi

say "$g==>$x Running upload-coverage"
say "      $b$codecov_command $(echo "${codecov_cli_args[@]}") upload-coverage$token_str $(echo "${codecov_uc_args[@]}")$x"
if ! $codecov_command \
  ${codecov_cli_args[*]} \
  upload-coverage \
  ${token_arg[*]} \
  "${codecov_uc_args[@]}";
then
  exit_if_error "Failed to upload coverage"
fi
