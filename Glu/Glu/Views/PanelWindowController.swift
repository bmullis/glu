import AppKit
import SwiftUI
import SwiftData

@MainActor
final class PanelWindowController {
    private var panel: PanelWindow?
    private var eventMonitor: Any?
    private var keyMonitor: Any?
    private(set) var isVisible = false

    private var navigateHandler: ((_ direction: Int) -> Void)?
    private var selectHandler: (() -> Void)?

    var onItemSelected: ((ClipboardEntry) -> Void)?

    func toggle(modelContext: ModelContext) {
        if isVisible {
            hide()
        } else {
            show(modelContext: modelContext)
        }
    }

    func show(modelContext: ModelContext) {
        guard !isVisible else { return }

        let panel = PanelWindow()
        self.panel = panel

        let contentView = PanelContentView(
            modelContext: modelContext,
            onSelect: { [weak self] entry in
                self?.onItemSelected?(entry)
            },
            onNavigate: { [weak self] navigate, select in
                self?.navigateHandler = navigate
                self?.selectHandler = select
            }
        )
        .modelContainer(modelContext.container)

        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = panel.contentView?.bounds ?? .zero
        hostingView.autoresizingMask = [.width, .height]
        panel.contentView = hostingView

        positionPanel(panel)

        // Start off-screen for slide-up animation
        let screen = NSScreen.main ?? NSScreen.screens.first!
        var startFrame = panel.frame
        startFrame.origin.y = screen.frame.origin.y - PanelWindow.panelHeight
        panel.setFrame(startFrame, display: false)
        panel.orderFrontRegardless()
        panel.makeKey()

        // Slide up
        var endFrame = startFrame
        endFrame.origin.y = screen.frame.origin.y
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().setFrame(endFrame, display: true)
        }

        isVisible = true
        startEventMonitors()
    }

    func hide() {
        guard isVisible, let panel = panel else { return }
        isVisible = false
        stopEventMonitors()
        navigateHandler = nil
        selectHandler = nil

        let screen = NSScreen.main ?? NSScreen.screens.first!
        var endFrame = panel.frame
        endFrame.origin.y = screen.frame.origin.y - PanelWindow.panelHeight

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().setFrame(endFrame, display: true)
        }, completionHandler: { [weak self] in
            panel.orderOut(nil)
            self?.panel = nil
        })
    }

    private func positionPanel(_ panel: PanelWindow) {
        let screen = NSScreen.main ?? NSScreen.screens.first!
        let frame = NSRect(
            x: screen.frame.origin.x,
            y: screen.frame.origin.y,
            width: screen.frame.width,
            height: PanelWindow.panelHeight
        )
        panel.setFrame(frame, display: false)
    }

    private func startEventMonitors() {
        // Click outside to dismiss
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor in
                self?.hide()
            }
        }

        // Keyboard: Escape, arrow keys, Enter
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }

            switch event.keyCode {
            case 53: // Escape
                self.hide()
                return nil
            case 123: // Left arrow
                self.navigateHandler?(-1)
                return nil
            case 124: // Right arrow
                self.navigateHandler?(1)
                return nil
            case 36: // Return/Enter
                self.selectHandler?()
                return nil
            default:
                return event
            }
        }
    }

    private func stopEventMonitors() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
    }
}
