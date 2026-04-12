import AppKit
import HotKey

@MainActor
final class HotkeyManager {
    private var hotKey: HotKey?
    var onToggle: (() -> Void)?

    func register() {
        let hk = HotKey(key: .v, modifiers: [.command, .shift])
        hk.keyDownHandler = { [weak self] in
            self?.onToggle?()
        }
        hotKey = hk
    }

    func unregister() {
        hotKey = nil
    }

    static func checkAccessibilityPermission() -> Bool {
        return AXIsProcessTrusted()
    }

    static func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    static func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}
