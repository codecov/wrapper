#!/bin/sh

if [ "$CODECOV_SKIP_VALIDATION" == "true" ] || [ -n "$CODECOV_BINARY" ] || [ "$CODECOV_USE_PYPI" == "true" ];
then
  say "$r==>$x Bypassing validation..."
else
  echo "$(curl -s https://keybase.io/codecovsecurity/pgp_keys.asc)" | \
    gpg --no-default-keyring --import
  say "$g==>$x Verifying GPG signature integrity"
  sha_url="https://cli.codecov.io"
  sha_url="${sha_url}/${CODECOV_VERSION}/${CODECOV_OS}"
  sha_url="${sha_url}/${CODECOV_FILENAME}.SHA256SUM"
  say "$g ->$x Downloading $b${sha_url}$x"
  say "$g ->$x Downloading $b${sha_url}.sig$x"
  say " "

  curl -Os $retry --connect-timeout 2 "$sha_url"
  curl -Os $retry --connect-timeout 2 "${sha_url}.sig"

  if ! gpg --verify "${CODECOV_FILENAME}.SHA256SUM.sig" "${CODECOV_FILENAME}.SHA256SUM";
  then
    exit_if_error "Could not verify signature. Please contact Codecov if problem continues"
  fi

  if ! (shasum -a 256 -c "${CODECOV_FILENAME}.SHA256SUM" 2>/dev/null || \
    sha256sum -c "${CODECOV_FILENAME}.SHA256SUM");
  then
    exit_if_error "Could not verify SHASUM. Please contact Codecov if problem continues"
  fi
  say "$g==>$x CLI integrity verified"
  say
  chmod +x "$CODECOV_COMMAND"
fi

if [ -n "$CODECOV_BINARY_LOCATION" ];
then
  mkdir -p "$CODECOV_BINARY_LOCATION" && mv "$CODECOV_FILENAME" $_
  say "$g==>$x ${CODECOV_CLI_TYPE} binary moved to ${CODECOV_BINARY_LOCATION}"
fi

if [ "$CODECOV_DOWNLOAD_ONLY" = "true" ];
then
  say "$g==>$x ${CODECOV_CLI_TYPE} download only called. Exiting..."
fi
