import Foundation

struct Board {
    var grid: [[Piece?]]
    
    init() {
        self.grid = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        resetBoard()
    }
    
    subscript(row: Int, col: Int) -> Piece? {
        get {
            guard isValidPosition(row: row, col: col) else { return nil }
            return grid[row][col]
        }
        set {
            guard isValidPosition(row: row, col: col) else { return }
            grid[row][col] = newValue
        }
    }
    
    subscript(pos: Position) -> Piece? {
        get { return self[pos.row, pos.col] }
        set { self[pos.row, pos.col] = newValue }
    }
    
    private func isValidPosition(row: Int, col: Int) -> Bool {
        return row >= 0 && row < 8 && col >= 0 && col < 8
    }
    
    mutating func resetBoard() {
        grid = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        
        for col in 0..<8 {
            grid[1][col] = Piece(type: .pawn, color: .black)
            grid[6][col] = Piece(type: .pawn, color: .white)
        }
        
        let pieceTypes: [PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
        
        for (col, type) in pieceTypes.enumerated() {
            grid[0][col] = Piece(type: type, color: .black)
            grid[7][col] = Piece(type: type, color: .white)
        }
    }
    
    mutating func movePiece(from: Position, to: Position) {
        guard let piece = self[from] else { return }
        self[to] = piece
        self[from] = nil
        
        if var movedPiece = self[to] {
            movedPiece.hasMoved = true
            self[to] = movedPiece
        }
    }
}
