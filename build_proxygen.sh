set -euo pipefail

# Resolve base directory safely
BASE_DIR="$(pwd)"

# Validate BASE_DIR
if [ -z "${BASE_DIR}" ] || [ "${BASE_DIR}" = "/" ]; then
  echo "ERROR: Invalid BASE_DIR='${BASE_DIR}'"
  exit 1
fi

# Ensure BASE_DIR is writable
[ -w "${BASE_DIR}" ] || {
  echo "ERROR: No write permission on ${BASE_DIR}"
  exit 1
}

# Guard against _build being a file
if [ -e "${BASE_DIR}/_build" ] && [ ! -d "${BASE_DIR}/_build" ]; then
  echo "ERROR: ${BASE_DIR}/_build exists but is not a directory"
  exit 1
fi

SCRATCH_DIR="/tmp/scratch_space"
INSTALL_DIR="/tmp/proxygen_install"

echo "Base directory: ${BASE_DIR}"

# Clean & prepare temp dirs
rm -rf "${SCRATCH_DIR}" "${INSTALL_DIR}"
mkdir -p "${SCRATCH_DIR}" "${INSTALL_DIR}"

echo "Running getdeps.sh with scratch-path=${SCRATCH_DIR}, install-prefix=${INSTALL_DIR}, no-tests, build-type=Release"
"${BASE_DIR}/getdeps.sh" \
  --scratch-path="${SCRATCH_DIR}" \
  --install-prefix="${INSTALL_DIR}" \
  --no-tests \
  --build-type=Release

echo "Building proxygen with parallel jobs"
cd "${BASE_DIR}/proxygen"

./build.sh -j "$(nproc)" --no-install-dependencies --no-tests

# Move built artifacts safely using absolute paths
echo "Reorganizing build artifacts"

rsync -av "${BASE_DIR}/_build/proxygen/" "${BASE_DIR}/proxygen/_build/"

# Cleanup
rm -rf "${BASE_DIR}/_build" "${SCRATCH_DIR}" "${INSTALL_DIR}"

# Move _build to parent level
mv "${BASE_DIR}/proxygen/_build" "${BASE_DIR}/_build"

echo "Setup completed successfully"
