#!/usr/bin/env bash

if [ -n "$CODECOV_BINARY" ];
then
  if [ -f "$CODECOV_BINARY" ];
  then
    codecov_filename=$CODECOV_BINARY
  else
    exit_if_error "Could not find binary file $CODECOV_BINARY"
  fi
else
  family=$(uname -s | tr '[:upper:]' '[:lower:]')
  codecov_os="windows"
  [[ $family == "darwin" ]] && codecov_os="macos"

  [[ $family == "linux" ]] && codecov_os="linux"
  [[ $codecov_os == "linux" ]] && \
    osID=$(grep -e "^ID=" /etc/os-release | cut -c4-)
  [[ $osID == "alpine" ]] && codecov_os="alpine"
  [[ $(arch) == "aarch64" && $family == "linux" ]] && codecov_os+="-arm64"
  say "$g==>$x Detected $b${codecov_os}$x"
  export codecov_os=${codecov_os}
  export codecov_version=${CODECOV_VERSION}

  codecov_filename="codecov"
  [[ $codecov_os == "windows" ]] && codecov_filename+=".exe"
  export codecov_filename=${codecov_filename}
  [[ $codecov_os == "macos" ]]  && \
    ! command -v gpg 2>&1 >/dev/null && \
    HOMEBREW_NO_AUTO_UPDATE=1 brew install gpg
  codecov_url="https://cli.codecov.io"
  codecov_url="$codecov_url/${CODECOV_VERSION}"
  codecov_url="$codecov_url/${codecov_os}/${codecov_filename}"
  say "$g ->$x Downloading $b${codecov_url}$x"
  curl -Os $codecov_url

  say "$g==>$x Finishing downloading $b${codecov_os}:${CODECOV_VERSION}$x"
  say " "
fi
