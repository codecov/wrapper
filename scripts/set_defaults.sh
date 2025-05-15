#!/usr/bin/env bash

CODECOV_WRAPPER_VERSION="0.2.6"
CODECOV_VERSION="${CODECOV_VERSION:-latest}"
CODECOV_FAIL_ON_ERROR="${CODECOV_FAIL_ON_ERROR:-false}"
CODECOV_RUN_CMD="${CODECOV_RUN_CMD:-upload-coverage}"
CODECOV_CLI_TYPE=${CODECOV_CLI_TYPE:-"codecov-cli"}

say "     _____          _
    / ____|        | |
   | |     ___   __| | ___  ___ _____   __
   | |    / _ \\ / _\` |/ _ \\/ __/ _ \\ \\ / /
   | |___| (_) | (_| |  __/ (_| (_) \\ V /
    \\_____\\___/ \\__,_|\\___|\\___\\___/ \\_/
                           $r Wrapper-$CODECOV_WRAPPER_VERSION$x
                           "

if [[ "$CODECOV_CLI_TYPE" != "codecov-cli" && "$CODECOV_CLI_TYPE" != "sentry-prevent-cli" ]]; then
  echo "Invalid CODECOV_CLI_TYPE: '$CODECOV_CLI_TYPE'. Must be 'codecov-cli' or 'sentry-prevent-cli'"
  exit 1
fi
