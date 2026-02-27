import Combine
import Foundation

class ChessEngine: ObservableObject {
    @Published var board: Board
    @Published var turn: PieceColor = .white
    @Published var isCheck: Bool = false
    @Published var isGameOver: Bool = false
    @Published var winner: PieceColor?

    @Published var capturedPiecesWhite: [Piece] = []
    @Published var capturedPiecesBlack: [Piece] = []

    init() {
        self.board = Board()
    }

    @Published var lastDoublePawnMove: Position? = nil

    func getValidMoves(for piece: Piece, at position: Position, on boardState: Board? = nil)
        -> [Move]
    {
        let currentBoard = boardState ?? self.board
        let potentialMoves = getRawMoves(for: piece, at: position, on: currentBoard)

        return potentialMoves.filter { move in
            var tempBoard = currentBoard

            tempBoard.movePiece(from: move.start, to: move.end)

            if piece.type == .pawn && move.end.col != move.start.col && tempBoard[move.end] == nil {
                tempBoard[move.start.row, move.end.col] = nil
            }

            return !isKingInCheck(color: piece.color, on: tempBoard)
        }
    }

    func makeMove(_ move: Move) {
        let piece = move.piece
        let start = move.start
        let end = move.end

        var capturedPiece: Piece? = nil
        if let target = board[end], target.color != piece.color {
            capturedPiece = target
        }

        if piece.type == .pawn && start.col != end.col && board[end] == nil {
            let capturedPawnPos = Position(row: start.row, col: end.col)
            if let target = board[capturedPawnPos] {
                capturedPiece = target
            }
            board[capturedPawnPos] = nil
        }

        if let captured = capturedPiece {
            if captured.color == .white {
                capturedPiecesWhite.append(captured)
            } else {
                capturedPiecesBlack.append(captured)
            }
        }

        if piece.type == .king && abs(start.col - end.col) == 2 {
            let isKingside = end.col > start.col
            let rookStartCol = isKingside ? 7 : 0
            let rookEndCol = isKingside ? 5 : 3
            let rookRow = start.row

            let rookPos = Position(row: rookRow, col: rookStartCol)
            let rookDest = Position(row: rookRow, col: rookEndCol)

            board.movePiece(from: rookPos, to: rookDest)
        }

        board.movePiece(from: start, to: end)

        if piece.type == .pawn && (end.row == 0 || end.row == 7) {
            if board[end] != nil {
                board[end] = Piece(type: .queen, color: piece.color)
                board[end]?.hasMoved = true
            }
        }

        turn = turn.opposite

        if piece.type == .pawn && abs(start.row - end.row) == 2 {
            lastDoublePawnMove = end
        } else {
            lastDoublePawnMove = nil
        }

        if isKingInCheck(color: turn, on: board) {
            isCheck = true
            if isCheckmate(color: turn) {
                isGameOver = true
                winner = turn.opposite
            }
        } else {
            isCheck = false
            if isStalemate(color: turn) {
                isGameOver = true
                winner = nil
            }
        }
    }

    func isKingInCheck(color: PieceColor, on boardState: Board) -> Bool {
        guard let kingPos = findKing(color: color, on: boardState) else { return false }
        return isSquareUnderAttack(position: kingPos, byColor: color.opposite, on: boardState)
    }

