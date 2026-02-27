import SwiftUI

struct StatsView: View {
    @ObservedObject var statsManager: StatsManager
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    var body: some View {
        ZStack {
            PremiumBackgroundView()
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("Your Statistics")
                        .font(.system(.title, design: appearanceManager.fontDesign))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    HStack(spacing: 16) {
                        StatCard(title: "Wins", value: "\(statsManager.wins)", color: .green)
                        StatCard(title: "Draws", value: "\(statsManager.draws)", color: .gray)
                        StatCard(title: "Losses", value: "\(statsManager.losses)", color: .red)
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Games")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 20)
                        
                        if statsManager.records.isEmpty {
                            Text("No games played yet")
                                .foregroundColor(.white.opacity(0.5))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(statsManager.records.prefix(10)) { record in
                                    GameRecordRow(record: record)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct GameRecordRow: View {
    let record: GameRecord
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    var body: some View {
        HStack {
            Circle()
                .fill(resultColor)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(resultText)
                    .font(.system(.subheadline, design: appearanceManager.fontDesign))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(record.difficulty)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text(record.date, style: .date)
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var resultText: String {
        if let winner = record.winner {
            return "\(winner) Won"
        }
        return "Draw"
    }
    
    private var resultColor: Color {
        if record.winner == "White" { return .green }
        if record.winner == "Black" { return .red }
        return .gray
    }
}
