import Foundation

struct Position: Equatable, Hashable {
    let row: Int
    let col: Int
    
    var description: String {
        let files = ["a", "b", "c", "d", "e", "f", "g", "h"]
        let rank = 8 - row
        guard col >= 0 && col < 8 && row >= 0 && row < 8 else { return "invalid" }
        return "\(files[col])\(rank)"
    }
}

struct Move: Equatable, Identifiable {
    let id = UUID()
    let start: Position
    let end: Position
    let piece: Piece
    let isCapture: Bool
    let isCastling: Bool
    let isEnPassant: Bool
    let promotedPiece: PieceType?
    
    init(start: Position, end: Position, piece: Piece, isCapture: Bool = false, isCastling: Bool = false, isEnPassant: Bool = false, promotedPiece: PieceType? = nil) {
        self.start = start
        self.end = end
        self.piece = piece
        self.isCapture = isCapture
        self.isCastling = isCastling
        self.isEnPassant = isEnPassant
        self.promotedPiece = promotedPiece
    }
}