    func isSquareUnderAttack(position: Position, byColor attackerColor: PieceColor, on board: Board)
        -> Bool
    {

        let attackFromRow = attackerColor == .white ? position.row + 1 : position.row - 1
        for colOffset in [-1, 1] {
            let checkPos = Position(row: attackFromRow, col: position.col + colOffset)
            if isValid(checkPos), let piece = board[checkPos], piece.color == attackerColor,
                piece.type == .pawn
            {
                return true
            }
        }

        let knightOffsets = [
            (1, 2), (1, -2), (-1, 2), (-1, -2), (2, 1), (2, -1), (-2, 1), (-2, -1),
        ]
        for (dr, dc) in knightOffsets {
            let checkPos = Position(row: position.row + dr, col: position.col + dc)
            if isValid(checkPos), let piece = board[checkPos], piece.color == attackerColor,
                piece.type == .knight
            {
                return true
            }
        }

        let kingOffsets = [(0, 1), (0, -1), (1, 0), (-1, 0), (1, 1), (1, -1), (-1, 1), (-1, -1)]
        for (dr, dc) in kingOffsets {
            let checkPos = Position(row: position.row + dr, col: position.col + dc)
            if isValid(checkPos), let piece = board[checkPos], piece.color == attackerColor,
                piece.type == .king
            {
                return true
            }
        }

        let orthoDirs = [(0, 1), (0, -1), (1, 0), (-1, 0)]
        for (dr, dc) in orthoDirs {
            var r = position.row + dr
            var c = position.col + dc
            while isValid(Position(row: r, col: c)) {
                let pos = Position(row: r, col: c)
                if let piece = board[pos] {
                    if piece.color == attackerColor && (piece.type == .rook || piece.type == .queen)
                    {
                        return true
                    }
                    break
                }
                r += dr
                c += dc
            }
        }

        let diagDirs = [(1, 1), (1, -1), (-1, 1), (-1, -1)]
        for (dr, dc) in diagDirs {
            var r = position.row + dr
            var c = position.col + dc
            while isValid(Position(row: r, col: c)) {
                let pos = Position(row: r, col: c)
                if let piece = board[pos] {
                    if piece.color == attackerColor
                        && (piece.type == .bishop || piece.type == .queen)
                    {
                        return true
                    }
                    break
                }
                r += dr
                c += dc
            }
        }

        return false
    }

    private func isCheckmate(color: PieceColor) -> Bool {
        return !hasAnyValidMoves(color: color)
    }

    private func isStalemate(color: PieceColor) -> Bool {
        return !isCheck && !hasAnyValidMoves(color: color)
    }

    private func hasAnyValidMoves(color: PieceColor) -> Bool {
        for row in 0..<8 {
            for col in 0..<8 {
                let pos = Position(row: row, col: col)
                if let piece = board[pos], piece.color == color {
                    if !getValidMoves(for: piece, at: pos).isEmpty {
                        return true
                    }
                }
            }
        }
        return false
    }

    private func findKing(color: PieceColor, on boardState: Board) -> Position? {
        for row in 0..<8 {
            for col in 0..<8 {
                let pos = Position(row: row, col: col)
                if let piece = boardState[pos], piece.type == .king, piece.color == color {
                    return pos
                }
            }
        }
        return nil
    }

    func getRawMoves(for piece: Piece, at position: Position, on boardState: Board? = nil) -> [Move]
    {
        let currentBoard = boardState ?? self.board
        var moves: [Move] = []

        switch piece.type {
        case .pawn:
            moves.append(
                contentsOf: getPawnMoves(piece: piece, position: position, board: currentBoard))
        case .rook:
            moves.append(
                contentsOf: getSlidingMoves(
                    piece: piece, position: position,
                    directions: [(0, 1), (0, -1), (1, 0), (-1, 0)], board: currentBoard))
        case .bishop:
            moves.append(
                contentsOf: getSlidingMoves(
                    piece: piece, position: position,
                    directions: [(1, 1), (1, -1), (-1, 1), (-1, -1)], board: currentBoard))
        case .queen:
            moves.append(
                contentsOf: getSlidingMoves(
                    piece: piece, position: position,
                    directions: [
                        (0, 1), (0, -1), (1, 0), (-1, 0), (1, 1), (1, -1), (-1, 1), (-1, -1),
                    ], board: currentBoard))
        case .knight:
            let knightMoves = [
                (1, 2), (1, -2), (-1, 2), (-1, -2), (2, 1), (2, -1), (-2, 1), (-2, -1),
            ]
            moves.append(
                contentsOf: getStepMoves(
                    piece: piece, position: position, relativeMoves: knightMoves,
                    board: currentBoard))
        case .king:
            let kingMoves = [(0, 1), (0, -1), (1, 0), (-1, 0), (1, 1), (1, -1), (-1, 1), (-1, -1)]
            moves.append(
                contentsOf: getStepMoves(
                    piece: piece, position: position, relativeMoves: kingMoves, board: currentBoard)
            )

            if !piece.hasMoved {
                let ksRookPos = Position(row: position.row, col: 7)
                if let rook = currentBoard[ksRookPos], rook.type == .rook,
                    rook.color == piece.color, !rook.hasMoved
                {
                    if currentBoard[position.row, 5] == nil && currentBoard[position.row, 6] == nil
                    {
                        moves.append(
                            Move(
                                start: position, end: Position(row: position.row, col: 6),
                                piece: piece))
                    }
                }

                let qsRookPos = Position(row: position.row, col: 0)
                if let rook = currentBoard[qsRookPos], rook.type == .rook,
                    rook.color == piece.color, !rook.hasMoved
                {
                    if currentBoard[position.row, 1] == nil && currentBoard[position.row, 2] == nil
                        && currentBoard[position.row, 3] == nil
                    {
                        moves.append(
                            Move(
                                start: position, end: Position(row: position.row, col: 2),
                                piece: piece))
                    }
                }
            }
        }
        return moves
    }

