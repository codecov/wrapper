#!/usr/bin/env bash

CODECOV_WRAPPER_VERSION="0.0.1"

say() {
  echo -e "$1"
}

exit_if_error() {
  say "$r==> $1$x"
  if [ $CODECOV_FAIL_ON_ERROR = true ];
  then
     say "$r    Exiting...$x"
     exit 1;
  fi
}

b="\033[0;36m"  # variables/constants
g="\033[0;32m"  # info/debug
r="\033[0;31m"  # errors
y="\033[0;33m"  # warnings
x="\033[0m"

say "     _____          _
    / ____|        | |
   | |     ___   __| | ___  ___ _____   __
   | |    / _ \\ / _\` |/ _ \\/ __/ _ \\ \\ / /
   | |___| (_) | (_| |  __/ (_| (_) \\ V /
    \\_____\\___/ \\__,_|\\___|\\___\\___/ \\_/
                           $r Wrapper-$CODECOV_WRAPPER_VERSION$x
                                  "

CODECOV_VERSION="${CODECOV_VERSION:-latest}"
CODECOV_FAIL_ON_ERROR="${CODECOV_FAIL_ON_ERROR:-false}"
say "$g ->$x$b CODECOV_VERSION$x = $CODECOV_VERSION"
say "$g ->$x$b CODECOV_FAIL_ON_ERROR$x = $CODECOV_FAIL_ON_ERROR"
say
