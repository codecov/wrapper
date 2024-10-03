#!/usr/bin/env bash

CODECOV_WRAPPER_VERSION="0.0.6"

say() {
  echo -e "$1"
}

exit_if_error() {
  say "$r==> $1$x"
  if [ $CODECOV_FAIL_ON_ERROR = true ];
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
                           $r Wrapper-$CODECOV_WRAPPER_VERSION$x
                                  "

CODECOV_VERSION="${CODECOV_VERSION:-latest}"
CODECOV_FAIL_ON_ERROR="${CODECOV_FAIL_ON_ERROR:-false}"
say "$g ->$x$b CODECOV_VERSION$x = $CODECOV_VERSION"
say "$g ->$x$b CODECOV_FAIL_ON_ERROR$x = $CODECOV_FAIL_ON_ERROR"
say

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

cat ./pgp_keys.asc  | \
  gpg --no-default-keyring --import
# One-time step
say "$g==>$x Verifying GPG signature integrity"
sha_url="https://cli.codecov.io"
sha_url="${sha_url}/${codecov_version}/${codecov_os}"
sha_url="${sha_url}/${codecov_filename}.SHA256SUM"
say "$g ->$x Downloading $b${sha_url}$x"
say "$g ->$x Downloading $b${sha_url}.sig$x"
say " "

curl -Os "$sha_url"
curl -Os "${sha_url}.sig"

if ! gpg --verify "${codecov_filename}.SHA256SUM.sig" "${codecov_filename}.SHA256SUM";
then
  exit_if_error "Could not verify signature. Please contact Codecov if problem continues"
fi

if ! shasum -a 256 -c "${codecov_filename}.SHA256SUM" && \
  ! sha256sum -c "${codecov_filename}.SHA256SUM";
then
  exit_if_error "Could not verify SHASUM. Please contact Codecov if problem continues"
fi
say "$g==>$x CLI integrity verified"
say


codecov_cli_args=""

if [ -n "$CODECOV_AUTO_LOAD_PARAMS_FROM" ];
then
  codecov_cli_args+=" --auto-load-params-from ${CODECOV_AUTO_LOAD_PARAMS_FROM}"
fi

if [ -n "$CODECOV_ENTERPRISE_URL" ];
then
  codecov_cli_args+=" --enterprise-url ${CODECOV_ENTERPRISE_URL}"
fi

unset CODECOV_YML_PATH
if [ -n "$CODECOV_YML_PATH" ];
then
  codecov_cli_args+=" --codecov-yml-path ${CODECOV_YML_PATH}"
fi


codecov_create_commit_args=()

if [ -n "$CODECOV_BRANCH" ];
then
  codecov_create_commit_args+=( " --branch " "${CODECOV_BRANCH}" )
fi

if [ "$CODECOV_FAIL_ON_ERROR" = "true" ];
then
  codecov_create_commit_args+=( " --fail-on-error" )
fi

if [ -n "$CODECOV_GIT_SERVICE" ];
then
  codecov_create_commit_args+=( " --git-service " "${CODECOV_GIT_SERVICE}" )
fi

if [ -n "$CODECOV_PARENT_SHA" ];
then
  codecov_create_commit_args+=( " --parent-sha " "${CODECOV_PARENT_SHA}" )
fi

if [ -n "$CODECOV_PULL_REQUEST" ];
then
  codecov_create_commit_args+=( " --pr " "${CODECOV_PULL_REQUEST}" )
fi

if [ -n "$CODECOV_SHA" ];
then
  codecov_create_commit_args+=( " --sha " "${CODECOV_SHA}" )
fi

if [ -n "$CODECOV_SLUG" ];
then
  codecov_create_commit_args+=( " --slug " "${CODECOV_SLUG}" )
fi

codecov_create_report_args=()

if [ -n "$CODECOV_CODE" ];
then
  codecov_create_report_args+=( " --code " "${CODECOV_CODE}" )
fi

if [ "$CODECOV_FAIL_ON_ERROR" = "true" ];
then
  codecov_create_report_args+=( " --fail-on-error" )
fi

if [ -n "$CODECOV_GIT_SERVICE" ];
then
  codecov_create_report_args+=( " --git-service " "${CODECOV_GIT_SERVICE}" )
fi

if [ -n "$CODECOV_PULL_REQUEST" ];
then
  codecov_create_report_args+=( " --pr " "${CODECOV_PULL_REQUEST}" )
fi

if [ -n "$CODECOV_SHA" ];
then
  codecov_create_report_args+=( " --sha " "${CODECOV_SHA}" )
fi

if [ -n "$CODECOV_SLUG" ];
then
  codecov_create_report_args+=( " --slug " "${CODECOV_SLUG}" )
fi

codecov_do_upload_args=()

OLDIFS=$IFS;IFS=,

if [ -n "$CODECOV_BRANCH" ];
then
  codecov_do_upload_args+=( " --branch " "${CODECOV_BRANCH}" )
fi

if [ -n "$CODECOV_BUILD" ];
then
  codecov_do_upload_args+=( " --build " "${CODECOV_BUILD}" )
fi

if [ -n "$CODECOV_BUILD_URL" ];
then
  codecov_do_upload_args+=( " --build-url " "${CODECOV_BUILD_URL}" )
fi

if [ -n "$CODECOV_CODE" ];
then
  codecov_do_upload_args+=( " --code " "${CODECOV_CODE}" )
fi

if [ "$CODECOV_DISABLE_FILE_FIXES" = "true" ];
then
  codecov_do_upload_args+=( " --disable-file-fixes" )
fi

if [ "$CODECOV_DISABLE_SEARCH" = "true" ];
then
  codecov_do_upload_args+=( " --disable-search" )
fi

if [ "$CODECOV_DRY_RUN" = "true" ];
then
  codecov_do_upload_args+=( " --dry-run" )
fi

if [ -n "$CODECOV_ENV" ];
then
  codecov_do_upload_args+=( " --env " "${CODECOV_ENV}" )
fi

if [ -n "$CODECOV_EXCLUDE_DIRS" ];
then
  for directory in $CODECOV_EXCLUDE_DIRS; do
    codecov_do_upload_args+=( " --exclude " "$directory" )
  done
fi

if [ "$CODECOV_FAIL_ON_ERROR" = "true" ];
then
  codecov_do_upload_args+=( " --fail-on-error" )
fi

if [ -n "$CODECOV_FILES" ];
then
  for file in $CODECOV_FILES; do
    codecov_do_upload_args+=( " --file " "$file" )
  done
fi

if [ -n "$CODECOV_FLAGS" ];
then
  for flag in $CODECOV_FLAGS; do
    codecov_do_upload_args+=( " --flag " "$flag" )
  done
fi

if [ -n "$CODECOV_GIT_SERVICE" ];
then
  codecov_do_upload_args+=( " --git-service " "${CODECOV_GIT_SERVICE}" )
fi

if [ "$CODECOV_HANDLE_NO_REPORTS_FOUND" = "true" ];
then
  codecov_do_upload_args+=( " --handle-no-reports-found" )
fi

if [ -n "$CODECOV_JOB_CODE" ];
then
  codecov_do_upload_args+=( " --job-code " "${CODECOV_JOB_CODE}" )
fi

if [ "$CODECOV_LEGACY" = "true" ];
then
  codecov_do_upload_args+=( " --legacy" )
fi

if [ -n "$CODECOV_NAME" ];
then
  codecov_do_upload_args+=( " --name " "${CODECOV_NAME}" )
fi

if [ -n "$CODECOV_NETWORK_FILTER" ];
then
  codecov_do_upload_args+=( " --network-filter " "${CODECOV_NETWORK_FILTER}" )
fi

if [ -n "$CODECOV_NETWORK_PREFIX" ];
then
  codecov_do_upload_args+=( " --network-prefix " "${CODECOV_NETWORK_PREFIX}" )
fi

if [ -n "$CODECOV_NETWORK_ROOT_FOLDER" ];
then
  codecov_do_upload_args+=( " --network-root-folder " "${CODECOV_NETWORK_ROOT_FOLDER}" )
fi

if [ -n "$CODECOV_PLUGINS" ];
then
  for plugin in $CODECOV_PLUGINS; do
    codecov_do_upload_args+=( " --plugin " "$plugin" )
  done
fi

if [ -n "$CODECOV_PULL_REQUEST" ];
then
  codecov_do_upload_args+=( " --pr " "${CODECOV_PULL_REQUEST}" )
fi

if [ -n "$CODECOV_REPORT_TYPE" ];
then
  codecov_do_upload_args+=( " --report-type " "${CODECOV_REPORT_TYPE}" )
fi

if [ -n "$CODECOV_SEARCH_DIR" ];
then
  codecov_do_upload_args+=( " --coverage-files-search-root-folder " "${CODECOV_SEARCH_DIR}" )
fi

if [ -n "$CODECOV_SHA" ];
then
  codecov_do_upload_args+=( " --sha " "${CODECOV_SHA}" )
fi

if [ -n "$CODECOV_SLUG" ];
then
  codecov_do_upload_args+=( " --slug " "${CODECOV_SLUG}" )
fi

IFS=$OLDIFS

unset NODE_OPTIONS
# See https://github.com/codecov/uploader/issues/475

chmod +x $codecov_filename

token="$(eval echo $CODECOV_TOKEN)"
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
say "      $b./$codecov_filename$codecov_cli_args create-commit$token_str$codecov_create_commit_args$x"

if ! ./$codecov_filename \
  $codecov_cli_args \
  create-commit \
  ${token_arg[@]} \
  ${codecov_create_commit_args[@]};
then
  exit_if_error "Failed to create-commit"
fi

say " "

#create report
say "$g==>$x Running create-report"
say "      $b./$codecov_filename$codecov_cli_args create-commit$token_str$codecov_create_report_args$x"

if ! ./$codecov_filename \
  $codecov_cli_args \
  create-report \
  ${token_arg[@]} \
  ${codecov_create_report_args[@]};
then
  exit_if_error "Failed to create-report"
fi

say " "

#upload reports
# alpine doesn't allow for indirect expansion
say "$g==>$x Running do-upload"
say "      $b./$codecov_filename$codecov_cli_args do-upload$token_str$codecov_do_upload_args$x"

if ! ./$codecov_filename \
  $codecov_cli_args \
  do-upload \
  ${token_arg[@]} \
  ${codecov_do_upload_args[@]};
then
  exit_if_error "Failed to upload"
fi
