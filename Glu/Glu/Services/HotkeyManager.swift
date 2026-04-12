import AppKit
import HotKey

@MainActor
final class HotkeyManager {
    private var hotKey: HotKey?
    var onToggle: (() -> Void)?

    func register() {
        let hk = HotKey(key: .v, modifiers: [.command, .shift])
        hk.keyDownHandler = { [weak self] in
            NSLog("[Glu] Hotkey fired")
            self?.onToggle?()
        }
        hotKey = hk
        NSLog("[Glu] Hotkey registered: Cmd+Shift+V")
    }

    func unregister() {
        hotKey = nil
    }

    static func checkAccessibilityPermission() -> Bool {
        let trusted = AXIsProcessTrusted()
        NSLog("[Glu] Accessibility check: \(trusted)")
        return trusted
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
