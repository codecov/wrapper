#!/usr/bin/env bash
CC_WRAPPER_VERSION="0.0.10"
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
y="\033[0;33m"  # warnings
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
say "$g ->$x$b CC_VERSION$x = $CC_VERSION"
say "$g ->$x$b CC_FAIL_ON_ERROR$x = $CC_FAIL_ON_ERROR"
say
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
cc_filename="cc"
[[ $cc_os == "windows" ]] && cc_filename+=".exe"
export cc_filename=${cc_filename}
[[ $cc_os == "macos" ]]  && \
  ! command -v gpg 2>&1 >/dev/null && \
  HOMEBREW_NO_AUTO_UPDATE=1 brew install gpg
cc_url="https://cli.cc.io"
cc_url="$cc_url/${CC_VERSION}"
cc_url="$cc_url/${cc_os}/${cc_filename}"
say "$g ->$x Downloading $b${cc_url}$x"
curl -Os $cc_url
say "$g==>$x Finishing downloading $b${cc_os}:${CC_VERSION}$x"
say " "
CC_PUBLIC_PGP_KEY=$(curl https://keybase.io/ccsecurity/pgp_keys.asc)
echo "${CC_PUBLIC_PGP_KEY}"  | \
  gpg --no-default-keyring --import
# One-time step
say "$g==>$x Verifying GPG signature integrity"
sha_url="https://cli.cc.io"
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
cc_cli_args=""
if [ -n "$CC_AUTO_LOAD_PARAMS_FROM" ];
then
  cc_cli_args+=" --auto-load-params-from ${CC_AUTO_LOAD_PARAMS_FROM}"
fi
if [ -n "$CC_ENTERPRISE_URL" ];
then
  cc_cli_args+=" --enterprise-url ${CC_ENTERPRISE_URL}"
fi
unset CC_YML_PATH
if [ -n "$CC_YML_PATH" ];
then
  cc_cli_args+=" --cc-yml-path ${CC_YML_PATH}"
fi
cc_create_commit_args=()
if [ -n "$CC_BRANCH" ];
then
  cc_create_commit_args+=( " --branch " "${CC_BRANCH}" )
fi
if [ "$CC_FAIL_ON_ERROR" = "true" ];
then
  cc_create_commit_args+=( " --fail-on-error" )
fi
if [ -n "$CC_GIT_SERVICE" ];
then
  cc_create_commit_args+=( " --git-service " "${CC_GIT_SERVICE}" )
fi
if [ -n "$CC_PARENT_SHA" ];
then
  cc_create_commit_args+=( " --parent-sha " "${CC_PARENT_SHA}" )
fi
if [ -n "$CC_PULL_REQUEST" ];
then
  cc_create_commit_args+=( " --pr " "${CC_PULL_REQUEST}" )
fi
if [ -n "$CC_SHA" ];
then
  cc_create_commit_args+=( " --sha " "${CC_SHA}" )
fi
if [ -n "$CC_SLUG" ];
then
  cc_create_commit_args+=( " --slug " "${CC_SLUG}" )
fi
cc_create_report_args=()
if [ -n "$CC_CODE" ];
then
  cc_create_report_args+=( " --code " "${CC_CODE}" )
fi
if [ "$CC_FAIL_ON_ERROR" = "true" ];
then
  cc_create_report_args+=( " --fail-on-error" )
fi
if [ -n "$CC_GIT_SERVICE" ];
then
  cc_create_report_args+=( " --git-service " "${CC_GIT_SERVICE}" )
fi
if [ -n "$CC_PULL_REQUEST" ];
then
  cc_create_report_args+=( " --pr " "${CC_PULL_REQUEST}" )
fi
if [ -n "$CC_SHA" ];
then
  cc_create_report_args+=( " --sha " "${CC_SHA}" )
fi
if [ -n "$CC_SLUG" ];
then
  cc_create_report_args+=( " --slug " "${CC_SLUG}" )
fi
cc_do_upload_args=()
OLDIFS=$IFS;IFS=,
if [ -n "$CC_BRANCH" ];
then
  cc_do_upload_args+=( " --branch " "${CC_BRANCH}" )
fi
if [ -n "$CC_BUILD" ];
then
  cc_do_upload_args+=( " --build " "${CC_BUILD}" )
fi
if [ -n "$CC_BUILD_URL" ];
then
  cc_do_upload_args+=( " --build-url " "${CC_BUILD_URL}" )
fi
if [ -n "$CC_CODE" ];
then
  cc_do_upload_args+=( " --code " "${CC_CODE}" )
fi
if [ "$CC_DISABLE_FILE_FIXES" = "true" ];
then
  cc_do_upload_args+=( " --disable-file-fixes" )
fi
if [ "$CC_DISABLE_SEARCH" = "true" ];
then
  cc_do_upload_args+=( " --disable-search" )
fi
if [ "$CC_DRY_RUN" = "true" ];
then
  cc_do_upload_args+=( " --dry-run" )
fi
if [ -n "$CC_ENV" ];
then
  cc_do_upload_args+=( " --env " "${CC_ENV}" )
fi
if [ -n "$CC_EXCLUDE_DIRS" ];
then
  for directory in $CC_EXCLUDE_DIRS; do
    cc_do_upload_args+=( " --exclude " "$directory" )
  done
fi
if [ "$CC_FAIL_ON_ERROR" = "true" ];
then
  cc_do_upload_args+=( " --fail-on-error" )
fi
if [ -n "$CC_FILES" ];
then
  for file in $CC_FILES; do
    cc_do_upload_args+=( " --file " "$file" )
  done
fi
if [ -n "$CC_FLAGS" ];
then
  for flag in $CC_FLAGS; do
    cc_do_upload_args+=( " --flag " "$flag" )
  done
fi
if [ -n "$CC_GIT_SERVICE" ];
then
  cc_do_upload_args+=( " --git-service " "${CC_GIT_SERVICE}" )
fi
if [ "$CC_HANDLE_NO_REPORTS_FOUND" = "true" ];
then
  cc_do_upload_args+=( " --handle-no-reports-found" )
fi
if [ -n "$CC_JOB_CODE" ];
then
  cc_do_upload_args+=( " --job-code " "${CC_JOB_CODE}" )
fi
if [ "$CC_LEGACY" = "true" ];
then
  cc_do_upload_args+=( " --legacy" )
fi
if [ -n "$CC_NAME" ];
then
  cc_do_upload_args+=( " --name " "${CC_NAME}" )
fi
if [ -n "$CC_NETWORK_FILTER" ];
then
  cc_do_upload_args+=( " --network-filter " "${CC_NETWORK_FILTER}" )
fi
if [ -n "$CC_NETWORK_PREFIX" ];
then
  cc_do_upload_args+=( " --network-prefix " "${CC_NETWORK_PREFIX}" )
fi
if [ -n "$CC_NETWORK_ROOT_FOLDER" ];
then
  cc_do_upload_args+=( " --network-root-folder " "${CC_NETWORK_ROOT_FOLDER}" )
fi
if [ -n "$CC_PLUGINS" ];
then
  for plugin in $CC_PLUGINS; do
    cc_do_upload_args+=( " --plugin " "$plugin" )
  done
fi
if [ -n "$CC_PULL_REQUEST" ];
then
  cc_do_upload_args+=( " --pr " "${CC_PULL_REQUEST}" )
fi
if [ -n "$CC_REPORT_TYPE" ];
then
  cc_do_upload_args+=( " --report-type " "${CC_REPORT_TYPE}" )
fi
if [ -n "$CC_SEARCH_DIR" ];
then
  cc_do_upload_args+=( " --coverage-files-search-root-folder " "${CC_SEARCH_DIR}" )
fi
if [ -n "$CC_SHA" ];
then
  cc_do_upload_args+=( " --sha " "${CC_SHA}" )
fi
if [ -n "$CC_SLUG" ];
then
  cc_do_upload_args+=( " --slug " "${CC_SLUG}" )
fi
IFS=$OLDIFS
unset NODE_OPTIONS
# See https://github.com/cc/uploader/issues/475
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
if [ -n $token ];
then
  token_str+=" -t <redacted>"
  token_arg+=( " -t " "$token")
fi
#create commit
say "$g==>$x Running create-commit"
say "      $b./$cc_filename$cc_cli_args create-commit$token_str$cc_create_commit_args$x"
if ! ./$cc_filename \
  $cc_cli_args \
  create-commit \
  ${token_arg[@]} \
  ${cc_create_commit_args[@]};
then
  exit_if_error "Failed to create-commit"
fi
say " "
#create report
say "$g==>$x Running create-report"
say "      $b./$cc_filename$cc_cli_args create-commit$token_str$cc_create_report_args$x"
if ! ./$cc_filename \
  $cc_cli_args \
  create-report \
  ${token_arg[@]} \
  ${cc_create_report_args[@]};
then
  exit_if_error "Failed to create-report"
fi
say " "
#upload reports
# alpine doesn't allow for indirect expansion
say "$g==>$x Running do-upload"
say "      $b./$cc_filename$cc_cli_args do-upload$token_str$cc_do_upload_args$x"
if ! ./$cc_filename \
  $cc_cli_args \
  do-upload \
  ${token_arg[@]} \
  ${cc_do_upload_args[@]};
then
  exit_if_error "Failed to upload"
fi
