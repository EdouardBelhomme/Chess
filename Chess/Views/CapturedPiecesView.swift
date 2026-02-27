import SwiftUI

struct CapturedPiecesView: View {
    let pieces: [Piece]
    let color: PieceColor
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(sortedPieces) { piece in
                Text(piece.unicodeCharacter)
                    .font(.system(size: 20))
                    .foregroundColor(color == .white ? .white : .black)
                    .shadow(color: color == .white ? .black.opacity(0.5) : .white.opacity(0.5), radius: 1, x: 0, y: 0)
            }
        }
        .frame(height: 30)
        .padding(.horizontal, 8)
    }
    
    private var sortedPieces: [Piece] {
        pieces.sorted { $0.type.value > $1.type.value }
    }
}
