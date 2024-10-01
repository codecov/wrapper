unset NODE_OPTIONS
# See https://github.com/codecov/uploader/issues/475

chmod +x $codecov_filename
[ -n "${CODECOV_FILE}" ] && \
  set - "${@}" "-f" "${CODECOV_FILE}"
[ -n "${CODECOV_UPLOAD_ARGS}" ] && \
  set - "${@}" "${CODECOV_UPLOAD_ARGS}"

FLAGS=""
OLDIFS=$IFS;IFS=,
for flag in $CODECOV_FLAGS; do
  eval e="\$$flag"
  for param in "${e}" "${flag}"; do
    if [ -n "${param}" ]; then
      if [ -n "${FLAGS}" ]; then
        FLAGS="${FLAGS},${param}"
      else
        FLAGS="${param}"
      fi
      break
    fi
  done
done
IFS=$OLDIFS

if [ -n "$FLAGS" ]; then
  FLAGS="-F ${FLAGS}"
fi

#create commit
echo "./\"$codecov_filename\" ${CODECOV_CLI_ARGS} create-commit -t $CODECOV_TOKEN"

./$codecov_filename \
  ${CODECOV_CLI_ARGS} \
  create-commit \
  -t "$(eval echo $CODECOV_TOKEN)" \
  ${CODECOV_COMMIT_ARGS}

#create report
echo "./\"$codecov_filename\" ${CODECOV_CLI_ARGS} create-report -t <redacted>"

./$codecov_filename \
  ${CODECOV_CLI_ARGS} \
  create-report \
  -t "$(eval echo $CODECOV_TOKEN)" \
  ${CODECOV_REPORT_ARGS}

#upload reports
# alpine doesn't allow for indirect expansion

echo "./${codecov_filename} ${CODECOV_CLI_ARGS} do-upload -Z -t <redacted> ${CODECOV_UPLOAD_ARGS} ${@}"

./$codecov_filename \
  ${CODECOV_CLI_ARGS} \
  do-upload \
  -Z \
  -t "$(eval echo $CODECOV_TOKEN)" \
  ${FLAGS} \
  ${CODECOV_UPLOAD_ARGS} \
  ${@}
