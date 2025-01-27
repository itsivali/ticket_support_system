#!/bin/bash

set -e # Exit on error

# Function to check command status
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed"
        exit 1
    fi
}

# Check dependencies
for dep in flutter cmake ninja; do
    if ! command -v $dep &> /dev/null; then
        echo "Error: $dep is not installed"
        exit 1
    fi
done

# Get absolute path
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Configure Flutter
echo "Configuring Flutter..."
flutter config --enable-linux-desktop
check_status "Flutter configuration"

# Clean previous build
echo "Cleaning..."
flutter clean
check_status "Flutter clean"

# Generate Linux platform files
echo "Generating Linux files..."
flutter create --platforms=linux .
check_status "Platform generation"

# Prepare Linux build
echo "Preparing Linux build..."
flutter build linux --debug
check_status "Flutter build"

# Setup build directory
echo "Setting up build directory..."
rm -rf "${SCRIPT_DIR}/build"
mkdir -p "${SCRIPT_DIR}/build/linux"

# Generate CMake files
echo "Generating CMake files..."
cd "${SCRIPT_DIR}/build/linux"
cmake "${SCRIPT_DIR}/linux" \
    -DCMAKE_BUILD_TYPE=Debug \
    -G Ninja
check_status "CMake configuration"

# Build with Ninja
echo "Building with Ninja..."
ninja -v
check_status "Ninja build"

# Verify and set permissions
EXECUTABLE="${SCRIPT_DIR}/build/linux/x64/debug/bundle/ticket_support_system"
if [ -f "$EXECUTABLE" ]; then
    echo "Setting executable permissions..."
    chmod +x "$EXECUTABLE"
    echo "Build completed successfully!"
else
    echo "Error: Executable not found"
    exit 1
fi