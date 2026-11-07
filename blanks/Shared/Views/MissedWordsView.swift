import SwiftUI

/// MoreBlanks: the words missed in the last seven days, with their meanings.
struct MissedWordsView: View {
    @Environment(GameState.self) private var game

    private static let wordFont = Font.custom("IowanOldStyle-Bold", size: 17, relativeTo: .body)
    private static let bodyFont = Font.custom("IowanOldStyle-Roman", size: 15, relativeTo: .subheadline)

    var body: some View {
        List {
            if game.progress.missedThisWeek.isEmpty {
                Text("Words you miss will show up here for a week.")
                    .font(Self.bodyFont)
                    .foregroundStyle(.black.opacity(0.6))
            }
            ForEach(game.progress.missedThisWeek, id: \.self) { word in
                VStack(alignment: .leading, spacing: 3) {
                    Text(word).font(Self.wordFont)
                    if let definition = game.definition(of: word) {
                        Text(definition).font(Self.bodyFont)
                    }
                }
                .foregroundStyle(.black)
                .padding(.vertical, 2)
                .listRowBackground(Color.white.opacity(0.7))
                .contentShape(Rectangle())
                .onLongPressGesture { DictionaryLookup.present(term: word, fallback: game.definition(of: word)) }
                .accessibilityElement(children: .combine)
                .accessibilityAction(named: "Look up \(word)") {
                    DictionaryLookup.present(term: word, fallback: game.definition(of: word))
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(white: 0.93))
        .navigationTitle("Missed This Week")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
    }
}
