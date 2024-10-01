echo "Codecov wrapper version: ${CODECOV_WRAPPER_VERSION}"

family=$(uname -s | tr '[:upper:]' '[:lower:]')
codecov_os="windows"
[[ $family == "darwin" ]] && codecov_os="macos"

[[ $family == "linux" ]] && codecov_os="linux"
[[ $codecov_os == "linux" ]] && \
  osID=$(grep -e "^ID=" /etc/os-release | cut -c4-)
[[ $osID == "alpine" ]] && codecov_os="alpine"
[[ $(arch) == "aarch64" && $family == "linux" ]] && codecov_os+="-arm64"
echo "Detected ${codecov_os}"
export codecov_os=${codecov_os}
export codecov_version=${CODECOV_VERSION}

codecov_filename="codecov"
[[ $codecov_os == "windows" ]] && codecov_filename+=".exe"
export codecov_filename=${codecov_filename}
[[ $codecov_os == "macos" ]] && \
  HOMEBREW_NO_AUTO_UPDATE=1 brew install gpg
codecov_url="https://cli.codecov.io"
codecov_url="$codecov_url/${CODECOV_VERSION}"
codecov_url="$codecov_url/${codecov_os}/${codecov_filename}"
echo "Downloading ${codecov_url}"
curl -Os $codecov_url

echo "Finishing downloading CLI ${CODECOV_VERSION}"
echo ""
