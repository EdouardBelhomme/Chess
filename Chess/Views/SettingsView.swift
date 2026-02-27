import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            PremiumBackgroundView()
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("Settings")
                        .font(.system(.title, design: appearanceManager.fontDesign))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    SettingsSection(title: "Visual Style") {
                        VStack(spacing: 12) {
                            ForEach(AppearanceManager.AppStyle.allCases) { style in
                                StyleOptionRow(style: style, isSelected: appearanceManager.appStyle == style) {
                                    appearanceManager.appStyle = style
                                }
                            }
                        }
                    }
                    
                    SettingsSection(title: "Board Theme") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(BoardTheme.allThemes) { theme in
                                    BoardThemeButton(theme: theme, isSelected: appearanceManager.currentTheme == theme) {
                                        appearanceManager.currentTheme = theme
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    SettingsSection(title: "Gameplay") {
                        VStack(spacing: 0) {
                            SettingsToggle(title: "Show Legal Moves", isOn: $appearanceManager.showLegalMoves)
                            Divider().background(Color.white.opacity(0.2))
                            SettingsToggle(title: "Show Coordinates", isOn: $appearanceManager.showCoordinates)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(0.1))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    
                    SettingsSection(title: "Audio & Haptics") {
                        VStack(spacing: 0) {
                            SettingsToggle(title: "Sound Effects", isOn: $appearanceManager.soundEnabled)
                            Divider().background(Color.white.opacity(0.2))
                            SettingsToggle(title: "Haptic Feedback", isOn: $appearanceManager.hapticsEnabled)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(0.1))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    
                    Button(action: resetToDefaults) {
                        Text("Reset to Defaults")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.white.opacity(0.15))
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
    
    private func resetToDefaults() {
        appearanceManager.currentTheme = .classic
        appearanceManager.appStyle = .modern
        appearanceManager.showLegalMoves = true
        appearanceManager.showCoordinates = true
        appearanceManager.soundEnabled = true
        appearanceManager.hapticsEnabled = true
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 24)
            
            content
                .padding(.horizontal, 20)
        }
    }
}

struct StyleOptionRow: View {
    let style: AppearanceManager.AppStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(style.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(isSelected ? 0.2 : 0.1))
        )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? Color.blue.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct BoardThemeButton: View {
    let theme: BoardTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.lightSquareColor)
                        .frame(width: 50, height: 50)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.darkSquareColor)
                        .frame(width: 50, height: 50)
                        .mask(
                            Rectangle()
                                .frame(width: 50, height: 50)
                                .offset(x: 12.5, y: 12.5)
                        )
                    
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 18, y: -18)
                    }
                }
                
                Text(theme.name)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct SettingsToggle: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .tint(.blue)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
