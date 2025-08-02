#!/bin/bash
set -e

# --- Configuration ---
# These variables are expected to be passed in from the environment (e.g., GitHub Actions)
COMMIT_HASH=${COMMIT_HASH:?"COMMIT_HASH is not set"}
VERSION_TAG=${VERSION_TAG:?"VERSION_TAG is not set"}
OS=${OS:?"OS is not set"}
ARCH=${ARCH:?"ARCH is not set"}
GLIBC_VERSION=${GLIBC_VERSION:-"default"} # Default for non-Linux builds

# --- Helper Functions ---
log() {
  echo "--- $1 ---"
}

map_glibc_to_ubuntu() {
  case "$1" in
    "2.27")
      UBUNTU_VERSION="18.04"
      UBUNTU_CODENAME="bionic"
      ;;
    "2.31")
      UBUNTU_VERSION="20.04"
      UBUNTU_CODENAME="focal"
      ;;
    "2.35")
      UBUNTU_VERSION="22.04"
      UBUNTU_CODENAME="jammy"
      ;;
    "2.39")
      UBUNTU_VERSION="24.04"
      UBUNTU_CODENAME="noble"
      ;;
    *)
      echo "Error: Unsupported glibc version: $1" >&2
      exit 1
      ;;
  esac
}

# --- Main Build Logic ---
main() {
  log "Starting Build"
  echo "Commit Hash: ${COMMIT_HASH}"
  echo "Version Tag: ${VERSION_TAG}"
  echo "OS: ${OS}"
  echo "Architecture: ${ARCH}"
  echo "Glibc Version: ${GLIBC_VERSION}"

  if [ "${OS}" == "linux" ]; then
    log "Mapping Glibc to Ubuntu Version"
    map_glibc_to_ubuntu "${GLIBC_VERSION}"
    echo "Detected Ubuntu Version: ${UBUNTU_VERSION} (${UBUNTU_CODENAME})"

    log "Building Docker Image"
    DOCKERFILE_PATH="docker/${ARCH}.Dockerfile"
    docker build \
      --build-arg UBUNTU_VERSION="${UBUNTU_VERSION}" \
      --build-arg UBUNTU_CODENAME="${UBUNTU_CODENAME}" \
      -t "conflux-builder:${VERSION_TAG}" \
      -f "${DOCKERFILE_PATH}" .

    log "Running Build in Docker Container"
    # We mount the conflux-rust checkout into the container's workspace.
    # We also mount the builder repo's scripts directory to make them available inside the container.
    docker run --rm \
      -v "${GITHUB_WORKSPACE}/conflux-rust:/workspace" \
      -v "${GITHUB_WORKSPACE}/builder/scripts:/scripts" \
      -w /workspace \
      -e "VERSION_TAG=${VERSION_TAG}" \
      -e "OS=${OS}" \
      -e "ARCH=${ARCH}" \
      -e "GLIBC_VERSION=${GLIBC_VERSION}" \
      "conflux-builder:${VERSION_TAG}" \
      bash -c "cargo build --release && /usr/bin/env bash /scripts/package_artifact.sh"

  else
    log "Running Native Build for ${OS}"
    # For non-Linux builds, we assume the code is in the current directory
    # and scripts are in a subdirectory. This needs to match the checkout path in the workflow.
    (cd conflux-rust && cargo build --release && /usr/bin/env bash ../builder/scripts/package_artifact.sh)
  fi

  log "Build Finished"
}

# --- Script Entrypoint ---
main "$@"