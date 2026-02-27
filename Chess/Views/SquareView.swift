import SwiftUI

struct SquareView: View {
    let position: Position
    let piece: Piece?
    let isSelected: Bool
    let isValidMove: Bool
    let isTarget: Bool
    let isCheck: Bool
    let theme: BoardTheme
    let showLegalMoves: Bool
    let namespace: Namespace.ID
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill((position.row + position.col) % 2 == 0 ? theme.lightSquareColor : theme.darkSquareColor)
            
            if isSelected {
                Rectangle()
                    .fill(Color.green.opacity(0.6))
            }
            
            if isCheck {
                Rectangle()
                    .fill(RadialGradient(gradient: Gradient(colors: [.red.opacity(0.8), .clear]), center: .center, startRadius: 2, endRadius: 25))
            }
            
            if isTarget {
                ZStack {
                    Rectangle()
                        .stroke(Color.green, lineWidth: 4)
                    Text("Here")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.green)
                        .background(Color.white.opacity(0.8))
                        .offset(y: -20)
                }
            }
            
            if let piece = piece {
                ZStack {
                    Text(piece.unicodeCharacter)
                        .font(.system(size: 40, weight: .black))
                        .foregroundStyle(Color.black.opacity(0.4))
                        .offset(x: 2, y: 3)
                    
                    Text(piece.unicodeCharacter)
                        .font(.system(size: 40, weight: .black))
                        .foregroundStyle(
                            piece.color == .white
                                ? LinearGradient(
                                    colors: [.white, Color(white: 0.85), .white],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color(white: 0.25), .black, Color(white: 0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .shadow(color: piece.color == .white ? .black.opacity(0.5) : .white.opacity(0.3), radius: 0.5, x: 0, y: 0)
                    
                    Text(piece.unicodeCharacter)
                        .font(.system(size: 40, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    piece.color == .white ? Color.white.opacity(0.9) : Color.white.opacity(0.2),
                                    .clear,
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                }
                .shadow(color: .black.opacity(0.5), radius: 4, x: 2, y: 4)
                .matchedGeometryEffect(id: piece.id, in: namespace)
                .transition(.scale.combined(with: .opacity))
            }
            
            if isValidMove && showLegalMoves {
                Circle()
                    .fill(Color.blue.opacity(0.5))
                    .frame(width: 15, height: 15)
            }
        }

        .aspectRatio(1, contentMode: .fit)
        .onTapGesture {
            onTap()
        }
    }

}

extension Piece {
    var imageName: String {
        let colorPrefix = color == .white ? "white" : "black"
        switch type {
        case .king: return "\(colorPrefix)_king"
        case .queen: return "\(colorPrefix)_queen"
        case .rook: return "\(colorPrefix)_rook"
        case .bishop: return "\(colorPrefix)_bishop"
        case .knight: return "\(colorPrefix)_knight"
        case .pawn: return "\(colorPrefix)_pawn"
        }
    }
    
    var unicodeCharacter: String {
        switch type {
        case .king: return "♔"
        case .queen: return "♕"
        case .rook: return "♖"
        case .bishop: return "♗"
        case .knight: return "♘"
        case .pawn: return "♙"
        }
    }
}
