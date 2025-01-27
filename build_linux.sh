#!/bin/bash

set -e # Exit on error

# Check dependencies
check_dependency() {
    if ! command -v $1 &> /dev/null; then
        echo "Error: $1 is not installed"
        exit 1
    fi
}

check_dependency flutter
check_dependency cmake
check_dependency ninja

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Ensure Flutter is configured for Linux
flutter config --enable-linux-desktop

# Clean and prepare
echo "Cleaning and preparing..."
flutter clean

# Generate Linux files
echo "Generating Linux files..."
flutter create --platforms=linux .

# Ensure linux directory exists
mkdir -p "${SCRIPT_DIR}/linux"

# Configure build
echo "Configuring build..."
flutter build linux --debug

# Create build directory
echo "Creating build directory..."
mkdir -p "${SCRIPT_DIR}/build/linux"

# Run CMake
echo "Running CMake..."
cd "${SCRIPT_DIR}/build/linux"
cmake ../../linux \
    -DCMAKE_BUILD_TYPE=Debug \
    -G Ninja

# Build
echo "Building..."
ninja -v

# Set permissions
echo "Setting permissions..."
chmod +x "${SCRIPT_DIR}/build/linux/x64/debug/bundle/ticket_support_system"

echo "Build completed!"