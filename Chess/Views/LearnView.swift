import SwiftUI

struct LearnView: View {
    let categories = LessonData.categories
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    var body: some View {
        ZStack {
            PremiumBackgroundView()
            
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("📚")
                            .font(.system(size: 50))
                        Text("Learn Chess")
                            .font(.system(.title, design: appearanceManager.fontDesign))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    
                    ForEach(categories) { category in
                        LessonCategorySection(category: category)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

struct LessonCategorySection: View {
    let category: LessonCategory
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(category.name)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text("\(category.lessons.count) lessons")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 10) {
                ForEach(category.lessons) { lesson in
                    NavigationLink(destination: LazyView(LessonView(lesson: lesson))) {
                        LessonRow(lesson: lesson)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct LessonRow: View {
    let lesson: Lesson
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    var body: some View {
        HStack(spacing: 16) {
            Text(lessonIcon)
                .font(.system(size: 28))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.system(.subheadline, design: appearanceManager.fontDesign))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(lesson.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
    
    private var lessonIcon: String {
        let title = lesson.title.lowercased()
        if title.contains("pawn") { return "♟" }
        if title.contains("rook") { return "♜" }
        if title.contains("knight") { return "♞" }
        if title.contains("bishop") { return "♝" }
        if title.contains("queen") { return "♛" }
        if title.contains("king") { return "♚" }
        if title.contains("castle") || title.contains("castling") { return "🏰" }
        if title.contains("en passant") { return "⚔️" }
        if title.contains("promotion") { return "👑" }
        if title.contains("check") { return "⚠️" }
        if title.contains("checkmate") || title.contains("mate") { return "🏆" }
        return "♟"
    }
}
