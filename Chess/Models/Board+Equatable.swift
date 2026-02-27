import Foundation

extension Board: Equatable {
    static func == (lhs: Board, rhs: Board) -> Bool {
        return lhs.grid == rhs.grid
    }
}
