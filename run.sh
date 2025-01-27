#!/bin/bash

# Function to run web version
run_web() {
    export CHROME_EXECUTABLE=/usr/bin/google-chrome-stable
    flutter run -d chrome --web-port=3001 --web-browser-flag="--disable-web-security"
}

# Function to run Linux version
run_linux() {
    flutter config --enable-linux-desktop
    flutter build linux
    ./build/linux/x64/debug/bundle/ticket_support_system
}

# Check if script is being sourced directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Select platform to run:"
    echo "1) Web (Chrome)"
    echo "2) Linux Desktop"
    read -p "Enter choice (1-2): " choice

    case $choice in
        1)
            run_web
            ;;
        2)
            run_linux
            ;;
        *)
            echo "Invalid choice"
            exit 1
            ;;
    esac
fi