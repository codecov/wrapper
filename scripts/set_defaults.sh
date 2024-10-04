#!/usr/bin/env bash

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

lower() {
  echo $(echo $1 | sed 's/CODECOV//' | sed 's/_/-//' | tr '[:upper:]' '[:lower:]')
}

write_existing_args() {
  if [ -n "$1" ];
  then
    echo " --$(lower $1) $(eval echo \$$1)"
  fi
}

write_truthy_args() {
  if [ "$1" = "true" ];
  then
    echo " --$(lower $1)"
  fi
}

b="\033[0;36m"  # variables/constants
g="\033[0;32m"  # info/debug
r="\033[0;31m"  # errors
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
