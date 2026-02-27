import Foundation
import Combine

struct GameRecord: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let winner: String?
    let difficulty: String
}

class StatsManager: ObservableObject {
    @Published var records: [GameRecord] = []
    
    private let fileName = "chess_stats.json"
    
    init() {
        loadStats()
    }
    
    func addGame(winner: PieceColor?, difficulty: String) {
        let winnerString = winner?.rawValue.capitalized
        let record = GameRecord(date: Date(), winner: winnerString, difficulty: difficulty)
        records.insert(record, at: 0)
        saveStats()
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func saveStats() {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if let data = try? JSONEncoder().encode(records) {
            try? data.write(to: url)
        }
    }
    
    private func loadStats() {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: url) {
            if let decoded = try? JSONDecoder().decode([GameRecord].self, from: data) {
                records = decoded
            }
        }
    }
    
    var wins: Int { records.filter { $0.winner == "White" }.count }
    var losses: Int { records.filter { $0.winner == "Black" }.count }
    var draws: Int { records.filter { $0.winner == nil }.count }
}
