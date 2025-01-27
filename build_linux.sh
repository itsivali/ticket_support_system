#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Clean previous build
rm -rf "${SCRIPT_DIR}/build"

# Create build directory
mkdir -p "${SCRIPT_DIR}/build/linux"
cd "${SCRIPT_DIR}/build/linux"

# Configure and build
cmake "${SCRIPT_DIR}/linux" \
  -DCMAKE_BUILD_TYPE=Debug \
  -G Ninja

ninja

# Create symlinks if needed
if [ ! -d "${SCRIPT_DIR}/linux/flutter/ephemeral" ]; then
  mkdir -p "${SCRIPT_DIR}/linux/flutter/ephemeral"
fi

# Make the script executable
chmod +x "${SCRIPT_DIR}/build/linux/x64/debug/bundle/ticket_support_system"