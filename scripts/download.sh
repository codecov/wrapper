#!/bin/sh

if [ -n "$CODECOV_BINARY" ];
then
  if [ -f "$CODECOV_BINARY" ];
  then
    CODECOV_FILENAME=$CODECOV_BINARY
    CODECOV_COMMAND=$CODECOV_BINARY
  else
    exit_if_error "Could not find binary file $CODECOV_BINARY"
  fi
elif [ "$CODECOV_USE_PYPI" = "true" ];
then
  if ! pip install "${CODECOV_CLI_TYPE}$([ "$CODECOV_VERSION" = "latest" ] && echo "" || echo "==$CODECOV_VERSION")"; then
    exit_if_error "Could not install via pypi."
    exit
  fi
  CODECOV_COMMAND="${CODECOV_CLI_TYPE}"
else
  if [ -n "$CODECOV_OS" ];
  then
    say "$g==>$x Overridden OS: $b${CODECOV_OS}$x"
  else
    CODECOV_OS="windows"
    family=$(uname -s | tr '[:upper:]' '[:lower:]')
    [ "$family" = "darwin" ] && CODECOV_OS="macos"
    [ "$family" = "linux" ] && CODECOV_OS="linux"
    [ "$CODECOV_OS" = "linux" ] && \
      osID=$(grep -e "^ID=" /etc/os-release | cut -c4-)
    [ "$osID" = "alpine" ] && CODECOV_OS="alpine"
    [ "$(arch)" = "aarch64" ] && [ "$family" = "linux" ] && CODECOV_OS="${CODECOV_OS}-arm64"
    say "$g==>$x Detected $b${CODECOV_OS}$x"
  fi

  CODECOV_FILENAME="${CODECOV_CLI_TYPE%-cli}"
  [ "$CODECOV_OS" = "windows" ] && CODECOV_FILENAME="${CODECOV_FILENAME}.exe"
  CODECOV_COMMAND="./$CODECOV_FILENAME"
  [ "$CODECOV_OS" = "macos" ] && \
    ! command -v gpg 2>&1 >/dev/null && \
    HOMEBREW_NO_AUTO_UPDATE=1 brew install gpg
  CODECOV_URL="${CODECOV_CLI_URL:-https://cli.codecov.io}"
  CODECOV_URL="$CODECOV_URL/${CODECOV_VERSION}"
  CODECOV_URL="$CODECOV_URL/${CODECOV_OS}/${CODECOV_FILENAME}"
  say "$g ->$x Downloading $b${CODECOV_URL}$x"
  curl -O $retry "$CODECOV_URL"
  say "$g==>$x Finishing downloading $b${CODECOV_OS}:${CODECOV_VERSION}$x"

  v_url="https://cli.codecov.io/api/${CODECOV_OS}/${CODECOV_VERSION}"
  v=$(curl $retry --retry-all-errors -s "$v_url" -H "Accept:application/json" | tr \{ '\n' | tr , '\n' | tr \} '\n' | grep "\"version\"" | awk  -F'"' '{print $4}' | tail -1)
  say "      Version: $b$v$x"
  say " "
fi
