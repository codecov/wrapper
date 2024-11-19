#!/usr/bin/env bash

unset NODE_OPTIONS
# See https://github.com/codecov/uploader/issues/475

if [ -z "$CC_USE_PYTHON" ]; 
then
  chmod +x $codecov_filename
  bin="./$codecov_filename"
else
  bin="codecov-cli"
fi

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

say "$g==>$x Running create-commit"
say "      $b$bin $(echo "${codecov_cli_args[@]}") create-commit$token_str $(echo "${codecov_cc_args[@]}")$x"
if ! $bin \
  ${codecov_cli_args[*]} \
  create-commit \
  ${token_arg[*]} \
  ${codecov_cc_args[*]};
then
  exit_if_error "Failed to create-commit"
fi
say " "

say "$g==>$x Running create-report"
say "      $b$bin $(echo "${codecov_cli_args[@]}") create-report$token_str $(echo "${codecov_cr_args[@]}")$x"
if ! $bin \
  ${codecov_cli_args[*]} \
  create-report \
  ${token_arg[*]} \
  ${codecov_cr_args[*]};
then
  exit_if_error "Failed to create-report"
fi
say " "

say "$g==>$x Running do-upload"
say "      $b$bin $(echo "${codecov_cli_args[@]}") do-upload$token_str $(echo "${codecov_du_args[@]}")$x"
if ! $bin \
  ${codecov_cli_args[*]} \
  do-upload \
  ${token_arg[*]} \
  ${codecov_du_args[*]};
then
  exit_if_error "Failed to upload"
fi
