#!/bin/bash

# Script per build di tutte le piattaforme
# Closer Acireale Flutter - Build All Platforms

set -e

echo "🚀 Starting build process for all platforms..."

# Cleanup
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Analyze and test
echo "🔍 Running code analysis..."
flutter analyze

echo "🧪 Running tests..."
flutter test

# Build Web
echo "📱 Building for Web..."
flutter build web --release
echo "✅ Web build completed"

# Build Android APK
echo "🤖 Building Android APK..."
flutter build apk --release
echo "✅ Android APK build completed"

# Build Android App Bundle (for Play Store)
echo "📦 Building Android App Bundle..."
flutter build appbundle --release
echo "✅ Android App Bundle build completed"

# Build Linux (if on Linux)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "🐧 Building for Linux..."
    flutter build linux --release
    echo "✅ Linux build completed"
fi

# Build macOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Building for macOS..."
    flutter build macos --release
    echo "✅ macOS build completed"
    
    echo "📱 Building for iOS..."
    flutter build ios --release --no-codesign
    echo "✅ iOS build completed"
fi

# Build Windows (if on Windows)
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "🪟 Building for Windows..."
    flutter build windows --release
    echo "✅ Windows build completed"
fi

echo "🎉 All builds completed successfully!"
echo ""
echo "📦 Build outputs:"
echo "  Web: build/web/"
echo "  Android APK: build/app/outputs/flutter-apk/app-release.apk"
echo "  Android Bundle: build/app/outputs/bundle/release/app-release.aab"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "  Linux: build/linux/x64/release/bundle/"
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "  macOS: build/macos/Build/Products/Release/closer_acireale_flutter.app"
    echo "  iOS: build/ios/Release-iphoneos/Runner.app"
fi

if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "  Windows: build/windows/runner/Release/"
fi

echo ""
echo "🚀 Ready for deployment!"