home_dir=$(bash -c "cd ~$(printf %q $USER) && pwd")
CODECOV_BASH_ENV="${CODECOV_BASH_ENV:-$home_dir/.bashrc}"

CODECOV_WRAPPER_VERSION="0.0.1"
CODECOV_VERSION="${CODECOV_VERSION:-latest}"

codecov_vars=(
  CODECOV_WRAPPER_VERSION
  CODECOV_VERSION
)

echo "Running wrapper version $CODECOV_WRAPPER_VERSION"
for value in "${codecov_vars[@]}"
do
  echo "==> \$$value=${!value}"
  export $value=${!value}
done

echo "Finishing setting env variables"
echo ""
