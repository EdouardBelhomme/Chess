import Foundation

class AIEngine {
    let chessEngine: ChessEngine

    init(chessEngine: ChessEngine) {
        self.chessEngine = chessEngine
    }

    func getBestMove(for color: PieceColor, difficulty: Difficulty, on board: Board) -> Move? {

        switch difficulty {
        case .easy:
            return getRandomMove(for: color, on: board)
        case .medium:
            return getMinimaxMove(for: color, depth: 1, on: board)
        case .hard:
            return getMinimaxMove(for: color, depth: 2, on: board)
        case .impossible:
            return getMinimaxMove(for: color, depth: 3, on: board)
        }
    }

    private func getRandomMove(for color: PieceColor, on board: Board) -> Move? {
        let allMoves = getAllValidMoves(for: color, on: board)
        return allMoves.randomElement()
    }

    private func getMinimaxMove(for color: PieceColor, depth: Int, on board: Board) -> Move? {
        var bestMove: Move?
        var bestValue = Int.min
        let alpha = Int.min
        let beta = Int.max

        let moves = getAllValidMoves(for: color, on: board)

        for move in moves.shuffled() {
            var tempBoard = board
            tempBoard.movePiece(from: move.start, to: move.end)

            let boardValue = minimax(
                board: tempBoard, depth: depth - 1, alpha: alpha, beta: beta, isMaximizing: false,
                playerColor: color)

            if boardValue > bestValue {
                bestValue = boardValue
                bestMove = move
            }
        }

        return bestMove
    }

    private func minimax(
        board: Board, depth: Int, alpha: Int, beta: Int, isMaximizing: Bool, playerColor: PieceColor
    ) -> Int {
        if depth == 0 {
            return evaluate(board: board, playerColor: playerColor)
        }

        var currentAlpha = alpha
        var currentBeta = beta

        let turnColor = isMaximizing ? playerColor : playerColor.opposite
        let moves = getAllValidMoves(for: turnColor, on: board)

        if moves.isEmpty {
            if chessEngine.isKingInCheck(color: turnColor, on: board) {
                return isMaximizing ? -100000 : 100000
            }
            return 0
        }

        if isMaximizing {
            var maxEval = Int.min
            for move in moves {
                var tempBoard = board
                tempBoard.movePiece(from: move.start, to: move.end)
                let eval = minimax(
                    board: tempBoard, depth: depth - 1, alpha: currentAlpha, beta: currentBeta,
                    isMaximizing: false, playerColor: playerColor)
                maxEval = max(maxEval, eval)
                currentAlpha = max(currentAlpha, eval)
                if currentBeta <= currentAlpha { break }
            }
            return maxEval
        } else {
            var minEval = Int.max
            for move in moves {
                var tempBoard = board
                tempBoard.movePiece(from: move.start, to: move.end)
                let eval = minimax(
                    board: tempBoard, depth: depth - 1, alpha: currentAlpha, beta: currentBeta,
                    isMaximizing: true, playerColor: playerColor)
                minEval = min(minEval, eval)
                currentBeta = min(currentBeta, eval)
                if currentBeta <= currentAlpha { break }
            }
            return minEval
        }
    }

    private func evaluate(board: Board, playerColor: PieceColor) -> Int {
        var score = 0

        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = board[row, col] {
                    let value = piece.type.value
                    if piece.color == playerColor {
                        score += value
                    } else {
                        score -= value
                    }

                    if (row == 3 || row == 4) && (col == 3 || col == 4) {
                        if piece.color == playerColor { score += 1 } else { score -= 1 }
                    }
                }
            }
        }
        return score
    }

    private func getAllValidMoves(for color: PieceColor, on board: Board) -> [Move] {
        var moves: [Move] = []
        for row in 0..<8 {
            for col in 0..<8 {
                let pos = Position(row: row, col: col)
                if let piece = board[pos], piece.color == color {
                    moves.append(
                        contentsOf: chessEngine.getValidMoves(for: piece, at: pos, on: board))
                }
            }
        }
        return moves
    }
}
