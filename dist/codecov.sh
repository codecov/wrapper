#!/usr/bin/env bash
set +u
say() {
  echo -e "$1"
}
exit_if_error() {
  say "$r==> $1$x"
  if [ "$CC_FAIL_ON_ERROR" = true ];
  then
     say "$r    Exiting...$x"
     exit 1;
  fi
}
lower() {
  echo $(echo $1 | sed 's/CC//' | sed 's/_/-/g' | tr '[:upper:]' '[:lower:]')
}
k_arg() {
  if [ -n "$(eval echo \$"CC_$1")" ];
  then
    echo "--$(lower "$1")"
  fi
}
v_arg() {
  if [ -n "$(eval echo \$"CC_$1")" ];
  then
    echo "$(eval echo \$"CC_$1")"
  fi
}
write_bool_args() {
  if [ "$(eval echo \$$1)" = "true" ] || [ "$(eval echo \$$1)" = "1" ];
  then
    echo "-$(lower $1)"
  fi
}
b="\033[0;36m"  # variables/constants
g="\033[0;32m"  # info/debug
r="\033[0;31m"  # errors
x="\033[0m"
retry="--retry 5 --retry-delay 2"
CC_WRAPPER_VERSION="0.2.7"
CC_VERSION="${CC_VERSION:-latest}"
CC_FAIL_ON_ERROR="${CC_FAIL_ON_ERROR:-false}"
CC_RUN_CMD="${CC_RUN_CMD:-upload-coverage}"
CC_CLI_TYPE=${CC_CLI_TYPE:-"codecov-cli"}
say "     _____          _
    / ____|        | |
   | |     ___   __| | ___  ___ _____   __
   | |    / _ \\ / _\` |/ _ \\/ __/ _ \\ \\ / /
   | |___| (_) | (_| |  __/ (_| (_) \\ V /
    \\_____\\___/ \\__,_|\\___|\\___\\___/ \\_/
                           $r Wrapper-$CC_WRAPPER_VERSION$x
                           "
if [[ "$CC_CLI_TYPE" != "codecov-cli" && "$CC_CLI_TYPE" != "sentry-prevent-cli" ]]; then
  echo "Invalid CC_CLI_TYPE: '$CC_CLI_TYPE'. Must be 'codecov-cli' or 'sentry-prevent-cli'"
  exit 1
fi
if [ -n "$CC_BINARY" ];
then
  if [ -f "$CC_BINARY" ];
  then
    CC_FILENAME=$CC_BINARY
    CC_COMMAND=$CC_BINARY
  else
    exit_if_error "Could not find binary file $CC_BINARY"
  fi
elif [ "$CC_USE_PYPI" == "true" ];
then
  if ! pip install "${CC_CLI_TYPE}$([ "$CC_VERSION" == "latest" ] && echo "" || echo "==$CC_VERSION")"; then
    exit_if_error "Could not install via pypi."
    exit
  fi
  if [[ "$CC_CLI_TYPE" == "codecov-cli" ]]; then
    CC_COMMAND="codecovcli"
  elif [[ "$CC_CLI_TYPE" == "sentry-prevent-cli" ]]; then
    CC_COMMAND="sentry-prevent-cli"
  else
    CC_COMMAND="${CC_CLI_TYPE}"
  fi
else
  if [ -n "$CC_OS" ];
  then
    say "$g==>$x Overridden OS: $b${CC_OS}$x"
  else
    CC_OS="windows"
    family=$(uname -s | tr '[:upper:]' '[:lower:]')
    [[ $family == "darwin" ]] && CC_OS="macos"
    [[ $family == "linux" ]] && CC_OS="linux"
    [[ $CC_OS == "linux" ]] && \
      osID=$(grep -e "^ID=" /etc/os-release | cut -c4-)
    [[ $osID == "alpine" ]] && CC_OS="alpine"
    [[ $(arch) == "aarch64" && $family == "linux" ]] && CC_OS+="-arm64"
    say "$g==>$x Detected $b${CC_OS}$x"
  fi
  CC_FILENAME="${CC_CLI_TYPE%-cli}"
  [[ $CC_OS == "windows" ]] && CC_FILENAME+=".exe"
  CC_COMMAND="./$CC_FILENAME"
  [[ $CC_OS == "macos" ]]  && \
    ! command -v gpg 2>&1 >/dev/null && \
    HOMEBREW_NO_AUTO_UPDATE=1 brew install gpg
  CC_URL="${CC_CLI_URL:-https://cli.codecov.io}"
  CC_URL="$CC_URL/${CC_VERSION}"
  CC_URL="$CC_URL/${CC_OS}/${CC_FILENAME}"
  say "$g ->$x Downloading $b${CC_URL}$x"
  curl -O $retry "$CC_URL"
  say "$g==>$x Finishing downloading $b${CC_OS}:${CC_VERSION}$x"
  v_url="https://cli.codecov.io/api/${CC_OS}/${CC_VERSION}"
  v=$(curl $retry --retry-all-errors -s "$v_url" -H "Accept:application/json" | tr \{ '\n' | tr , '\n' | tr \} '\n' | grep "\"version\"" | awk  -F'"' '{print $4}' | tail -1)
  say "      Version: $b$v$x"
  say " "
fi
if [ "$CC_SKIP_VALIDATION" == "true" ] || [ -n "$CC_BINARY" ] || [ "$CC_USE_PYPI" == "true" ];
then
  say "$r==>$x Bypassing validation..."
  if [ "$CC_SKIP_VALIDATION" == "true" ];
  then
    chmod +x "$CC_COMMAND"
  fi
else
  gpg --no-default-keyring --import <<'PGP_PUBLIC_KEY'
-----BEGIN PGP PUBLIC KEY BLOCK-----

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
=ch7z
-----END PGP PUBLIC KEY BLOCK-----
PGP_PUBLIC_KEY
  # One-time step
  say "$g==>$x Verifying GPG signature integrity"
  sha_url="https://cli.codecov.io"
  sha_url="${sha_url}/${CC_VERSION}/${CC_OS}"
  sha_url="${sha_url}/${CC_FILENAME}.SHA256SUM"
  say "$g ->$x Downloading $b${sha_url}$x"
  say "$g ->$x Downloading $b${sha_url}.sig$x"
  say " "
  curl -Os $retry --connect-timeout 2 "$sha_url"
  curl -Os $retry --connect-timeout 2 "${sha_url}.sig"
  if ! gpg --verify "${CC_FILENAME}.SHA256SUM.sig" "${CC_FILENAME}.SHA256SUM";
  then
    exit_if_error "Could not verify signature. Please contact Codecov if problem continues"
  fi
  if ! (shasum -a 256 -c "${CC_FILENAME}.SHA256SUM" 2>/dev/null || \
    sha256sum -c "${CC_FILENAME}.SHA256SUM");
  then
    exit_if_error "Could not verify SHASUM. Please contact Codecov if problem continues"
  fi
  say "$g==>$x CLI integrity verified"
  say
  chmod +x "$CC_COMMAND"
fi
if [ -n "$CC_BINARY_LOCATION" ];
then
  mkdir -p "$CC_BINARY_LOCATION" && mv "$CC_FILENAME" $_
  say "$g==>$x ${CC_CLI_TYPE} binary moved to ${CC_BINARY_LOCATION}"
fi
if [ "$CC_DOWNLOAD_ONLY" = "true" ];
then
  say "$g==>$x ${CC_CLI_TYPE} download only called. Exiting..."
  exit
fi
CC_CLI_ARGS=()
CC_CLI_ARGS+=( $(k_arg AUTO_LOAD_PARAMS_FROM) $(v_arg AUTO_LOAD_PARAMS_FROM))
CC_CLI_ARGS+=( $(k_arg ENTERPRISE_URL) $(v_arg ENTERPRISE_URL))
if [ -n "$CC_YML_PATH" ]
then
  CC_CLI_ARGS+=( "--codecov-yml-path" )
  CC_CLI_ARGS+=( "$CC_YML_PATH" )
fi
CC_CLI_ARGS+=( $(write_bool_args CC_DISABLE_TELEM) )
CC_CLI_ARGS+=( $(write_bool_args CC_VERBOSE) )
CC_ARGS=()
if [ "$CC_RUN_CMD" == "upload-coverage" ]; then
# Args for create commit
CC_ARGS+=( $(write_bool_args CC_FAIL_ON_ERROR) )
CC_ARGS+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
CC_ARGS+=( $(k_arg PARENT_SHA) $(v_arg PARENT_SHA))
CC_ARGS+=( $(k_arg PR) $(v_arg PR))
CC_ARGS+=( $(k_arg SHA) $(v_arg SHA))
CC_ARGS+=( $(k_arg SLUG) $(v_arg SLUG))
# Args for create report
CC_ARGS+=( $(k_arg CODE) $(v_arg CODE))
# Args for do upload
CC_ARGS+=( $(k_arg ENV) $(v_arg ENV))
OLDIFS=$IFS;IFS=,
CC_ARGS+=( $(k_arg BRANCH) $(v_arg BRANCH))
CC_ARGS+=( $(k_arg BUILD) $(v_arg BUILD))
CC_ARGS+=( $(k_arg BUILD_URL) $(v_arg BUILD_URL))
CC_ARGS+=( $(k_arg DIR) $(v_arg DIR))
CC_ARGS+=( $(write_bool_args CC_DISABLE_FILE_FIXES) )
CC_ARGS+=( $(write_bool_args CC_DISABLE_SEARCH) )
CC_ARGS+=( $(write_bool_args CC_DRY_RUN) )
if [ -n "$CC_EXCLUDES" ];
then
  for directory in $CC_EXCLUDES; do
    CC_ARGS+=( "--exclude" "$directory" )
  done
fi
if [ -n "$CC_FILES" ];
then
  for file in $CC_FILES; do
    CC_ARGS+=( "--file" "$file" )
  done
fi
if [ -n "$CC_FLAGS" ];
then
  for flag in $CC_FLAGS; do
    CC_ARGS+=( "--flag" "$flag" )
  done
fi
CC_ARGS+=( $(k_arg GCOV_ARGS) $(v_arg GCOV_ARGS))
CC_ARGS+=( $(k_arg GCOV_EXECUTABLE) $(v_arg GCOV_EXECUTABLE))
CC_ARGS+=( $(k_arg GCOV_IGNORE) $(v_arg GCOV_IGNORE))
CC_ARGS+=( $(k_arg GCOV_INCLUDE) $(v_arg GCOV_INCLUDE))
CC_ARGS+=( $(write_bool_args CC_HANDLE_NO_REPORTS_FOUND) )
CC_ARGS+=( $(write_bool_args CC_RECURSE_SUBMODULES) )
CC_ARGS+=( $(k_arg JOB_CODE) $(v_arg JOB_CODE))
CC_ARGS+=( $(write_bool_args CC_LEGACY) )
if [ -n "$CC_NAME" ];
then
  CC_ARGS+=( "--name" "$CC_NAME" )
fi
CC_ARGS+=( $(k_arg NETWORK_FILTER) $(v_arg NETWORK_FILTER))
CC_ARGS+=( $(k_arg NETWORK_PREFIX) $(v_arg NETWORK_PREFIX))
CC_ARGS+=( $(k_arg NETWORK_ROOT_FOLDER) $(v_arg NETWORK_ROOT_FOLDER))
if [ -n "$CC_PLUGINS" ];
then
  for plugin in $CC_PLUGINS; do
    CC_ARGS+=( "--plugin" "$plugin" )
  done
fi
CC_ARGS+=( $(k_arg REPORT_TYPE) $(v_arg REPORT_TYPE))
CC_ARGS+=( $(k_arg SWIFT_PROJECT) $(v_arg SWIFT_PROJECT))
IFS=$OLDIFS
elif [ "$CC_RUN_CMD" == "empty-upload" ]; then
CC_ARGS+=( $(k_arg BRANCH) $(v_arg BRANCH))
CC_ARGS+=( $(write_bool_args CC_FAIL_ON_ERROR) )
CC_ARGS+=( $(write_bool_args CC_FORCE) )
CC_ARGS+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
CC_ARGS+=( $(k_arg PARENT_SHA) $(v_arg PARENT_SHA))
CC_ARGS+=( $(k_arg PR) $(v_arg PR))
CC_ARGS+=( $(k_arg SHA) $(v_arg SHA))
CC_ARGS+=( $(k_arg SLUG) $(v_arg SLUG))
elif [ "$CC_RUN_CMD" == "pr-base-picking" ]; then
CC_ARGS+=( $(k_arg BASE_SHA) $(v_arg BASE_SHA))
CC_ARGS+=( $(k_arg PR) $(v_arg PR))
CC_ARGS+=( $(k_arg SLUG) $(v_arg SLUG))
CC_ARGS+=( $(k_arg SERVICE) $(v_arg SERVICE))
elif [ "$CC_RUN_CMD" == "send-notifications" ]; then
CC_ARGS+=( $(k_arg SHA) $(v_arg SHA))
CC_ARGS+=( $(write_bool_args CC_FAIL_ON_ERROR) )
CC_ARGS+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
CC_ARGS+=( $(k_arg SLUG) $(v_arg SLUG))
else
  exit_if_error "Invalid run command specified: $CC_RUN_CMD"
  exit
fi
unset NODE_OPTIONS
# github.com/codecov/uploader/issues/475
if [ -n "$CC_TOKEN_VAR" ];
then
  token="$(eval echo \$$CC_TOKEN_VAR)"
else
  token="$(eval echo $CC_TOKEN)"
fi
say "$g ->$x Token length: ${#token}"
token_str=""
token_arg=()
if [ -n "$token" ];
then
  token_str+=" -t <redacted>"
  token_arg+=( " -t " "$token")
fi
say "$g==>$x Running $CC_RUN_CMD"
say "      $b$CC_COMMAND $(echo "${CC_CLI_ARGS[@]}") $CC_RUN_CMD$token_str $(echo "${CC_ARGS[@]}")$x"
if ! $CC_COMMAND \
  ${CC_CLI_ARGS[*]} \
  ${CC_RUN_CMD} \
  ${token_arg[*]} \
  "${CC_ARGS[@]}";
then
  exit_if_error "Failed to run $CC_RUN_CMD"
fi
