import SwiftUI
import WidgetKit

@main
struct BlanksWidgetBundle: WidgetBundle {
    var body: some Widget {
        WordOfTheDayWidget()
    }
}

struct WordOfTheDayEntry: TimelineEntry {
    let date: Date
    let word: WordLists.DailyEntry?
}

struct WordOfTheDayProvider: TimelineProvider {
    private static let sample = WordLists.DailyEntry(word: "decorum", definition: "propriety in manners and conduct")

    private func entry(for date: Date) -> WordOfTheDayEntry {
        let daily = WordLists.bundled?.daily ?? []
        let word = DailyWord.index(for: date, count: daily.count).map { daily[$0] }
        return WordOfTheDayEntry(date: date, word: word)
    }

    func placeholder(in context: Context) -> WordOfTheDayEntry {
        WordOfTheDayEntry(date: .now, word: Self.sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (WordOfTheDayEntry) -> Void) {
        completion(entry(for: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WordOfTheDayEntry>) -> Void) {
        let now = Date.now
        let timeline = Timeline(entries: [entry(for: now)], policy: .after(DailyWord.nextChange(after: now)))
        completion(timeline)
    }
}

struct WordOfTheDayView: View {
    let entry: WordOfTheDayEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        if let word = entry.word {
            switch family {
            case .accessoryRectangular:
                VStack(alignment: .leading, spacing: 0) {
                    Text(word.word)
                        .font(.custom("IowanOldStyle-Bold", size: 15, relativeTo: .headline))
                    Text(word.definition)
                        .font(.custom("IowanOldStyle-Roman", size: 12, relativeTo: .caption))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            default:
                VStack(alignment: .leading, spacing: 6) {
                    Text("Word of the day")
                        .font(.custom("IowanOldStyle-Italic", size: 12, relativeTo: .caption))
                        .foregroundStyle(.black.opacity(0.6))
                    Text(word.word)
                        .font(.custom("IowanOldStyle-Bold", size: 22, relativeTo: .title3))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(word.definition)
                        .font(.custom("IowanOldStyle-Roman", size: 14, relativeTo: .footnote))
                        .minimumScaleFactor(0.8)
                    Spacer(minLength: 0)
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        } else {
            Text("Open the app to play")
                .font(.custom("IowanOldStyle-Roman", size: 14, relativeTo: .footnote))
        }
    }
}

struct WordOfTheDayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "WordOfTheDay", provider: WordOfTheDayProvider()) { entry in
            WordOfTheDayView(entry: entry)
                .containerBackground(Color(red: 0.97, green: 0.95, blue: 0.89), for: .widget)
        }
        .configurationDisplayName("Word of the Day")
        .description("A new word and its meaning every day.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}
