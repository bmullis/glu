import SwiftUI

struct NeuExtruded: ViewModifier {
    let theme: ThemeManager
    let cornerRadius: CGFloat
    let intensity: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: theme.neuShadowLight, radius: 10 * intensity, x: -6 * intensity, y: -6 * intensity)
            .shadow(color: theme.neuShadowDark, radius: 10 * intensity, x: 6 * intensity, y: 6 * intensity)
    }
}

struct NeuInset: ViewModifier {
    let theme: ThemeManager
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(theme.neuShadowDark, lineWidth: 2)
                    .blur(radius: 3)
                    .offset(x: 2, y: 2)
                    .mask(RoundedRectangle(cornerRadius: cornerRadius).fill(.linearGradient(
                        colors: [.black, .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(theme.neuShadowLight, lineWidth: 2)
                    .blur(radius: 3)
                    .offset(x: -2, y: -2)
                    .mask(RoundedRectangle(cornerRadius: cornerRadius).fill(.linearGradient(
                        colors: [.clear, .black],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )))
            )
    }
}

extension View {
    func neuExtruded(theme: ThemeManager, cornerRadius: CGFloat = 12, intensity: CGFloat = 1.0) -> some View {
        modifier(NeuExtruded(theme: theme, cornerRadius: cornerRadius, intensity: intensity))
    }

    func neuInset(theme: ThemeManager, cornerRadius: CGFloat = 12) -> some View {
        modifier(NeuInset(theme: theme, cornerRadius: cornerRadius))
    }
}
