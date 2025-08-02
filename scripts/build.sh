#!/bin/bash
set -e

echo "--- Starting Build ---"
echo "Commit Hash: ${COMMIT_HASH}"
echo "OS: ${OS}"
echo "Architecture: ${ARCH}"
echo "Glibc Version: ${GLIBC_VERSION}"

# TODO: Add platform-specific build commands here

# Create a dummy artifact for demonstration


cargo build --release

echo "--- Packaging Artifact ---"

# Determine platform and extension
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

# Define artifact name, removing 'v' from version tag for consistency
VERSION_TAG_CLEANED=${VERSION_TAG#v}
ARTIFACT_NAME="conflux-v${VERSION_TAG_CLEANED}-${ARCH}-${PLATFORM}"
ARCHIVE_NAME="${ARTIFACT_NAME}.${ARCHIVE_EXT}"

# Create a directory for the artifact
mkdir -p "target/release/${ARTIFACT_NAME}"

# Move the binary into the directory
mv "target/release/${BINARY_NAME}" "target/release/${ARTIFACT_NAME}/"

# Create the archive from the directory
if [ "${OS}" == "windows" ]; then
  cd "target/release"
  zip -r "${ARCHIVE_NAME}" "${ARTIFACT_NAME}"
  cd ../..
else
  cd "target/release"
  tar -czvf "${ARCHIVE_NAME}" "${ARTIFACT_NAME}"
  cd ../..
fi

echo "Created archive: target/release/${ARCHIVE_NAME}"






echo "--- Build Finished ---"