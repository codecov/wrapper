#!/usr/bin/env bash

unset NODE_OPTIONS
# See https://github.com/codecov/uploader/issues/475

chmod +x $codecov_filename

token="$(eval echo $CODECOV_TOKEN)"
say "$g ->$x Token of length ${#token} detected"
token_str=""
token_arg=()
if [ -n $token ];
then
  token_str+=" -t <redacted>"
  token_arg+=( " -t " "$token")
fi

#create commit
say "$g==>$x Running create-commit"
say "      $b./$codecov_filename$codecov_cli_args create-commit$token_str$codecov_create_commit_args$x"

if ! ./$codecov_filename \
  $codecov_cli_args \
  create-commit \
  ${token_arg[@]} \
  ${codecov_create_commit_args[@]};
then
  exit_if_error "Failed to create-commit"
fi

say " "

#create report
say "$g==>$x Running create-report"
say "      $b./$codecov_filename$codecov_cli_args create-commit$token_str$codecov_create_report_args$x"

if ! ./$codecov_filename \
  $codecov_cli_args \
  create-report \
  ${token_arg[@]} \
  ${codecov_create_report_args[@]};
then
  exit_if_error "Failed to create-report"
fi

say " "

#upload reports
# alpine doesn't allow for indirect expansion
say "$g==>$x Running do-upload"
say "      $b./$codecov_filename$codecov_cli_args do-upload$token_str$codecov_do_upload_args$x"

if ! ./$codecov_filename \
  $codecov_cli_args \
  do-upload \
  ${token_arg[@]} \
  ${codecov_do_upload_args[@]};
then
  exit_if_error "Failed to upload"
fi
