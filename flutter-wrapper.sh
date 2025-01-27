#!/bin/bash

# Function to find project root
find_project_root() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/pubspec.yaml" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# Function to show platform selection menu
show_platform_menu() {
    echo "Select platform to run:"
    echo "1) Web (Chrome)"
    echo "2) Linux Desktop"
    read -p "Enter choice (1-2): " choice

    case $choice in
        1)
            export CHROME_EXECUTABLE=/usr/bin/google-chrome-stable
            command flutter run -d chrome --web-port=3001 --web-browser-flag="--disable-web-security"
            ;;
        2)
            command flutter run -d linux
            ;;
        *)
            echo "Invalid choice"
            return 1
            ;;
    esac
}

# Main wrapper function
flutter_wrapper() {
    if [[ "$1" == "run" && $# -eq 1 ]]; then
        show_platform_menu
    else
        command flutter "$@"
    fi
}

# Execute the wrapper
flutter_wrapper "$@"