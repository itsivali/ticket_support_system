#!/bin/bash

function show_platform_menu() {
    if ! command -v flutter &> /dev/null; then
        echo "Error: Flutter not found in PATH"
        return 1
    }

    # Store original command
    local original_command="$@"

    if [[ "$1" == "run" && $# -eq 1 ]]; then
        echo "Select platform to run:"
        echo "1) Web (Chrome)"
        echo "2) Linux Desktop"
        read -p "Enter choice (1-2): " choice

        case $choice in
            1)
                if ! command -v google-chrome-stable &> /dev/null; then
                    echo "Error: Chrome not found"
                    return 1
                fi
                export CHROME_EXECUTABLE=/usr/bin/google-chrome-stable
                command flutter run -d chrome --web-port=3001 --web-browser-flag="--disable-web-security"
                ;;
            2)
                command flutter config --enable-linux-desktop
                command flutter run -d linux
                ;;
            *)
                echo "Invalid choice"
                return 1
                ;;
        esac
    else
        command flutter "$@"
    fi
}

show_platform_menu "$@"