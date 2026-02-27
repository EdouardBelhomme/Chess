import SwiftUI

extension GameViewModel.GameMode {
    static var defaultAIMode: GameViewModel.GameMode {
        .ai(difficulty: .medium, userColor: .white)
    }
}

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @EnvironmentObject var statsManager: StatsManager
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showSettings = false
    
    @State private var appearAnimation = false
    
    init(mode: GameViewModel.GameMode = .defaultAIMode) {
        _viewModel = StateObject(wrappedValue: GameViewModel(mode: mode))
    }
    
    var body: some View {
        ZStack {
            PremiumBackgroundView()
            
            VStack(spacing: 16) {
                GameHUDView(viewModel: viewModel, showSettings: $showSettings)
                
                GameBoardAreaView(viewModel: viewModel)
                    .padding(.horizontal, 8)
            }
            .padding(.bottom, 20)
            .blur(radius: viewModel.chessEngine.isGameOver ? 10 : 0)
            .scaleEffect(viewModel.chessEngine.isGameOver ? 0.95 : 1.0)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.chessEngine.isGameOver)
            
            CheckBannerView(viewModel: viewModel)
            
            if viewModel.chessEngine.isGameOver {
                GameOverOverlayView(viewModel: viewModel, presentationMode: _presentationMode)
            }
        }
        .onChange(of: viewModel.chessEngine.isGameOver) { _, newValue in
            if newValue {
                let difficultyString: String
                switch viewModel.gameMode {
                case .playerVsPlayer: difficultyString = "PvP"
                case .ai(let d, _): difficultyString = String(describing: d).capitalized
                }
                statsManager.addGame(winner: viewModel.chessEngine.winner, difficulty: difficultyString)
            }
        }
        .sheet(isPresented: $showSettings) {
             NavigationView {
                 SettingsView()
                     .toolbar {
                         ToolbarItem(placement: .navigationBarTrailing) {
                             Button("Done") { showSettings = false }
                         }
                     }
             }
             .navigationViewStyle(.stack)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appearAnimation = true
            }
        }
    }
}

struct LiquidBackgroundView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            Circle()
                .fill(Color.blue.opacity(0.4))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -100, y: -200)
            
            Circle()
                .fill(Color.purple.opacity(0.4))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: 100, y: 150)
            
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .opacity(0.3)
        }
    }
    
    @ViewBuilder
    private var backgroundColor: some View {
        if let gradient = appearanceManager.buttonGradient {
            gradient
        } else {
            Color(UIColor.systemBackground)
        }
    }
}

