#!/usr/bin/env bash
CC_WRAPPER_VERSION="0.2.0"
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
say "     _____          _
    / ____|        | |
   | |     ___   __| | ___  ___ _____   __
   | |    / _ \\ / _\` |/ _ \\/ __/ _ \\ \\ / /
   | |___| (_) | (_| |  __/ (_| (_) \\ V /
    \\_____\\___/ \\__,_|\\___|\\___\\___/ \\_/
                           $r Wrapper-$CC_WRAPPER_VERSION$x
                                  "
CC_VERSION="${CC_VERSION:-latest}"
CC_FAIL_ON_ERROR="${CC_FAIL_ON_ERROR:-false}"
CC_RUN_CMD="${CC_RUN_CMD:-upload-coverage}"
if [ -n "$CC_BINARY" ];
then
  if [ -f "$CC_BINARY" ];
  then
    cfilename=$CC_BINARY
    ccommand=$CC_BINARY
  else
    exit_if_error "Could not find binary file $CC_BINARY"
  fi
elif [ "$CC_USE_PYPI" == "true" ];
then
  if ! pip install codecov-cli"$([ "$CC_VERSION" == "latest" ] && echo "" || echo "==$CC_VERSION" )"; then
    exit_if_error "Could not install via pypi."
    exit
  fi
  ccommand="codecovcli"
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
  cfilename="codecov"
  [[ $CC_OS == "windows" ]] && cfilename+=".exe"
  ccommand="./$cfilename"
  [[ $CC_OS == "macos" ]]  && \
    ! command -v gpg 2>&1 >/dev/null && \
    HOMEBREW_NO_AUTO_UPDATE=1 brew install gpg
  curl="https://cli.codecov.io"
  curl="$curl/${CC_VERSION}"
  curl="$curl/${CC_OS}/${cfilename}"
  say "$g ->$x Downloading $b${curl}$x"
  curl -O --retry 5 --retry-delay 2 "$curl"
  say "$g==>$x Finishing downloading $b${CC_OS}:${CC_VERSION}$x"
  version_url="https://cli.codecov.io/api/${CC_OS}/${CC_VERSION}"
  version=$(curl -s "$version_url" -H "Accept:application/json" | tr \{ '\n' | tr , '\n' | tr \} '\n' | grep "\"version\"" | awk  -F'"' '{print $4}' | tail -1)
  say "      Version: $b$version$x"
  say " "
fi
if [ "$CC_SKIP_VALIDATION" == "true" ] || [ -n "$CC_BINARY" ] || [ "$CC_USE_PYPI" == "true" ];
then
  say "$r==>$x Bypassing validation..."
else
CC_PUBLIC_PGP_KEY=$(curl -s https://keybase.io/codecovsecurity/pgp_keys.asc)
  echo "${CC_PUBLIC_PGP_KEY}"  | \
    gpg --no-default-keyring --import
  # One-time step
  say "$g==>$x Verifying GPG signature integrity"
  sha_url="https://cli.codecov.io"
  sha_url="${sha_url}/${CC_VERSION}/${CC_OS}"
  sha_url="${sha_url}/${cfilename}.SHA256SUM"
  say "$g ->$x Downloading $b${sha_url}$x"
  say "$g ->$x Downloading $b${sha_url}.sig$x"
  say " "
  curl -Os --retry 5 --retry-delay 2 --connect-timeout 2 "$sha_url"
  curl -Os --retry 5 --retry-delay 2 --connect-timeout 2 "${sha_url}.sig"
  if ! gpg --verify "${cfilename}.SHA256SUM.sig" "${cfilename}.SHA256SUM";
  then
    exit_if_error "Could not verify signature. Please contact Codecov if problem continues"
  fi
  if ! (shasum -a 256 -c "${cfilename}.SHA256SUM" 2>/dev/null || \
    sha256sum -c "${cfilename}.SHA256SUM");
  then
    exit_if_error "Could not verify SHASUM. Please contact Codecov if problem continues"
  fi
  say "$g==>$x CLI integrity verified"
  say
  chmod +x "$ccommand"
fi
if [ -n "$CC_BINARY_LOCATION" ];
then
  mkdir -p "$CC_BINARY_LOCATION" && mv "$cfilename" $_
  say "$g==>$x Codecov binary moved to ${CC_BINARY_LOCATION}"
fi
if [ "$CC_DOWNLOAD_ONLY" = "true" ];
then
  say "$g==>$x Codecov download only called. Exiting..."
fi
ccli_args=()
ccli_args+=( $(k_arg AUTO_LOAD_PARAMS_FROM) $(v_arg AUTO_LOAD_PARAMS_FROM))
ccli_args+=( $(k_arg ENTERPRISE_URL) $(v_arg ENTERPRISE_URL))
if [ -n "$CC_YML_PATH" ]
then
  ccli_args+=( "--codecov-yml-path" )
  ccli_args+=( "$CC_YML_PATH" )
fi
ccli_args+=( $(write_bool_args CC_DISABLE_TELEM) )
ccli_args+=( $(write_bool_args CC_VERBOSE) )
if [ -n "$CC_TOKEN_VAR" ];
then
  token="$(eval echo \$$CC_TOKEN_VAR)"
else
  token="$(eval echo $CC_TOKEN)"
fi
say "$g ->$x Token of length ${#token} detected"
token_str=""
token_arg=()
if [ -n "$token" ];
then
  token_str+=" -t <redacted>"
  token_arg+=( " -t " "$token")
fi
if [ "$CC_RUN_CMD" == "upload-coverage" ]; then
cargs=()
# Args for create commit
cargs+=( $(write_bool_args CC_FAIL_ON_ERROR) )
cargs+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
cargs+=( $(k_arg PARENT_SHA) $(v_arg PARENT_SHA))
cargs+=( $(k_arg PR) $(v_arg PR))
cargs+=( $(k_arg SHA) $(v_arg SHA))
cargs+=( $(k_arg SLUG) $(v_arg SLUG))
# Args for create report
cargs+=( $(k_arg CODE) $(v_arg CODE))
# Args for do upload
cargs+=( $(k_arg ENV) $(v_arg ENV))
OLDIFS=$IFS;IFS=,
cargs+=( $(k_arg BRANCH) $(v_arg BRANCH))
cargs+=( $(k_arg BUILD) $(v_arg BUILD))
cargs+=( $(k_arg BUILD_URL) $(v_arg BUILD_URL))
cargs+=( $(k_arg DIR) $(v_arg DIR))
cargs+=( $(write_bool_args CC_DISABLE_FILE_FIXES) )
cargs+=( $(write_bool_args CC_DISABLE_SEARCH) )
cargs+=( $(write_bool_args CC_DRY_RUN) )
if [ -n "$CC_EXCLUDES" ];
then
  for directory in $CC_EXCLUDES; do
    cargs+=( "--exclude" "$directory" )
  done
fi
if [ -n "$CC_FILES" ];
then
  for file in $CC_FILES; do
    cargs+=( "--file" "$file" )
  done
fi
if [ -n "$CC_FLAGS" ];
then
  for flag in $CC_FLAGS; do
    cargs+=( "--flag" "$flag" )
  done
fi
cargs+=( $(k_arg GCOV_ARGS) $(v_arg GCOV_ARGS))
cargs+=( $(k_arg GCOV_EXECUTABLE) $(v_arg GCOV_EXECUTABLE))
cargs+=( $(k_arg GCOV_IGNORE) $(v_arg GCOV_IGNORE))
cargs+=( $(k_arg GCOV_INCLUDE) $(v_arg GCOV_INCLUDE))
cargs+=( $(write_bool_args CC_HANDLE_NO_REPORTS_FOUND) )
cargs+=( $(write_bool_args CC_RECURSE_SUBMODULES) )
cargs+=( $(k_arg JOB_CODE) $(v_arg JOB_CODE))
cargs+=( $(write_bool_args CC_LEGACY) )
if [ -n "$CC_NAME" ];
then
  cargs+=( "--name" "$CC_NAME" )
fi
cargs+=( $(k_arg NETWORK_FILTER) $(v_arg NETWORK_FILTER))
cargs+=( $(k_arg NETWORK_PREFIX) $(v_arg NETWORK_PREFIX))
cargs+=( $(k_arg NETWORK_ROOT_FOLDER) $(v_arg NETWORK_ROOT_FOLDER))
if [ -n "$CC_PLUGINS" ];
then
  for plugin in $CC_PLUGINS; do
    cargs+=( "--plugin" "$plugin" )
  done
fi
cargs+=( $(k_arg REPORT_TYPE) $(v_arg REPORT_TYPE))
cargs+=( $(k_arg SWIFT_PROJECT) $(v_arg SWIFT_PROJECT))
IFS=$OLDIFS
elif [ "$CC_RUN_CMD" == "empty-upload" ]; then
cargs=()
cargs+=( $(k_arg BRANCH) $(v_arg BRANCH))
cargs+=( $(write_bool_args CC_FAIL_ON_ERROR) )
cargs+=( $(write_bool_args CC_FORCE) )
cargs+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
cargs+=( $(k_arg PARENT_SHA) $(v_arg PARENT_SHA))
cargs+=( $(k_arg PR) $(v_arg PR))
cargs+=( $(k_arg SHA) $(v_arg SHA))
cargs+=( $(k_arg SLUG) $(v_arg SLUG))
elif [ "$CC_RUN_CMD" == "pr-base-picking" ]; then
cargs=()
cargs+=( $(k_arg BASE_SHA) $(v_arg BASE_SHA))
cargs+=( $(k_arg PR) $(v_arg PR))
cargs+=( $(k_arg SLUG) $(v_arg SLUG))
cargs+=( $(k_arg SERVICE) $(v_arg SERVICE))
elif [ "$CC_RUN_CMD" == "send-notifications" ]; then
cargs=()
cargs+=( $(k_arg SHA) $(v_arg SHA))
cargs+=( $(write_bool_args CC_FAIL_ON_ERROR) )
cargs+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
cargs+=( $(k_arg SLUG) $(v_arg SLUG))
else
  exit_if_error "Invalid run command specified: $CC_RUN_CMD"
  exit
fi
unset NODE_OPTIONS
# https://github.com/codecov/uploader/issues/475
say "$g==>$x Running $CC_RUN_CMD"
say "      $b$ccommand $(echo "${ccli_args[@]}") $CC_RUN_CMD$token_str $(echo "${cargs[@]}")$x"
if ! $ccommand \
  ${ccli_args[*]} \
  ${CC_RUN_CMD} \
  ${token_arg[*]} \
  "${cargs[@]}";
then
  exit_if_error "Failed to run $CC_RUN_CMD"
fi
