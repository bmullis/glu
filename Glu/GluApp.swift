import SwiftUI
import SwiftData
import ServiceManagement

@main
struct GluApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let modelContainer: ModelContainer

    init() {
        let container: ModelContainer
        do {
            container = try ModelContainer(for: ClipboardEntry.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
        self.modelContainer = container
        appDelegate.setup(container: container)
    }

    var body: some Scene {
        MenuBarExtra("Glu", systemImage: "clipboard") {
            MenuBarView()
                .modelContainer(modelContainer)
        }
        Settings {
            EmptyView()
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var clipboardMonitor: ClipboardMonitor?
    private var hotkeyManager: HotkeyManager?
    private var panelController: PanelWindowController?
    private var pasteService: PasteService?
    private var container: ModelContainer?
    let themeManager = ThemeManager()

    func setup(container: ModelContainer) {
        self.container = container
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let container = self.container else { return }
        let context = container.mainContext

        themeManager.startObservingAppearance()

        let monitor = ClipboardMonitor(modelContext: context)
        monitor.start()
        clipboardMonitor = monitor

        let paste = PasteService(clipboardMonitor: monitor, modelContext: context)
        pasteService = paste

        let panel = PanelWindowController()
        panel.themeManager = themeManager
        panel.onItemSelected = { entry in
            paste.paste(entry: entry)
            panel.hideForPaste()
            paste.simulatePaste()
        }
        panelController = panel

        let hotkey = HotkeyManager()
        hotkey.onToggle = { [weak self] in
            self?.panelController?.toggle(modelContext: context)
        }
        hotkey.register()
        hotkeyManager = hotkey

        if !HotkeyManager.checkAccessibilityPermission() {
            showAccessibilityPrompt()
        }
    }

    private func showAccessibilityPrompt() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "Glu needs Accessibility access to simulate paste keystrokes and register the global hotkey. Please grant access in System Settings."
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Later")
        alert.alertStyle = .informational

        if alert.runModal() == .alertFirstButtonReturn {
            HotkeyManager.openAccessibilitySettings()
        }
    }
}

struct MenuBarView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var launchAtLogin = false

    var body: some View {
        Text("Glu Clipboard Manager v1.0")
            .font(.headline)

        Divider()

        Button("Clear History") {
            clearHistory()
        }

        Toggle("Launch at Login", isOn: $launchAtLogin)
            .onChange(of: launchAtLogin) { _, newValue in
                setLaunchAtLogin(newValue)
            }

        Divider()

        Button("About Glu") {
            showAbout()
        }

        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }

    private func clearHistory() {
        do {
            try modelContext.delete(model: ClipboardEntry.self)
            try modelContext.save()
        } catch {
            // Silently handle
        }
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            // Silently handle
        }
    }

    private func showAbout() {
        NSApplication.shared.orderFrontStandardAboutPanel(options: [
            .applicationName: "Glu",
            .applicationVersion: "1.0",
            .version: "1",
        ])
    }
}
