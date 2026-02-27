import SwiftUI

struct DifficultySelectionView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @State private var selectedColor: PieceColor = .white
    
    var body: some View {
        ZStack {
            PremiumBackgroundView()
            
            VStack(spacing: 25) {
                Text("Choose Your Challenge")
                    .font(.system(.title, design: appearanceManager.fontDesign))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                HStack(spacing: 20) {
                    ColorChoiceButton(color: .white, isSelected: selectedColor == .white) {
                        selectedColor = .white
                    }
                    ColorChoiceButton(color: .black, isSelected: selectedColor == .black) {
                        selectedColor = .black
                    }
                }
                .padding(.bottom, 20)
                
                VStack(spacing: 16) {
                    DifficultyRow(level: .easy, emoji: "🌱", selectedColor: selectedColor)
                    DifficultyRow(level: .medium, emoji: "⚖️", selectedColor: selectedColor)
                    DifficultyRow(level: .hard, emoji: "🔥", selectedColor: selectedColor)
                    DifficultyRow(level: .impossible, emoji: "🤖", selectedColor: selectedColor)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

struct ColorChoiceButton: View {
    let color: PieceColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(color == .white ? "♔" : "♚")
                    .font(.system(size: 40))
                Text(color == .white ? "White" : "Black")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(width: 100, height: 90)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.white : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct DifficultyRow: View {
    let level: Difficulty
    let emoji: String
    let selectedColor: PieceColor
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    var body: some View {
        NavigationLink(destination: LazyView(GameView(mode: .ai(difficulty: level, userColor: selectedColor)))) {
            HStack(spacing: 16) {
                Text(emoji)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.rawValue.capitalized)
                        .font(.system(.headline, design: appearanceManager.fontDesign))
                        .fontWeight(.bold)
                    
                    Text(levelDescription)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(borderColor.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var levelDescription: String {
        switch level {
        case .easy: return "Perfect for beginners"
        case .medium: return "A balanced challenge"
        case .hard: return "For experienced players"
        case .impossible: return "Can you beat the machine?"
        }
    }
    
    private var borderColor: Color {
        switch level {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        case .impossible: return .purple
        }
    }
}
