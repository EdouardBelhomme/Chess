import Foundation

enum PieceColor: String {
    case white
    case black
    
    var opposite: PieceColor {
        return self == .white ? .black : .white
    }
}

enum PieceType: String {
    case pawn
    case rook
    case knight
    case bishop
    case queen
    case king
    
    var value: Int {
        switch self {
        case .pawn: return 1
        case .knight, .bishop: return 3
        case .rook: return 5
        case .queen: return 9
        case .king: return 1000
        }
    }
}

struct Piece: Equatable, Identifiable {
    let id = UUID()
    let type: PieceType
    let color: PieceColor
    var hasMoved: Bool = false
    
    static func == (lhs: Piece, rhs: Piece) -> Bool {
        return lhs.type == rhs.type && lhs.color == rhs.color
    }
}