    private func getPawnMoves(piece: Piece, position: Position, board: Board) -> [Move] {
        var moves: [Move] = []
        let direction = piece.color == .white ? -1 : 1

        let forward1 = Position(row: position.row + direction, col: position.col)
        if isValid(forward1) && board[forward1] == nil {
            moves.append(Move(start: position, end: forward1, piece: piece))

            let startRow = piece.color == .white ? 6 : 1
            if position.row == startRow {
                let forward2 = Position(row: position.row + (direction * 2), col: position.col)
                if isValid(forward2) && board[forward2] == nil {
                    moves.append(Move(start: position, end: forward2, piece: piece))
                }
            }
        }

        for colOffset in [-1, 1] {
            let capturePos = Position(row: position.row + direction, col: position.col + colOffset)
            if isValid(capturePos) {
                if let target = board[capturePos], target.color != piece.color {
                    moves.append(
                        Move(start: position, end: capturePos, piece: piece, isCapture: true))
                } else if board[capturePos] == nil {
                    let pawnLocation = Position(row: position.row, col: capturePos.col)
                    if let lastMove = lastDoublePawnMove, lastMove == pawnLocation {
                        if let enemyPawn = board[pawnLocation], enemyPawn.color != piece.color,
                            enemyPawn.type == .pawn
                        {
                            moves.append(
                                Move(
                                    start: position, end: capturePos, piece: piece, isCapture: true)
                            )
                        }
                    }
                }
            }
        }

        return moves
    }

    private func getSlidingMoves(
        piece: Piece, position: Position, directions: [(Int, Int)], board: Board
    ) -> [Move] {
        var moves: [Move] = []

        for (dRow, dCol) in directions {
            var currentRow = position.row + dRow
            var currentCol = position.col + dCol

            while true {
                let targetPos = Position(row: currentRow, col: currentCol)
                guard isValid(targetPos) else { break }

                if let targetPiece = board[targetPos] {
                    if targetPiece.color != piece.color {
                        moves.append(
                            Move(start: position, end: targetPos, piece: piece, isCapture: true))
                    }
                    break
                } else {
                    moves.append(Move(start: position, end: targetPos, piece: piece))
                    currentRow += dRow
                    currentCol += dCol
                }
            }
        }
        return moves
    }

    private func getStepMoves(
        piece: Piece, position: Position, relativeMoves: [(Int, Int)], board: Board
    ) -> [Move] {
        var moves: [Move] = []

        for (dRow, dCol) in relativeMoves {
            let targetPos = Position(row: position.row + dRow, col: position.col + dCol)
            if isValid(targetPos) {
                if let targetPiece = board[targetPos] {
                    if targetPiece.color != piece.color {
                        moves.append(
                            Move(start: position, end: targetPos, piece: piece, isCapture: true))
                    }
                } else {
                    moves.append(Move(start: position, end: targetPos, piece: piece))
                }
            }
        }
        return moves
    }

    private func isValid(_ position: Position) -> Bool {
        return position.row >= 0 && position.row < 8 && position.col >= 0 && position.col < 8
    }
}
