#!/bin/sh
# Builds DiskSpace.app into ~/Applications and starts it.
set -e
cd "$(dirname "$0")"
APP=~/Applications/DiskSpace.app
mkdir -p "$APP/Contents/MacOS"
swiftc -O main.swift -o "$APP/Contents/MacOS/DiskSpace"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleIdentifier</key><string>io.shickshack.diskspace</string>
  <key>CFBundleName</key><string>DiskSpace</string>
  <key>CFBundleExecutable</key><string>DiskSpace</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>LSUIElement</key><true/>
</dict></plist>
PLIST
codesign --force -s - "$APP"
pkill -x DiskSpace || true
open "$APP"
