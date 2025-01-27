#!/bin/bash

check_platform() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "2"  
    elif [[ "$OSTYPE" == "msys" ]]; then
        echo "3"  
    else
        echo "1"  
    fi
}

check_dependencies() {
    if ! command -v flutter &> /dev/null; then
        echo "Error: Flutter not found"
        return 1
    fi
    return 0
}

run_web() {
    export CHROME_EXECUTABLE=/usr/bin/google-chrome-stable
    command flutter run -d chrome --web-port=3001
}

run_linux() {
    command flutter config --enable-linux-desktop
    command flutter run -d linux
}

run_windows() {
    command flutter config --enable-windows-desktop
    command flutter run -d windows
}

main() {
    if ! check_dependencies; then
        exit 1
    }

    if [[ "$1" == "run" ]]; then
        platform=$(check_platform)
        case $platform in
            1) run_web ;;
            2) run_linux ;;
            3) run_windows ;;
        esac
    else
        command flutter "$@"
    fi
}

main "$@"