import SwiftUI

/// MoreBlanks: the last 50 completed words with their meanings.
struct RecentWordsView: View {
    @Environment(GameState.self) private var game

    private static let wordFont = Font.custom("IowanOldStyle-Bold", size: 17, relativeTo: .body)
    private static let bodyFont = Font.custom("IowanOldStyle-Roman", size: 15, relativeTo: .subheadline)

    var body: some View {
        List {
            if game.progress.recent.isEmpty {
                Text("Words you answer will show up here.")
                    .font(Self.bodyFont)
                    .foregroundStyle(.black.opacity(0.6))
            }
            ForEach(game.progress.recent) { item in
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(item.word).font(Self.wordFont)
                        Spacer()
                        Text(item.firstTry ? "first try" : "missed")
                            .font(Self.bodyFont.italic())
                            .foregroundStyle(item.firstTry ? .black.opacity(0.5) : Color(red: 0.6, green: 0.1, blue: 0.1))
                    }
                    if let definition = game.definition(of: item.word) {
                        Text(definition).font(Self.bodyFont)
                    }
                }
                .foregroundStyle(.black)
                .padding(.vertical, 2)
                .listRowBackground(Color.white.opacity(0.7))
                .contentShape(Rectangle())
                .onLongPressGesture { DictionaryLookup.present(term: item.word, fallback: game.definition(of: item.word)) }
                .accessibilityElement(children: .combine)
                .accessibilityAction(named: "Look up \(item.word)") {
                    DictionaryLookup.present(term: item.word, fallback: game.definition(of: item.word))
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(white: 0.93))
        .navigationTitle("Recent Words")
        .navigationBarTitleDisplayMode(.inline)
        // Same black bar as About; it does not carry over to pushed views.
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
    }
}
