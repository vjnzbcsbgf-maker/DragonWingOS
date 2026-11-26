import SwiftUI

enum EditorTheme: String, CaseIterable, Identifiable {
    case midnight = "Midnight"
    case graphite = "Graphite"
    case light = "Light"
    case nord = "Nord"
    var id: String { rawValue }
    var isLight: Bool { self == .light }
    var background: Color {
        switch self {
        case .midnight: return Color(red: 0.035, green: 0.045, blue: 0.075)
        case .graphite: return Color(red: 0.10, green: 0.11, blue: 0.13)
        case .light: return Color(red: 0.94, green: 0.95, blue: 0.97)
        case .nord: return Color(red: 0.18, green: 0.20, blue: 0.25)
        }
    }
    var foreground: Color { isLight ? Color(red: 0.12, green: 0.14, blue: 0.18) : .white }
    var accent: Color { self == .nord ? Color(red: 0.55, green: 0.72, blue: 0.82) : .cyan }
}

@MainActor
final class ThemeStore: ObservableObject {
    @Published var selected: EditorTheme = .midnight
}
