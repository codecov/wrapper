#!/usr/bin/env bash
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
b="\033[0;36m"  # variables/constants
g="\033[0;32m"  # info/debug
r="\033[0;31m"  # errors
x="\033[0m"
retry="--retry 5 --retry-delay 2"
CODECOV_WRAPPER_VERSION="0.2.6"
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
if [ -n "$CODECOV_BINARY" ];
then
  if [ -f "$CODECOV_BINARY" ];
  then
    CODECOV_FILENAME=$CODECOV_BINARY
    CODECOV_COMMAND=$CODECOV_BINARY
  else
    exit_if_error "Could not find binary file $CODECOV_BINARY"
  fi
elif [ "$CODECOV_USE_PYPI" == "true" ];
then
  if ! pip install codecov-cli"$([ "$CODECOV_VERSION" == "latest" ] && echo "" || echo "==$CODECOV_VERSION" )"; then
    exit_if_error "Could not install via pypi."
    exit
  fi
  CODECOV_COMMAND="codecovcli"
else
  if [ -n "$CODECOV_OS" ];
  then
    say "$g==>$x Overridden OS: $b${CODECOV_OS}$x"
  else
    CODECOV_OS="windows"
    family=$(uname -s | tr '[:upper:]' '[:lower:]')
    [[ $family == "darwin" ]] && CODECOV_OS="macos"
    [[ $family == "linux" ]] && CODECOV_OS="linux"
    [[ $CODECOV_OS == "linux" ]] && \
      osID=$(grep -e "^ID=" /etc/os-release | cut -c4-)
    [[ $osID == "alpine" ]] && CODECOV_OS="alpine"
    [[ $(arch) == "aarch64" && $family == "linux" ]] && CODECOV_OS+="-arm64"
    say "$g==>$x Detected $b${CODECOV_OS}$x"
  fi
  CODECOV_FILENAME="codecov"
  [[ $CODECOV_OS == "windows" ]] && CODECOV_FILENAME+=".exe"
  CODECOV_COMMAND="./$CODECOV_FILENAME"
  [[ $CODECOV_OS == "macos" ]]  && \
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
if [ "$CODECOV_SKIP_VALIDATION" == "true" ] || [ -n "$CODECOV_BINARY" ] || [ "$CODECOV_USE_PYPI" == "true" ];
then
  say "$r==>$x Bypassing validation..."
else
  echo "$(curl -s https://keybase.io/codecovsecurity/pgp_keys.asc)" | \
    gpg --no-default-keyring --import
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
  say "$g==>$x Codecov binary moved to ${CODECOV_BINARY_LOCATION}"
fi
if [ "$CODECOV_DOWNLOAD_ONLY" = "true" ];
then
  say "$g==>$x Codecov download only called. Exiting..."
fi
CODECOV_CLI_ARGS=()
CODECOV_CLI_ARGS+=( $(k_arg AUTO_LOAD_PARAMS_FROM) $(v_arg AUTO_LOAD_PARAMS_FROM))
CODECOV_CLI_ARGS+=( $(k_arg ENTERPRISE_URL) $(v_arg ENTERPRISE_URL))
if [ -n "$CODECOV_YML_PATH" ]
then
  CODECOV_CLI_ARGS+=( "--codecov-yml-path" )
  CODECOV_CLI_ARGS+=( "$CODECOV_YML_PATH" )
fi
CODECOV_CLI_ARGS+=( $(write_bool_args CODECOV_DISABLE_TELEM) )
CODECOV_CLI_ARGS+=( $(write_bool_args CODECOV_VERBOSE) )
CODECOV_ARGS=()
if [ "$CODECOV_RUN_CMD" == "upload-coverage" ]; then
# Args for create commit
CODECOV_ARGS+=( $(write_bool_args CODECOV_FAIL_ON_ERROR) )
CODECOV_ARGS+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
CODECOV_ARGS+=( $(k_arg PARENT_SHA) $(v_arg PARENT_SHA))
CODECOV_ARGS+=( $(k_arg PR) $(v_arg PR))
CODECOV_ARGS+=( $(k_arg SHA) $(v_arg SHA))
CODECOV_ARGS+=( $(k_arg SLUG) $(v_arg SLUG))
# Args for create report
CODECOV_ARGS+=( $(k_arg CODE) $(v_arg CODE))
# Args for do upload
CODECOV_ARGS+=( $(k_arg ENV) $(v_arg ENV))
OLDIFS=$IFS;IFS=,
CODECOV_ARGS+=( $(k_arg BRANCH) $(v_arg BRANCH))
CODECOV_ARGS+=( $(k_arg BUILD) $(v_arg BUILD))
CODECOV_ARGS+=( $(k_arg BUILD_URL) $(v_arg BUILD_URL))
CODECOV_ARGS+=( $(k_arg DIR) $(v_arg DIR))
CODECOV_ARGS+=( $(write_bool_args CODECOV_DISABLE_FILE_FIXES) )
CODECOV_ARGS+=( $(write_bool_args CODECOV_DISABLE_SEARCH) )
CODECOV_ARGS+=( $(write_bool_args CODECOV_DRY_RUN) )
if [ -n "$CODECOV_EXCLUDES" ];
then
  for directory in $CODECOV_EXCLUDES; do
    CODECOV_ARGS+=( "--exclude" "$directory" )
  done
