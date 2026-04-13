import SwiftUI
import AppKit

enum ThemeMode: String, CaseIterable {
    case system
    case light
    case dark

    var next: ThemeMode {
        switch self {
        case .system: return .light
        case .light: return .dark
        case .dark: return .system
        }
    }

    var iconName: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }
}

@MainActor
@Observable
final class ThemeManager {
    private static let defaultsKey = "glu.themeMode"

    var mode: ThemeMode {
        didSet {
            UserDefaults.standard.set(mode.rawValue, forKey: Self.defaultsKey)
        }
    }

    private(set) var isDark: Bool = true
    private var appearanceObservation: NSKeyValueObservation?

    init() {
        let stored = UserDefaults.standard.string(forKey: Self.defaultsKey)
        self.mode = stored.flatMap(ThemeMode.init(rawValue:)) ?? .system
        self.isDark = Self.resolveIsDark(mode: self.mode)
    }

    func startObservingAppearance() {
        guard appearanceObservation == nil else { return }
        isDark = Self.resolveIsDark(mode: mode)
        appearanceObservation = NSApp.observe(\.effectiveAppearance, options: [.new]) { [weak self] _, _ in
            Task { @MainActor in
                guard let self else { return }
                self.isDark = Self.resolveIsDark(mode: self.mode)
            }
        }
    }

    private static func resolveIsDark(mode: ThemeMode) -> Bool {
        switch mode {
        case .dark: return true
        case .light: return false
        case .system:
            guard let app = NSApp else { return true }
            return app.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        }
    }

    func toggle() {
        mode = mode.next
        isDark = Self.resolveIsDark(mode: mode)
    }

    // MARK: - Design Tokens
    //
    // Neumorphic palette reference:
    //   Light: base #e0e0e0 (0.878), light shadow #ffffff, dark shadow #bebebe (0.745)
    //   Dark:  base #2d2d2d (0.176), light shadow #383838 (0.22), dark shadow #222222 (0.133)

    var primaryBackground: Color {
        isDark ? Color(white: 0.176) : Color(white: 0.878)
    }

    var cardBackground: Color {
        isDark ? Color(white: 0.176) : Color(white: 0.878)
    }

    var searchBarBackground: Color {
        // Inset surfaces: darkened ~3-5% from base
        isDark ? Color(white: 0.149) : Color(white: 0.839)
    }

    var textPrimary: Color {
        isDark ? Color(white: 0.83) : Color(white: 0.23)
    }

    var textSecondary: Color {
        isDark ? Color(white: 0.54) : Color(white: 0.48)
    }

    var textTertiary: Color {
        isDark ? Color(white: 0.45) : Color(white: 0.55)
    }

    var accent: Color {
        .accentColor
    }

    var divider: Color {
        isDark ? Color.white.opacity(0.06) : Color.black.opacity(0.06)
    }

    var neuShadowLight: Color {
        isDark ? Color(white: 0.22) : Color.white
    }

    var neuShadowDark: Color {
        isDark ? Color(white: 0.133) : Color(white: 0.745)
    }

    var urlColor: Color {
        isDark ? Color.blue.opacity(0.9) : Color.blue
    }

    var fileIconColor: Color {
        isDark ? Color(white: 0.54) : Color(white: 0.48)
    }

    var toolbarBackground: Color {
        // Toolbar: ~3% lighter than base
        isDark ? Color(white: 0.196) : Color(white: 0.902)
    }

    var panelBorder: Color {
        isDark ? Color.white.opacity(0.06) : Color.clear
    }
}
