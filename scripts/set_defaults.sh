#!/usr/bin/env bash

CODECOV_WRAPPER_VERSION="0.2.5"
CODECOV_VERSION="${CODECOV_VERSION:-latest}"
CODECOV_FAIL_ON_ERROR="${CODECOV_FAIL_ON_ERROR:-false}"
CODECOV_RUN_CMD="${CODECOV_RUN_CMD:-upload-coverage}"

say "     _____          _
    / ____|        | |
   | |     ___   __| | ___  ___ _____   __
   | |    / _ \\ / _\` |/ _ \\/ __/ _ \\ \\ / /
   | |___| (_) | (_| |  __/ (_| (_) \\ V /
    \\_____\\___/ \\__,_|\\___|\\___\\___/ \\_/
                           $r Wrapper-$CODECOV_WRAPPER_VERSION$x
                           "
