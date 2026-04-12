import AppKit

final class PanelWindow: NSPanel {
    static let panelHeight: CGFloat = 380

    init() {
        let screen = NSScreen.main ?? NSScreen.screens.first!
        let frame = NSRect(
            x: screen.frame.origin.x,
            y: screen.frame.origin.y - Self.panelHeight,
            width: screen.frame.width,
            height: Self.panelHeight
        )

        super.init(
            contentRect: frame,
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )

        level = .floating
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        isMovable = false
        isMovableByWindowBackground = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        hidesOnDeactivate = false
    }

    override var canBecomeKey: Bool { true }
}
