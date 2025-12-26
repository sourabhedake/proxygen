BASE_DIR="/home/http/FCGI_ADSERVER/Build"
SRC_DIR="$(pwd)"
TARGET_DIR="${BASE_DIR}/proxygen"
BACKUP_DIR="${BASE_DIR}/proxygen_m2"

mkdir -p "${BASE_DIR}"

# Safety check: prevent self-move
if [ "${SRC_DIR}" = "${TARGET_DIR}" ]; then
  echo "ERROR: Source and target directories are the same. Aborting."
  exit 1
fi

if [ -d "${BACKUP_DIR}" ]; then
  echo "Backup exists (${BACKUP_DIR}). Replacing target with new proxygen."

  # Remove existing target if present
  if [ -d "${TARGET_DIR}" ]; then
    echo "Removing existing target: ${TARGET_DIR}"
    rm -rf "${TARGET_DIR}"
  fi

else
  # Backup existing proxygen only once
  if [ -d "${TARGET_DIR}" ]; then
    echo "Creating backup → proxygen_m2"
    mv "${TARGET_DIR}" "${BACKUP_DIR}"
  else
    echo "No existing proxygen directory to backup"
  fi
fi

# Move new proxygen into place
echo "Installing new proxygen from ${SRC_DIR}"
mv "${SRC_DIR}" "${TARGET_DIR}"

echo "Proxygen Installed Successfully"
