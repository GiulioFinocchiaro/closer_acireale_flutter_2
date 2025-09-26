#!/bin/bash

# Script di setup per ambiente di sviluppo
# Closer Acireale Flutter - Development Setup

set -e

echo "🛠️  Setting up Closer Acireale Flutter development environment..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first:"
    echo "   https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter is installed"

# Check Flutter doctor
echo "🔍 Running Flutter doctor..."
flutter doctor

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Enable all platforms
echo "🔧 Enabling all platforms..."
flutter config --enable-web
flutter config --enable-linux-desktop
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop

# Generate code if needed
echo "🔨 Generating code..."
if [ -f "build_runner.yaml" ]; then
    flutter packages pub run build_runner build
fi

# Setup IDE configurations
echo "⚙️  Setting up IDE configurations..."

# VSCode settings
if [ ! -d ".vscode" ]; then
    mkdir -p .vscode
fi

cat > .vscode/settings.json << EOL
{
    "dart.flutterSdkPath": null,
    "dart.lineLength": 100,
    "dart.previewFlutterUiGuides": true,
    "dart.previewFlutterUiGuidesCustomTracking": true,
    "editor.rulers": [100],
    "editor.formatOnSave": true,
    "dart.debugExternalPackageLibraries": false,
    "dart.debugSdkLibraries": false,
    "files.associations": {
        "*.dart": "dart"
    }
}
EOL

cat > .vscode/launch.json << EOL
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug (Chrome)",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart",
            "deviceId": "chrome",
            "args": ["--web-port", "3000"]
        },
        {
            "name": "Debug (Mobile)",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart"
        },
        {
            "name": "Profile",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart",
            "flutterMode": "profile"
        }
    ]
}
EOL

# Run tests to make sure everything works
echo "🧪 Running initial tests..."
flutter test

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "  1. Open the project in your IDE (VS Code recommended)"
echo "  2. Run 'flutter run -d chrome' for web development"
echo "  3. Run 'flutter run' for mobile development"
echo "  4. Check README.md for more information"
echo ""
echo "🚀 Happy coding!"