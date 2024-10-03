#!/usr/bin/env bash
CC_WRAPPER_VERSION="0.0.13"
say() {
  echo -e "$1"
}
exit_if_error() {
  say "$r==> $1$x"
  if [ $CC_FAIL_ON_ERROR = true ];
  then
     say "$r    Exiting...$x"
     exit 1;
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
say
if [ -n "$CC_BINARY" ];
then
  if [ -f "$CC_BINARY" ];
  then
    cc_filename=$CC_BINARY
  else
    exit_if_error "Could not find binary file $CC_BINARY"
  fi
else
  family=$(uname -s | tr '[:upper:]' '[:lower:]')
  cc_os="windows"
  [[ $family == "darwin" ]] && cc_os="macos"
  [[ $family == "linux" ]] && cc_os="linux"
  [[ $cc_os == "linux" ]] && \
    osID=$(grep -e "^ID=" /etc/os-release | cut -c4-)
  [[ $osID == "alpine" ]] && cc_os="alpine"
  [[ $(arch) == "aarch64" && $family == "linux" ]] && cc_os+="-arm64"
  say "$g==>$x Detected $b${cc_os}$x"
  export cc_os=${cc_os}
  export cc_version=${CC_VERSION}
  cc_filename="codecov"
  [[ $cc_os == "windows" ]] && cc_filename+=".exe"
  export cc_filename=${cc_filename}
  [[ $cc_os == "macos" ]]  && \
    ! command -v gpg 2>&1 >/dev/null && \
    HOMEBREW_NO_AUTO_UPDATE=1 brew install gpg
  cc_url="https://cli.codecov.io"
  cc_url="$cc_url/${CC_VERSION}"
  cc_url="$cc_url/${cc_os}/${cc_filename}"
  say "$g ->$x Downloading $b${cc_url}$x"
  curl -Os $cc_url
  say "$g==>$x Finishing downloading $b${cc_os}:${CC_VERSION}$x"
  say " "
fi
if [ "$CC_SKIP_VALIDATION" = "true" ] || [ -n "$CC_BINARY" ];
then
  say "$r==>$x Bypassing validation as requested by user"
else
CC_PUBLIC_PGP_KEY=$(curl https://keybase.io/codecovsecurity/pgp_keys.asc)
  echo "${CC_PUBLIC_PGP_KEY}"  | \
    gpg --no-default-keyring --import
  # One-time step
  say "$g==>$x Verifying GPG signature integrity"
  sha_url="https://cli.codecov.io"
  sha_url="${sha_url}/${cc_version}/${cc_os}"
  sha_url="${sha_url}/${cc_filename}.SHA256SUM"
  say "$g ->$x Downloading $b${sha_url}$x"
  say "$g ->$x Downloading $b${sha_url}.sig$x"
  say " "
  curl -Os "$sha_url"
  curl -Os "${sha_url}.sig"
  if ! gpg --verify "${cc_filename}.SHA256SUM.sig" "${cc_filename}.SHA256SUM";
  then
    exit_if_error "Could not verify signature. Please contact Codecov if problem continues"
  fi
  if ! (shasum -a 256 -c "${cc_filename}.SHA256SUM" || \
    sha256sum -c "${cc_filename}.SHA256SUM");
  then
    exit_if_error "Could not verify SHASUM. Please contact Codecov if problem continues"
  fi
  say "$g==>$x CLI integrity verified"
  say
fi
cc_cli_args=()
if [ -n "$CC_AUTO_LOAD_PARAMS_FROM" ];
then
  cc_cli_args+=( " --auto-load-params-from " "${CC_AUTO_LOAD_PARAMS_FROM}" )
fi
if [ -n "$CC_ENTERPRISE_URL" ];
then
  cc_cli_args+=( " --enterprise-url " "${CC_ENTERPRISE_URL}" )
fi
unset CC_YML_PATH
if [ -n "$CC_YML_PATH" ];
then
  cc_cli_args+=( " --codecov-yml-path " "${CC_YML_PATH}" )
fi
cc_cc_args=()
if [ "$CC_FAIL_ON_ERROR" = "true" ];
then
  cc_cc_args+=( " --fail-on-error" )
fi
if [ -n "$CC_GIT_SERVICE" ];
then
  cc_cc_args+=( " --git-service " "${CC_GIT_SERVICE}" )
fi
if [ -n "$CC_PARENT_SHA" ];
then
  cc_cc_args+=( " --parent-sha " "${CC_PARENT_SHA}" )
fi
if [ -n "$CC_PULL_REQUEST" ];
then
  cc_cc_args+=( " --pr " "${CC_PULL_REQUEST}" )
fi
if [ -n "$CC_SHA" ];
then
  cc_cc_args+=( " --sha " "${CC_SHA}" )
fi
if [ -n "$CC_SLUG" ];
then
  cc_cc_args+=( " --slug " "${CC_SLUG}" )
fi
cc_create_report_args=()
if [ -n "$CC_CODE" ];
then
  cc_cr_args+=( " --code " "${CC_CODE}" )
fi
if [ "$CC_FAIL_ON_ERROR" = "true" ];
then
  cc_cr_args+=( " --fail-on-error" )
fi
if [ -n "$CC_GIT_SERVICE" ];
then
  cc_cr_args+=( " --git-service " "${CC_GIT_SERVICE}" )
fi
if [ -n "$CC_PULL_REQUEST" ];
then
  cc_cr_args+=( " --pr " "${CC_PULL_REQUEST}" )
fi
if [ -n "$CC_SHA" ];
then
  cc_cr_args+=( " --sha " "${CC_SHA}" )
fi
if [ -n "$CC_SLUG" ];
then
  cc_cr_args+=( " --slug " "${CC_SLUG}" )
fi
cc_du_args=()
OLDIFS=$IFS;IFS=,
if [ -n "$CC_BRANCH" ];
then
  cc_du_args+=( " --branch " "${CC_BRANCH}" )
fi
if [ -n "$CC_BUILD" ];
then
  cc_du_args+=( " --build " "${CC_BUILD}" )
fi
if [ -n "$CC_BUILD_URL" ];
then
  cc_du_args+=( " --build-url " "${CC_BUILD_URL}" )
fi
if [ -n "$CC_CODE" ];
then
  cc_du_args+=( " --code " "${CC_CODE}" )
fi
if [ "$CC_DISABLE_FILE_FIXES" = "true" ];
then
  cc_du_args+=( " --disable-file-fixes" )
fi
if [ "$CC_DISABLE_SEARCH" = "true" ];
then
  cc_du_args+=( " --disable-search" )
fi
if [ "$CC_DRY_RUN" = "true" ];
then
  cc_du_args+=( " --dry-run" )
fi
if [ -n "$CC_ENV" ];
then
  cc_du_args+=( " --env " "${CC_ENV}" )
fi
if [ -n "$CC_EXCLUDE_DIRS" ];
then
  for directory in $CC_EXCLUDE_DIRS; do
    cc_du_args+=( " --exclude " "$directory" )
  done
fi
if [ "$CC_FAIL_ON_ERROR" = "true" ];
then
  cc_du_args+=( " --fail-on-error" )
fi
if [ -n "$CC_FILES" ];
then
  for file in $CC_FILES; do
    cc_du_args+=( " --file " "$file" )
  done
fi
if [ -n "$CC_FLAGS" ];
then
  for flag in $CC_FLAGS; do
    cc_du_args+=( " --flag " "$flag" )
  done
fi
if [ -n "$CC_GIT_SERVICE" ];
then
  cc_du_args+=( " --git-service " "${CC_GIT_SERVICE}" )
fi
if [ "$CC_HANDLE_NO_REPORTS_FOUND" = "true" ];
then
  cc_du_args+=( " --handle-no-reports-found" )
fi
if [ -n "$CC_JOB_CODE" ];
then
  cc_du_args+=( " --job-code " "${CC_JOB_CODE}" )
fi
if [ "$CC_LEGACY" = "true" ];
then
  cc_du_args+=( " --legacy" )
fi
if [ -n "$CC_NAME" ];
then
  cc_du_args+=( " --name " "${CC_NAME}" )
fi
if [ -n "$CC_NETWORK_FILTER" ];
then
  cc_du_args+=( " --network-filter " "${CC_NETWORK_FILTER}" )
fi
if [ -n "$CC_NETWORK_PREFIX" ];
then
  cc_du_args+=( " --network-prefix " "${CC_NETWORK_PREFIX}" )
fi
if [ -n "$CC_NETWORK_ROOT_FOLDER" ];
then
  cc_du_args+=( " --network-root-folder " "${CC_NETWORK_ROOT_FOLDER}" )
fi
if [ -n "$CC_PLUGINS" ];
then
  for plugin in $CC_PLUGINS; do
    cc_du_args+=( " --plugin " "$plugin" )
  done
fi
if [ -n "$CC_PULL_REQUEST" ];
then
  cc_du_args+=( " --pr " "${CC_PULL_REQUEST}" )
fi
if [ -n "$CC_REPORT_TYPE" ];
then
  cc_du_args+=( " --report-type " "${CC_REPORT_TYPE}" )
fi
if [ -n "$CC_SEARCH_DIR" ];
then
  cc_du_args+=( " --coverage-files-search-root-folder " "${CC_SEARCH_DIR}" )
fi
if [ -n "$CC_SHA" ];
then
  cc_du_args+=( " --sha " "${CC_SHA}" )
fi
if [ -n "$CC_SLUG" ];
then
  cc_du_args+=( " --slug " "${CC_SLUG}" )
fi
IFS=$OLDIFS
unset NODE_OPTIONS
# See https://github.com/codecov/uploader/issues/475
chmod +x $cc_filename
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
say "$g==>$x Running create-commit"
say "      $b./$cc_filename$cc_cli_args create-commit$token_str$cc_cc_args$x"
if ! ./$cc_filename \
  ${cc_cli_args[@]} \
  create-commit \
  ${token_arg[@]} \
  ${cc_cc_args[@]};
then
  exit_if_error "Failed to create-commit"
fi
say " "
say "$g==>$x Running create-report"
say "      $b./$cc_filename$cc_cli_args create-commit$token_str$cc_cr_args$x"
if ! ./$cc_filename \
  ${cc_cli_args[@]} \
  create-report \
  ${token_arg[@]} \
  ${cc_cr_args[@]};
then
  exit_if_error "Failed to create-report"
fi
say " "
say "$g==>$x Running do-upload"
say "      $b./$cc_filename$cc_cli_args do-upload$token_str$cc_du_args$x"
if ! ./$cc_filename \
  ${cc_cli_args[@]} \
  do-upload \
  ${token_arg[@]} \
  ${cc_du_args[@]};
then
  exit_if_error "Failed to upload"
fi
