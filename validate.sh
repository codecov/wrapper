echo "${CODECOV_PUBLIC_PGP_KEY}" | \
  gpg --no-default-keyring --import
# One-time step
sha_url="https://cli.codecov.io"
sha_url="${sha_url}/${codecov_version}/${codecov_os}"
sha_url="${sha_url}/${codecov_filename}.SHA256SUM"
echo "Downloading ${sha_url}"
curl -Os "$sha_url"
curl -Os "${sha_url}.sig"

gpg --verify "${codecov_filename}.SHA256SUM.sig" "${codecov_filename}.SHA256SUM"
shasum -a 256 -c "${codecov_filename}.SHA256SUM" || \
  sha256sum -c "${codecov_filename}.SHA256SUM"
echo ""
