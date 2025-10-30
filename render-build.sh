#!/usr/bin/env bash
# Exit on any error
set -e

# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Enable Flutter web
flutter config --enable-web

# Get dependencies
flutter pub get

# Build for web
flutter build web
