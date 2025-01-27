#!/bin/bash

# Find Flutter project root directory
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

# Check required dependencies
check_dependencies() {
    if ! command -v flutter &> /dev/null; then
        echo "Error: Flutter SDK not found"
        return 1
    fi
    if ! command -v google-chrome-stable &> /dev/null; then
        echo "Warning: google-chrome-stable not found (needed for web)"
    fi
    return 0
}

# Run web version
run_web() {
    export CHROME_EXECUTABLE=/usr/bin/google-chrome-stable
    flutter run -d chrome --web-port=3001
}

# Run Linux version
run_linux() {
    flutter config --enable-linux-desktop
    flutter run -d linux
}

# Main execution
main() {
    local project_root
    project_root=$(find_project_root)
    
    if [[ $? -ne 0 ]]; then
        echo "Error: Not in a Flutter project directory"
        exit 1
    fi

    cd "$project_root" || exit 1

    if ! check_dependencies; then
        exit 1
    fi

    # Clean and get dependencies
    flutter clean
    flutter pub get

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
}

main "$@"