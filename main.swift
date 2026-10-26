import AppKit
import SwiftUI

// Disk space at a glance in the menu bar. Numbers match Finder's "Available".
struct Stats {
    var name: String, total: Int64, free: Int64, purgeable: Int64
    var used: Int64 { total - free }
    var fraction: Double { Double(used) / Double(total) }
}

let fmt = ByteCountFormatter()
func size(_ b: Int64) -> String { fmt.string(fromByteCount: b) }

struct DiskView: View {
    let s: Stats
    var tint: Color { s.fraction > 0.9 ? .red : s.fraction > 0.75 ? .orange : .green }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(s.name).font(.caption).foregroundStyle(.secondary)
            Text("\(size(s.free)) free").font(.title2.bold())
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(.quaternary)
                    Capsule().fill(tint).frame(width: g.size.width * s.fraction)
                }
            }
            .frame(height: 8)
            Text("\(size(s.used)) used of \(size(s.total)) · \(Int(s.fraction * 100))%")
                .font(.callout)
            Divider()
            HStack {
                Text("Purgeable")
                Spacer()
                Text(size(s.purgeable)).monospacedDigit()
            }
            .font(.callout)
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .frame(width: 260)
    }
}

final class App: NSObject, NSApplicationDelegate, NSMenuDelegate {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let panel = NSMenuItem()

    func applicationDidFinishLaunching(_ n: Notification) {
        item.button?.image = NSImage(systemSymbolName: "internaldrive", accessibilityDescription: "Disk space")
        item.button?.imagePosition = .imageLeading
        let menu = NSMenu()
        menu.delegate = self
        menu.addItem(panel)
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        item.menu = menu
        refresh()
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in self?.refresh() }
    }

    func menuWillOpen(_ menu: NSMenu) { refresh() }

    func refresh() {
        let keys: Set<URLResourceKey> = [.volumeNameKey, .volumeTotalCapacityKey, .volumeAvailableCapacityKey,
                                         .volumeAvailableCapacityForImportantUsageKey]
        guard let v = try? URL(fileURLWithPath: "/").resourceValues(forKeys: keys),
              let total = v.volumeTotalCapacity.map(Int64.init),
              let strict = v.volumeAvailableCapacity.map(Int64.init),
              let free = v.volumeAvailableCapacityForImportantUsage else { return }
        let s = Stats(name: v.volumeName ?? "Disk", total: total, free: free, purgeable: max(free - strict, 0))

        item.button?.title = " " + size(free)
        let host = NSHostingView(rootView: DiskView(s: s))
        host.frame.size = host.fittingSize
        panel.view = host
    }
}

let app = NSApplication.shared
let delegate = App()
app.delegate = delegate
app.setActivationPolicy(.accessory) // menu bar only, no Dock icon
app.run()
