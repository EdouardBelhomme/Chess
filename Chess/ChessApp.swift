import SwiftUI

@main
struct ChessApp: App {
    @StateObject private var appearanceManager = AppearanceManager()
    @StateObject private var statsManager = StatsManager()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
            .environmentObject(appearanceManager)
            .environmentObject(statsManager)
            .preferredColorScheme(appearanceManager.appStyle.colorScheme)
        }
    }
}
