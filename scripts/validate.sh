#!/usr/bin/env bash

if [ "$CODECOV_SKIP_VALIDATION" == "true" ] || [ -n "$CODECOV_BINARY" ] || [ "$CODECOV_USE_PYPI" == "true" ];
then
  say "$r==>$x Bypassing validation..."
  if [ "$CODECOV_SKIP_VALIDATION" == "true" ];
  then
    chmod +x "$CODECOV_COMMAND"
  fi
else
  # Import GPG key with retry logic and error handling
  say "$g==>$x Importing GPG verification key..."
  gpg_key_imported=false
  for attempt in 1 2 3; do
    say "$g ->$x Attempt $attempt to import GPG key"
    if gpg_key=$(curl -f -s --retry 3 --retry-delay 2 https://keybase.io/codecovsecurity/pgp_keys.asc 2>&1); then
      if [ -n "$gpg_key" ]; then
        if echo "$gpg_key" | gpg --no-default-keyring --import 2>&1; then
          gpg_key_imported=true
          say "$g==>$x GPG key imported successfully"
          break
        else
          say "$y==>$x GPG import failed on attempt $attempt"
        fi
      else
        say "$y==>$x Empty GPG key received on attempt $attempt"
      fi
    else
      say "$y==>$x Failed to download GPG key on attempt $attempt"
    fi
    if [ $attempt -lt 3 ]; then
      sleep 2
    fi
  done

  if [ "$gpg_key_imported" = false ]; then
    exit_if_error "Failed to import GPG key after 3 attempts. Please check network connectivity or try setting CODECOV_SKIP_VALIDATION=true"
  fi

  # One-time step
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
  exit
fi