fi
if [ -n "$CODECOV_FILES" ];
then
  for file in $CODECOV_FILES; do
    CODECOV_ARGS+=( "--file" "$file" )
  done
fi
if [ -n "$CODECOV_FLAGS" ];
then
  for flag in $CODECOV_FLAGS; do
    CODECOV_ARGS+=( "--flag" "$flag" )
  done
fi
CODECOV_ARGS+=( $(k_arg GCOV_ARGS) $(v_arg GCOV_ARGS))
CODECOV_ARGS+=( $(k_arg GCOV_EXECUTABLE) $(v_arg GCOV_EXECUTABLE))
CODECOV_ARGS+=( $(k_arg GCOV_IGNORE) $(v_arg GCOV_IGNORE))
CODECOV_ARGS+=( $(k_arg GCOV_INCLUDE) $(v_arg GCOV_INCLUDE))
CODECOV_ARGS+=( $(write_bool_args CODECOV_HANDLE_NO_REPORTS_FOUND) )
CODECOV_ARGS+=( $(write_bool_args CODECOV_RECURSE_SUBMODULES) )
CODECOV_ARGS+=( $(k_arg JOB_CODE) $(v_arg JOB_CODE))
CODECOV_ARGS+=( $(write_bool_args CODECOV_LEGACY) )
if [ -n "$CODECOV_NAME" ];
then
  CODECOV_ARGS+=( "--name" "$CODECOV_NAME" )
fi
CODECOV_ARGS+=( $(k_arg NETWORK_FILTER) $(v_arg NETWORK_FILTER))
CODECOV_ARGS+=( $(k_arg NETWORK_PREFIX) $(v_arg NETWORK_PREFIX))
CODECOV_ARGS+=( $(k_arg NETWORK_ROOT_FOLDER) $(v_arg NETWORK_ROOT_FOLDER))
if [ -n "$CODECOV_PLUGINS" ];
then
  for plugin in $CODECOV_PLUGINS; do
    CODECOV_ARGS+=( "--plugin" "$plugin" )
  done
fi
CODECOV_ARGS+=( $(k_arg REPORT_TYPE) $(v_arg REPORT_TYPE))
CODECOV_ARGS+=( $(k_arg SWIFT_PROJECT) $(v_arg SWIFT_PROJECT))
IFS=$OLDIFS
elif [ "$CODECOV_RUN_CMD" == "empty-upload" ]; then
CODECOV_ARGS+=( $(k_arg BRANCH) $(v_arg BRANCH))
CODECOV_ARGS+=( $(write_bool_args CODECOV_FAIL_ON_ERROR) )
CODECOV_ARGS+=( $(write_bool_args CODECOV_FORCE) )
CODECOV_ARGS+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
CODECOV_ARGS+=( $(k_arg PARENT_SHA) $(v_arg PARENT_SHA))
CODECOV_ARGS+=( $(k_arg PR) $(v_arg PR))
CODECOV_ARGS+=( $(k_arg SHA) $(v_arg SHA))
CODECOV_ARGS+=( $(k_arg SLUG) $(v_arg SLUG))
elif [ "$CODECOV_RUN_CMD" == "pr-base-picking" ]; then
CODECOV_ARGS+=( $(k_arg BASE_SHA) $(v_arg BASE_SHA))
CODECOV_ARGS+=( $(k_arg PR) $(v_arg PR))
CODECOV_ARGS+=( $(k_arg SLUG) $(v_arg SLUG))
CODECOV_ARGS+=( $(k_arg SERVICE) $(v_arg SERVICE))
elif [ "$CODECOV_RUN_CMD" == "send-notifications" ]; then
CODECOV_ARGS+=( $(k_arg SHA) $(v_arg SHA))
CODECOV_ARGS+=( $(write_bool_args CODECOV_FAIL_ON_ERROR) )
CODECOV_ARGS+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
CODECOV_ARGS+=( $(k_arg SLUG) $(v_arg SLUG))
else
  exit_if_error "Invalid run command specified: $CODECOV_RUN_CMD"
  exit
fi
unset NODE_OPTIONS
# github.com/codecov/uploader/issues/475
if [ -n "$CODECOV_TOKEN_VAR" ];
then
  token="$(eval echo \$$CODECOV_TOKEN_VAR)"
else
  token="$(eval echo $CODECOV_TOKEN)"
fi
say "$g ->$x Token length: ${#token}"
token_str=""
token_arg=()
if [ -n "$token" ];
then
  token_str+=" -t <redacted>"
  token_arg+=( " -t " "$token")
fi
say "$g==>$x Running $CODECOV_RUN_CMD"
say "      $b$CODECOV_COMMAND $(echo "${CODECOV_CLI_ARGS[@]}") $CODECOV_RUN_CMD$token_str $(echo "${CODECOV_ARGS[@]}")$x"
if ! $CODECOV_COMMAND \
  ${CODECOV_CLI_ARGS[*]} \
  ${CODECOV_RUN_CMD} \
  ${token_arg[*]} \
  "${CODECOV_ARGS[@]}";
then
  exit_if_error "Failed to run $CODECOV_RUN_CMD"
fi
