# DiskSpace

Free disk space in your Mac menu bar, at a glance.

Click the icon for a small panel: free space, a usage bar (green / orange / red), used of total, and purgeable space. Numbers match Finder's "Available". Refreshes every minute and whenever you open it.

## Build

Requires macOS 13+ and the Xcode command line tools.

```sh
./build.sh
```

This compiles `main.swift` into `~/Applications/DiskSpace.app` and launches it. No Dock icon; quit from the menu.

To start it at login, add `~/Applications/DiskSpace.app` under System Settings → General → Login Items.
