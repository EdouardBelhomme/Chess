import SwiftUI
import Combine

struct LessonView: View {
    let lesson: Lesson
    @StateObject private var viewModel: GameViewModel
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showSuccess = false
    
    init(lesson: Lesson) {
        self.lesson = lesson
        let vm = GameViewModel(mode: .playerVsPlayer)
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack {
            PremiumBackgroundView()
            
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Text(lesson.title)
                        .font(.system(.title2, design: appearanceManager.fontDesign))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(lesson.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
                    
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    appearanceManager.currentTheme.borderColor.opacity(0.6),
                                    appearanceManager.currentTheme.borderColor.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                    
                    BoardView(viewModel: viewModel, targetPosition: getTargetPosition())
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .padding(10)
                }
                .aspectRatio(1.0, contentMode: .fit)
                .padding(.horizontal, 20)
                .disabled(showSuccess)
                
                if showSuccess {
                    VStack(spacing: 16) {
                        Text("🎉 Lesson Complete!")
                            .font(.system(.title2, design: appearanceManager.fontDesign))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 14)
                                .background(
                                    Capsule()
                                        .fill(Color.green)
                                        .shadow(color: .green.opacity(0.4), radius: 8, x: 0, y: 4)
                                )
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            setupLesson()
        }
        .onChange(of: viewModel.chessEngine.turn) { _, _ in
            checkGoal()
        }
    }
    
    private func setupLesson() {
        var blankBoard = Board()
        blankBoard.grid = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        
        lesson.setupBoard(&blankBoard)
        viewModel.chessEngine.board = blankBoard
        viewModel.chessEngine.turn = .white
        
        lesson.setupEngine?(viewModel.chessEngine)
        
        viewModel.moveValidator = { move in
            switch lesson.goal {
            case .moveToSquare(let target):
                return move.end == target
            case .capturePiece(let type):
                if let target = viewModel.chessEngine.board[move.end], target.type == type, target.color != move.piece.color {
                    return true
                }
                return false
                
            case .check:
                var tempBoard = viewModel.chessEngine.board
                tempBoard.movePiece(from: move.start, to: move.end)
                return viewModel.chessEngine.isKingInCheck(color: move.piece.color.opposite, on: tempBoard)
                
            case .checkmate:
                var tempBoard = viewModel.chessEngine.board
                tempBoard.movePiece(from: move.start, to: move.end)
                if viewModel.chessEngine.isKingInCheck(color: move.piece.color.opposite, on: tempBoard) {
                    return true
                }
                return false
            }
        }
        
        viewModel.objectWillChange.send()
    }
    
    private func getTargetPosition() -> Position? {
        switch lesson.goal {
        case .moveToSquare(let pos):
            return pos
        case .capturePiece(let type):
            for r in 0..<8 {
                for c in 0..<8 {
                    let pos = Position(row: r, col: c)
                    if let p = viewModel.chessEngine.board[pos], p.color == .black, p.type == type {
                        return pos
                    }
                }
            }
            return nil
        case .check, .checkmate:
            let engine = viewModel.chessEngine
            for r in 0..<8 {
                for c in 0..<8 {
                    let start = Position(row: r, col: c)
                    if let p = engine.board[start], p.color == .white {
                        let moves = engine.getValidMoves(for: p, at: start)
                        for move in moves {
                            var tempBoard = engine.board
                            tempBoard.movePiece(from: move.start, to: move.end)
                            if engine.isKingInCheck(color: .black, on: tempBoard) {
                                return move.end
                            }
                        }
                    }
                }
            }
            return nil
        }
    }

    private func checkGoal() {
        if viewModel.chessEngine.turn == .black {
            DispatchQueue.main.async {
                viewModel.chessEngine.turn = .white
            }
        }
        
        switch lesson.goal {
        case .capturePiece(let pieceType):
            let opponents = viewModel.chessEngine.board.grid.flatMap { $0 }.compactMap { $0 }.filter { $0.color == .black && $0.type == pieceType }
            if opponents.isEmpty {
                withAnimation { showSuccess = true }
                SoundManager.shared.playSuccessSound()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
            
        case .moveToSquare(let position):
            if let piece = viewModel.chessEngine.board[position], piece.color == .white {
                withAnimation { showSuccess = true }
                SoundManager.shared.playSuccessSound()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
            
        case .check:
            if viewModel.chessEngine.isCheck {
                withAnimation { showSuccess = true }
                SoundManager.shared.playSuccessSound()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
            
        case .checkmate:
            if viewModel.chessEngine.isGameOver && viewModel.chessEngine.winner == .white {
                withAnimation { showSuccess = true }
                SoundManager.shared.playSuccessSound()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }
}
