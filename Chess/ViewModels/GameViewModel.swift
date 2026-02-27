import Combine
import SwiftUI

class GameViewModel: ObservableObject {
    @Published var chessEngine: ChessEngine

    @Published var selectedPosition: Position? = nil
    @Published var validMovesForSelection: [Move] = []

    var moveValidator: ((Move) -> Bool)? = nil

    @Published var gameMode: GameMode

    var userColor: PieceColor {
        if case .ai(_, let color) = gameMode {
            return color
        }
        return .white
    }

    var aiEngine: AIEngine?
    var cancellables = Set<AnyCancellable>()

    enum GameMode {
        case playerVsPlayer
        case ai(difficulty: Difficulty, userColor: PieceColor)
    }

    init(mode: GameMode = .ai(difficulty: .easy, userColor: .white)) {
        self.gameMode = mode
        let engine = ChessEngine()
        self.chessEngine = engine
        self.aiEngine = AIEngine(chessEngine: engine)

        setupBindings()

        if case .ai(_, let userColor) = mode, userColor == .black {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.makeAIMove()
            }
        }
    }

    private func setupBindings() {
        chessEngine.$turn
            .sink { [weak self] newTurn in
                self?.handleTurnChange(newTurn)
            }
            .store(in: &cancellables)

        chessEngine.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func handleSquareTap(at position: Position) {
        if chessEngine.isGameOver { return }

        if isAITurn { return }

        if selectedPosition != nil {
            if let move = validMovesForSelection.first(where: { $0.end == position }) {
                userMoved(move)
                return
            }

            if let piece = chessEngine.board[position], piece.color == chessEngine.turn {
                selectPiece(at: position)
            } else {
                deselect()
            }
        } else {
            if let piece = chessEngine.board[position], piece.color == chessEngine.turn {
                selectPiece(at: position)
            }
        }
    }

    private func selectPiece(at position: Position) {
        if let piece = chessEngine.board[position], piece.color == chessEngine.turn {
            selectedPosition = position
            let moves = chessEngine.getValidMoves(for: piece, at: position)

            if let validator = moveValidator {
                validMovesForSelection = moves.filter { validator($0) }
            } else {
                validMovesForSelection = moves
            }
        }
    }

    private func deselect() {
        selectedPosition = nil
        validMovesForSelection = []
    }

    private func userMoved(_ move: Move) {
        chessEngine.makeMove(move)
        if move.isCapture {
            SoundManager.shared.playCaptureSound()
        } else {
            SoundManager.shared.playMoveSound()
        }
        deselect()
    }

    private var isAITurn: Bool {
        if case .ai(_, let userColor) = gameMode {
            return chessEngine.turn != userColor
        }
        return false
    }

    private func handleTurnChange(_ turn: PieceColor) {
        if chessEngine.isGameOver { return }

        if case .ai(_, let userColor) = gameMode, turn != userColor {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.makeAIMove()
            }
        }
    }

    private func makeAIMove() {
        guard isAITurn else { return }
        guard case .ai(let difficulty, _) = gameMode else { return }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, let aiEngine = self.aiEngine else { return }
            let currentBoard = self.chessEngine.board
            let move = aiEngine.getBestMove(
                for: self.chessEngine.turn, difficulty: difficulty, on: currentBoard)

            DispatchQueue.main.async {
                if let bestMove = move {
                    self.chessEngine.makeMove(bestMove)
                    if bestMove.isCapture {
                        SoundManager.shared.playCaptureSound()
                    } else {
                        SoundManager.shared.playMoveSound()
                    }
                }
            }
        }
    }

    func resetGame() {
        chessEngine = ChessEngine()
        aiEngine = AIEngine(chessEngine: chessEngine)
        setupBindings()
        selectedPosition = nil
        validMovesForSelection = []

        if case .ai(_, let userColor) = gameMode, userColor == .black {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.makeAIMove()
            }
        }
    }
}
