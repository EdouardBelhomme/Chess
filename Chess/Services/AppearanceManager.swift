import Combine
import SwiftUI

class AppearanceManager: ObservableObject {
    @Published var currentTheme: BoardTheme = .classic

    enum AppStyle: String, CaseIterable, Identifiable {
        case modern = "Modern (System)"
        case light = "Modern Light"
        case dark = "Modern Dark"
        case minimal = "Minimal (B&W)"
        case retro = "Retro 70s"

        var id: String { self.rawValue }

        var colorScheme: ColorScheme? {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .minimal: return .light
            case .retro: return .dark
            default: return nil
            }
        }
    }
    @Published var appStyle: AppStyle = .modern

    var buttonGradient: LinearGradient? {
        switch appStyle {
        case .modern:
            return LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading,
                endPoint: .bottomTrailing)
        case .light:
            return LinearGradient(
                gradient: Gradient(colors: [Color.white, Color(white: 0.9)]), startPoint: .top,
                endPoint: .bottom)
        case .dark:
            return LinearGradient(
                gradient: Gradient(colors: [Color(white: 0.2), Color(white: 0.1)]),
                startPoint: .top, endPoint: .bottom)
        default:
            return nil
        }
    }

    var buttonColor: Color {
        switch appStyle {
        case .modern: return .clear
        case .light: return .white
        case .dark: return .black
        case .minimal: return .clear
        case .retro: return Color(red: 0.8, green: 0.4, blue: 0.1)
        }
    }

    var buttonTextColor: Color {
        switch appStyle {
        case .light, .minimal: return .black
        default: return .white
        }
    }

    var fontDesign: Font.Design {
        switch appStyle {
        case .minimal: return .monospaced
        case .retro: return .serif
        default: return .default
        }
    }

    var cornerRadius: CGFloat {
        switch appStyle {
        case .minimal: return 0
        case .retro: return 25
        default: return 15
        }
    }

    var buttonBorderWidth: CGFloat {
        return appStyle == .minimal ? 2 : 0
    }

    var backgroundPrimaryColor: Color {
        switch appStyle {
        case .modern: return Color.blue
        case .light: return Color.cyan
        case .dark: return Color.indigo
        case .minimal: return Color.gray
        case .retro: return Color.orange
        }
    }

    var backgroundSecondaryColor: Color {
        switch appStyle {
        case .modern: return Color.purple
        case .light: return Color.teal
        case .dark: return Color.purple
        case .minimal: return Color.gray.opacity(0.5)
        case .retro: return Color.brown
        }
    }

    var backgroundAccentColor: Color {
        switch appStyle {
        case .modern: return Color.pink
        case .light: return Color.mint
        case .dark: return Color.blue
        case .minimal: return Color.gray.opacity(0.3)
        case .retro: return Color.yellow
        }
    }

    @Published var showLegalMoves: Bool = true
    @Published var showCoordinates: Bool = true

    @Published var soundEnabled: Bool = true
    @Published var hapticsEnabled: Bool = true

}
