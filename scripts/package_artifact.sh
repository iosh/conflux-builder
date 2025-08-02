#!/bin/bash
set -e

# This script is responsible for packaging the compiled binary into a distributable archive.
# It is designed to be run either natively or inside a Docker container.

log() {
  echo "--- $1 ---"
}

log "Packaging Artifact"

# --- Configuration ---
# These variables are expected to be passed in from the calling environment (build.sh).
VERSION_TAG=${VERSION_TAG:?"VERSION_TAG is not set"}
OS=${OS:?"OS is not set"}
ARCH=${ARCH:?"ARCH is not set"}
GLIBC_VERSION=${GLIBC_VERSION:-"default"}

# --- Determine Platform and Archive Details ---
if [ "${OS}" == "windows" ]; then
  BINARY_NAME="conflux.exe"
  PLATFORM="pc-windows-msvc"
  ARCHIVE_EXT="zip"
else
  BINARY_NAME="conflux"
  if [ "${OS}" == "macos" ]; then
    PLATFORM="apple-darwin"
  else
    PLATFORM="unknown-linux-gnu-glibc${GLIBC_VERSION}"
  fi
  ARCHIVE_EXT="tar.gz"
fi

# --- Define Artifact and Archive Names ---
VERSION_TAG_CLEANED=${VERSION_TAG#v}
ARTIFACT_NAME="conflux-v${VERSION_TAG_CLEANED}-${ARCH}-${PLATFORM}"
ARCHIVE_NAME="${ARTIFACT_NAME}.${ARCHIVE_EXT}"
ARTIFACT_DIR="target/release/${ARTIFACT_NAME}"

log "Creating artifact directory: ${ARTIFACT_DIR}"
mkdir -p "${ARTIFACT_DIR}"

log "Moving binary to artifact directory"
mv "target/release/${BINARY_NAME}" "${ARTIFACT_DIR}/"

log "Creating archive: ${ARCHIVE_NAME}"
cd target/release
if [ "${OS}" == "windows" ]; then
  zip -r "${ARCHIVE_NAME}" "${ARTIFACT_NAME}"
else
  tar -czvf "${ARCHIVE_NAME}" "${ARTIFACT_NAME}"
fi
cd ../..

log "Created archive: target/release/${ARCHIVE_NAME}"
# Output the archive name for the workflow to capture
echo "archive_name=${ARCHIVE_NAME}" >> $GITHUB_OUTPUT