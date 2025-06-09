#!/bin/sh

set +u
say() {
  echo -e "$1"
}

exit_if_error() {
  say "$r==> $1$x"
  if [ "$CODECOV_FAIL_ON_ERROR" = true ];
  then
     say "$r    Exiting...$x"
     exit 1;
  fi
}

lower() {
  echo $(echo $1 | sed 's/CODECOV//' | sed 's/_/-/g' | tr '[:upper:]' '[:lower:]')
}

k_arg() {
  if [ -n "$(eval echo \$"CODECOV_$1")" ];
  then
    echo "--$(lower "$1")"
  fi
}

v_arg() {
  if [ -n "$(eval echo \$"CODECOV_$1")" ];
  then
    echo "$(eval echo \$"CODECOV_$1")"
  fi
}

write_bool_args() {
  if [ "$(eval echo \$$1)" = "true" ] || [ "$(eval echo \$$1)" = "1" ];
  then
    echo "-$(lower $1)"
  fi
}

add_cli_arg() { [ -n "$1" ] && CODECOV_CLI_ARGS="${CODECOV_CLI_ARGS:+$CODECOV_CLI_ARGS }$1"; }
add_arg() { [ -n "$1" ] && CODECOV_ARGS="${CODECOV_ARGS:+$CODECOV_ARGS }$1"; }

b="\033[0;36m"  # variables/constants
g="\033[0;32m"  # info/debug
r="\033[0;31m"  # errors
x="\033[0m"
retry="--retry 5 --retry-delay 2"
