import SwiftUI

struct HomeView: View {
    @StateObject private var statsManager = StatsManager()
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    var body: some View {
        NavigationView {
            ZStack {
                PremiumBackgroundView()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text("♟️")
                            .font(.system(size: 60))
                        Text("Chess Master")
                            .font(.system(size: 36, weight: .bold, design: appearanceManager.fontDesign))
                            .foregroundColor(appearanceManager.buttonTextColor)
                    }
                    .padding(.bottom, 40)
                    
                    VStack(spacing: 16) {
                        NavigationLink(destination: DifficultySelectionView().environmentObject(statsManager)) {
                            PremiumMenuButton(title: "Play vs AI", icon: "play.fill")
                        }
                        
                        NavigationLink(destination: StatsView(statsManager: statsManager)) {
                            PremiumMenuButton(title: "Statistics", icon: "chart.bar.fill")
                        }
                        
                        NavigationLink(destination: LearnView()) {
                            PremiumMenuButton(title: "Learn to Play", icon: "book.fill")
                        }
                        
                        NavigationLink(destination: SettingsView()) {
                            PremiumMenuButton(title: "Settings", icon: "gearshape.fill")
                        }
                    }
                    
                    Spacer()
                    Spacer()
                }
                .padding(.horizontal, 30)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}

struct PremiumBackgroundView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    appearanceManager.backgroundPrimaryColor.opacity(0.8),
                    appearanceManager.backgroundSecondaryColor.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Circle()
                .fill(appearanceManager.backgroundPrimaryColor.opacity(0.5))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: -80, y: -300)
            
            Circle()
                .fill(appearanceManager.backgroundSecondaryColor.opacity(0.5))
                .frame(width: 350, height: 350)
                .blur(radius: 70)
                .offset(x: 100, y: 200)
            
            Circle()
                .fill(appearanceManager.backgroundAccentColor.opacity(0.4))
                .frame(width: 200, height: 200)
                .blur(radius: 50)
                .offset(x: -150, y: 100)
            
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.5)
                .ignoresSafeArea()
        }
        .animation(.easeInOut(duration: 0.5), value: appearanceManager.appStyle)
    }
}

struct PremiumMenuButton: View {
    let title: String
    let icon: String
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
            
            Text(title)
                .font(.system(.title3, design: appearanceManager.fontDesign))
                .fontWeight(.semibold)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
