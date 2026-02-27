import SwiftUI

struct BoardView: View {
    @ObservedObject var viewModel: GameViewModel
    @EnvironmentObject var appearanceManager: AppearanceManager
    var targetPosition: Position? = nil
    @Namespace private var animation
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { col in
                        let position = Position(row: row, col: col)
                        SquareView(
                            position: position,
                            piece: viewModel.chessEngine.board[position],
                            isSelected: viewModel.selectedPosition == position,
                            isValidMove: viewModel.validMovesForSelection.contains { $0.end == position },
                            isTarget: targetPosition == position || isTargetPiece(at: position),
                            isCheck: viewModel.chessEngine.isCheck && viewModel.chessEngine.board[position]?.type == .king && viewModel.chessEngine.board[position]?.color == viewModel.chessEngine.turn,
                            theme: appearanceManager.currentTheme,
                            showLegalMoves: appearanceManager.showLegalMoves,
                            namespace: animation,
                            onTap: {
                                viewModel.handleSquareTap(at: position)
                            }
                        )
                        .rotationEffect(isFlipped ? .degrees(180) : .zero)
                    }
                }
            }
        }

        .border(appearanceManager.currentTheme.borderColor, width: 2)
        .rotationEffect(isFlipped ? .degrees(180) : .zero)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: viewModel.chessEngine.board)
    }
    
    private var isFlipped: Bool {
        if case .ai(_, let userColor) = viewModel.gameMode, userColor == .black {
            return true
        }
        return false
    }
    
    private func isTargetPiece(at position: Position) -> Bool {
        return false
    }
}
