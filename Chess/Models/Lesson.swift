import Foundation

enum LessonGoal {
    case capturePiece(PieceType)
    case moveToSquare(Position)
    case check
    case checkmate
}

struct Lesson: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let setupBoard: (inout Board) -> Void
    var setupEngine: ((ChessEngine) -> Void)? = nil
    let goal: LessonGoal
    let playerColor: PieceColor = .white
}

struct LessonCategory: Identifiable {
    let id = UUID()
    let name: String
    let lessons: [Lesson]
}

struct LessonData {
    static let categories: [LessonCategory] = [
        LessonCategory(name: "Movement Basics", lessons: [
            Lesson(
                title: "Pawn Basics",
                description: "Pawns move forward one square, but capture diagonally. Capture the black Pawn!",
                setupBoard: { board in
                    board.resetBoard()
                    board.grid = Array(repeating: Array(repeating: nil, count: 8), count: 8)
                    board[4, 4] = Piece(type: .pawn, color: .white)
                    board[3, 5] = Piece(type: .pawn, color: .black)
                },
                goal: .capturePiece(.pawn)
            ),
            Lesson(
                title: "The Knight's L",
                description: "Knights move in an L-shape and can jump over pieces. Move your Knight to c3 (row 5, col 2).",
                setupBoard: { board in
                    board.grid = Array(repeating: Array(repeating: nil, count: 8), count: 8)
                    board[7, 1] = Piece(type: .knight, color: .white)
                    board[6, 1] = Piece(type: .pawn, color: .white)
                    board[6, 2] = Piece(type: .pawn, color: .white)
                },
                goal: .moveToSquare(Position(row: 5, col: 2))
            ),
            Lesson(
                title: "Rook Power",
                description: "Rooks move horizontally or vertically. Capture the black Bishop!",
                setupBoard: { board in
                     board.grid = Array(repeating: Array(repeating: nil, count: 8), count: 8)
                     board[7, 0] = Piece(type: .rook, color: .white)
                     board[1, 0] = Piece(type: .bishop, color: .black)
                },
                goal: .capturePiece(.bishop)
            ),
            Lesson(
                title: "Bishop Diagonals",
                description: "Bishops move diagonally as far as they want. Capture the black Rook!",
                setupBoard: { board in
                     board.grid = Array(repeating: Array(repeating: nil, count: 8), count: 8)
                     board[2, 2] = Piece(type: .bishop, color: .white)
                     board[5, 5] = Piece(type: .rook, color: .black)
                },
                goal: .capturePiece(.rook)
            ),
            Lesson(
                title: "The Queen's Power",
                description: "The Queen is the most powerful piece. Move her diagonally to the top corner (h8)!",
                setupBoard: { board in
                     board.grid = Array(repeating: Array(repeating: nil, count: 8), count: 8)
                     board[7, 0] = Piece(type: .queen, color: .white)
                },
                goal: .moveToSquare(Position(row: 0, col: 7))
            ),
            Lesson(
                title: "Protect the King",
                description: "The King moves one square in any direction. Move him forward to f1.",
                setupBoard: { board in
                     board.grid = Array(repeating: Array(repeating: nil, count: 8), count: 8)
                     board[7, 4] = Piece(type: .king, color: .white)
                     board[6, 6] = Piece(type: .pawn, color: .white)
                     board[6, 7] = Piece(type: .pawn, color: .white)
                     board[6, 5] = Piece(type: .pawn, color: .white)
                },
                goal: .moveToSquare(Position(row: 7, col: 5))
            )
        ]),
        
        LessonCategory(name: "Special Rules", lessons: [
            Lesson(
                title: "Castling",
                description: "Move your King two squares sideways (to g1), and the Rook will hop over.",
                setupBoard: { board in
                    board.grid = Array(repeating: Array(repeating: nil, count: 8), count: 8)
                    board[7, 4] = Piece(type: .king, color: .white)
                    board[7, 7] = Piece(type: .rook, color: .white)
                },
                goal: .moveToSquare(Position(row: 7, col: 6))
            ),
            Lesson(
                title: "En Passant",
                description: "The black pawn just moved two steps. Capture it as if it moved one (move to d6)!",
                setupBoard: { board in
                    board.grid = Array(repeating: Array(repeating: nil, count: 8), count: 8)
                    board[3, 4] = Piece(type: .pawn, color: .white)
                    board[3, 3] = Piece(type: .pawn, color: .black)
                },
                setupEngine: { engine in
                    engine.lastDoublePawnMove = Position(row: 3, col: 3)
                },
                goal: .moveToSquare(Position(row: 2, col: 3))
            ),
            Lesson(
                title: "Promotion",
                description: "When a pawn reaches the end, it becomes a Queen! Move your pawn to the last rank.",
                setupBoard: { board in
                    board.grid = Array(repeating: Array(repeating: nil, count: 8), count: 8)
                    board[1, 0] = Piece(type: .pawn, color: .white)
                },
                goal: .moveToSquare(Position(row: 0, col: 0))
            )
        ]),
        
        LessonCategory(name: "Winning the Game", lessons: [
            Lesson(
                title: "Check",
                description: "Put the King in danger! Move your Rook to e1 to attack the King.",
                setupBoard: { board in
                    board.grid = Array(repeating: Array(repeating: nil, count: 8), count: 8)
                    board[7, 0] = Piece(type: .rook, color: .white)
                    board[0, 4] = Piece(type: .king, color: .black)
                },
                goal: .moveToSquare(Position(row: 7, col: 4))
            ),
            Lesson(
                title: "Checkmate",
                description: "Win the game! The Black King is trapped by his own pawns. Move your Rook to c8 to deliver Checkmate.",
                setupBoard: { board in
                    board.grid = Array(repeating: Array(repeating: nil, count: 8), count: 8)
                    board[0, 6] = Piece(type: .king, color: .black)
                    board[1, 5] = Piece(type: .pawn, color: .black)
                    board[1, 6] = Piece(type: .pawn, color: .black)
                    board[1, 7] = Piece(type: .pawn, color: .black)
                    
                    board[7, 2] = Piece(type: .rook, color: .white)
                },
                goal: .moveToSquare(Position(row: 0, col: 2))
            )
        ])
    ]
}
