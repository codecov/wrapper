#!/usr/bin/env bash

unset NODE_OPTIONS
# See https://github.com/codecov/uploader/issues/475

chmod +x $codecov_filename

token="$(eval echo $CODECOV_TOKEN)"
say "$g ->$x Token of length ${#token} detected"

#create commit
say "$g==>$x Running create-commit"
say "       $b./$codecov_filename$codecov_cli_args create-commit$codecov_create_commit_args$x"

./$codecov_filename \
  $codecov_cli_args \
  create-commit \
  -t $token \
  $codecov_create_commit_args

say

#create report
say "./\"$codecov_filename\" $codecov_cli_args create-report -t <redacted>"

./$codecov_filename \
  $codecov_cli_args \
  create-report \
  -t "$(eval echo $CODECOV_TOKEN)" \
  ${CODECOV_REPORT_ARGS}

#upload reports
# alpine doesn't allow for indirect expansion

say "./${codecov_filename} $codecov_cli_args do-upload -Z -t <redacted> ${CODECOV_UPLOAD_ARGS} ${@}"

./$codecov_filename \
  $codecov_cli_args \
  do-upload \
  -Z \
  -t "$(eval echo $CODECOV_TOKEN)" \
  ${FLAGS} \
  ${CODECOV_UPLOAD_ARGS} \
  ${@}
