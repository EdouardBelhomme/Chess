import SwiftUI

struct BoardTheme: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let lightSquareColor: Color
    let darkSquareColor: Color
    let backgroundColor: Color
    let borderColor: Color
    
    static let classic = BoardTheme(
        name: "Classic",
        lightSquareColor: Color(white: 0.9),
        darkSquareColor: Color(red: 0.4, green: 0.6, blue: 0.8),
        backgroundColor: Color.white,
        borderColor: Color.black
    )
    
    static let wood = BoardTheme(
        name: "Wood",
        lightSquareColor: Color(red: 0.93, green: 0.87, blue: 0.80),
        darkSquareColor: Color(red: 0.55, green: 0.27, blue: 0.07),
        backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.1),
        borderColor: Color(red: 0.4, green: 0.2, blue: 0.0)
    )
    
    static let midnight = BoardTheme(
        name: "Midnight",
        lightSquareColor: Color(red: 0.7, green: 0.7, blue: 0.8),
        darkSquareColor: Color(red: 0.3, green: 0.3, blue: 0.45),
        backgroundColor: Color.black,
        borderColor: Color.white.opacity(0.5)
    )
    
    static let modern = BoardTheme(
        name: "Modern",
        lightSquareColor: Color(red: 0.85, green: 0.87, blue: 0.91),
        darkSquareColor: Color(red: 0.40, green: 0.55, blue: 0.75),
        backgroundColor: Color(red: 0.95, green: 0.95, blue: 0.97),
        borderColor: Color(red: 0.3, green: 0.4, blue: 0.5)
    )
    
    static let minimal = BoardTheme(
        name: "Minimal",
        lightSquareColor: Color.white,
        darkSquareColor: Color.gray.opacity(0.3),
        backgroundColor: Color.white,
        borderColor: Color.black
    )
    
    static let retro70s = BoardTheme(
        name: "Retro 70s",
        lightSquareColor: Color(red: 0.96, green: 0.87, blue: 0.47),
        darkSquareColor: Color(red: 0.65, green: 0.35, blue: 0.15),
        backgroundColor: Color(red: 0.2, green: 0.15, blue: 0.1),
        borderColor: Color(red: 0.4, green: 0.3, blue: 0.2)
    )
    
    static let light = BoardTheme(
        name: "Light",
        lightSquareColor: Color(white: 0.98),
        darkSquareColor: Color(white: 0.85),
        backgroundColor: Color.white,
        borderColor: Color.gray
    )
    
    static let dark = BoardTheme(
        name: "Dark",
        lightSquareColor: Color(white: 0.3),
        darkSquareColor: Color(white: 0.15),
        backgroundColor: Color.black,
        borderColor: Color.white.opacity(0.3)
    )
    
    static let allThemes: [BoardTheme] = [.classic, .wood, .midnight, .modern, .minimal, .retro70s, .light, .dark]
}