struct GameHUDView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var showSettings: Bool
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    var body: some View {
        HStack {
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(appearanceManager.buttonTextColor)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            
            Spacer()
            
            HStack(spacing: 8) {
                Circle()
                    .fill(viewModel.chessEngine.turn == .white ? Color.white : Color.black)
                    .frame(width: 12, height: 12)
                    .shadow(radius: 2)
                
                Text("\(viewModel.chessEngine.turn == .white ? "White" : "Black")'s Turn")
                    .font(.system(.headline, design: appearanceManager.fontDesign))
                    .foregroundColor(appearanceManager.buttonTextColor)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            
            Spacer()
            
            Button(action: {
                withAnimation { viewModel.resetGame() }
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(appearanceManager.buttonTextColor)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

struct GameBoardAreaView: View {
    @ObservedObject var viewModel: GameViewModel
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    private let boardCornerRadius: CGFloat = 24
    private let slabThickness: CGFloat = 20
    
    var body: some View {
        VStack(spacing: 24) {
            CapturedPiecesContainer(
                pieces: viewModel.userColor == .white ? viewModel.chessEngine.capturedPiecesWhite : viewModel.chessEngine.capturedPiecesBlack,
                color: viewModel.userColor == .white ? .white : .black
            )
            
            ZStack {
                ForEach(0..<5) { i in
                    RoundedRectangle(cornerRadius: boardCornerRadius, style: .continuous)
                        .fill(Color.black.opacity(0.15 - Double(i) * 0.02))
                        .blur(radius: CGFloat(15 + i * 8))
                        .offset(x: CGFloat(3 + i * 2), y: CGFloat(20 + i * 10))
                }
                
                RoundedRectangle(cornerRadius: boardCornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(white: 0.25),
                                Color(white: 0.15),
                                Color(white: 0.08)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .offset(y: slabThickness / 2)
                
                RoundedRectangle(cornerRadius: boardCornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(white: 0.2),
                                Color(white: 0.1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: slabThickness / 3, y: slabThickness / 3)
                
                ZStack {
                    RoundedRectangle(cornerRadius: boardCornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(white: 0.95),
                                    Color(white: 0.88)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: boardCornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.8),
                                    Color.clear,
                                    Color.black.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                    
                    ChessBoard3DView(viewModel: viewModel)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(8)
                }
                
                RoundedRectangle(cornerRadius: boardCornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.9),
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
            .padding(.horizontal, 24)
            .aspectRatio(1.0, contentMode: .fit)
            .rotation3DEffect(
                .degrees(12),
                axis: (x: 1, y: 0, z: 0),
                anchor: .center,
                perspective: 0.35
            )
            
            CapturedPiecesContainer(
                pieces: viewModel.userColor == .white ? viewModel.chessEngine.capturedPiecesBlack : viewModel.chessEngine.capturedPiecesWhite,
                color: viewModel.userColor == .white ? .black : .white
            )
        }
    }
}

struct CapturedPiecesContainer: View {
    let pieces: [Piece]
    let color: PieceColor
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    var body: some View {
        HStack {
            if pieces.isEmpty {
                Text("Captures")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
            } else {
                CapturedPiecesView(pieces: pieces, color: color)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
            }
        }
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

struct CheckBannerView: View {
    @ObservedObject var viewModel: GameViewModel
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    var body: some View {
        if viewModel.chessEngine.isCheck && !viewModel.chessEngine.isGameOver {
            VStack {
                Text("CHECK")
                    .font(.system(size: 28, weight: .black, design: appearanceManager.fontDesign))
                    .tracking(2)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 30)
                    .background(
                        Capsule()
                            .fill(Color.red.opacity(0.9))
                            .shadow(color: .red.opacity(0.5), radius: 10, x: 0, y: 5)
                    )
                    .padding(.top, 80)
                    .transition(.move(edge: .top).combined(with: .opacity))
                Spacer()
            }
            .zIndex(10)
        }
    }
}

struct GameOverOverlayView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .opacity(0.9)
            
            VStack(spacing: 30) {
                Image(systemName: viewModel.chessEngine.winner != nil ? "trophy.fill" : "flag.fill")
                    .font(.system(size: 60))
                    .foregroundColor(viewModel.chessEngine.winner == .white ? .yellow : (viewModel.chessEngine.winner == .black ? .primary : .gray))
                    .shadow(radius: 10)
                
                VStack(spacing: 8) {
                    Text(gameStateTitle)
                        .font(.system(size: 36, weight: .heavy, design: appearanceManager.fontDesign))
                        .foregroundColor(.primary)
                    
                    Text(gameStateMessage)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 16) {
                    Button(action: {
                        withAnimation { viewModel.resetGame() }
                    }) {
                        Text("New Game")
                            .font(.headline)
                            .foregroundColor(appearanceManager.buttonTextColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(newGameButtonBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: appearanceManager.buttonColor.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Main Menu")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.regularMaterial)
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(.horizontal, 20)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(radius: 30)
            )
            .padding(.horizontal, 30)
            .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
        .zIndex(100)
    }
    
    var gameStateTitle: String {
        if let _ = viewModel.chessEngine.winner { return "VICTORY" }
        return "DRAW"
    }
    
    var gameStateMessage: String {
        if let winner = viewModel.chessEngine.winner {
            return "\(winner == .white ? "White" : "Black") wins the match!"
        }
        return "It's a stalemate."
    }
    
    @ViewBuilder
    private var newGameButtonBackground: some View {
        if let gradient = appearanceManager.buttonGradient {
            gradient
        } else {
            appearanceManager.buttonColor
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension GameViewModel.GameMode: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .playerVsPlayer: hasher.combine(0)
        case .ai(let d, let c):
            hasher.combine(1)
            hasher.combine(d)
            hasher.combine(c)
        }
    }
    
    static func == (lhs: GameViewModel.GameMode, rhs: GameViewModel.GameMode) -> Bool {
        switch (lhs, rhs) {
        case (.playerVsPlayer, .playerVsPlayer): return true
        case (.ai(let d1, let c1), .ai(let d2, let c2)): return d1 == d2 && c1 == c2
        default: return false
        }
    }
}
