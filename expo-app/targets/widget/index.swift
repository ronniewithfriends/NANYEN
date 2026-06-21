import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Timeline

struct NanyenEntry: TimelineEntry {
    let date: Date
    let genre: String
    let amountText: String
}

struct NanyenProvider: TimelineProvider {
    func placeholder(in context: Context) -> NanyenEntry {
        NanyenEntry(date: Date(), genre: "食事", amountText: "¥0")
    }

    func getSnapshot(in context: Context, completion: @escaping (NanyenEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NanyenEntry>) -> Void) {
        completion(Timeline(entries: [currentEntry()], policy: .never))
    }

    private func currentEntry() -> NanyenEntry {
        NanyenEntry(date: Date(), genre: NanyenStore.draftGenre, amountText: NanyenStore.formattedDraft())
    }
}

// MARK: - Buttons

private struct GenreButton: View {
    let genre: String
    let selected: Bool

    var body: some View {
        Button(intent: SetGenreIntent(genre: genre)) {
            Text(genre)
                .font(.system(size: 13, weight: .heavy))
                .frame(maxWidth: .infinity, minHeight: 30)
        }
        .buttonStyle(.plain)
        .foregroundStyle(selected ? Color(red: 0.92, green: 0.16, blue: 0.58) : .secondary)
        .background(selected ? Color(red: 1, green: 0.16, blue: 0.58).opacity(0.16) : Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct AmountButton: View {
    let label: String
    let delta: Int

    var body: some View {
        Button(intent: AddAmountIntent(delta: delta)) {
            Text(label)
                .font(.system(size: 15, weight: .heavy))
                .frame(maxWidth: .infinity, minHeight: 42)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .background(Color(red: 0.14, green: 0.78, blue: 0.86).opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - View

struct NANYENWidgetView: View {
    var entry: NanyenEntry
    @Environment(\.widgetFamily) var family

    private var amountFontSize: CGFloat { family == .systemLarge ? 38 : 28 }

    var body: some View {
        VStack(spacing: 7) {
            HStack {
                Text("NANYEN")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(entry.genre)
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(Color(red: 0.92, green: 0.16, blue: 0.58))
            }

            Text(entry.amountText)
                .font(.system(size: amountFontSize, weight: .black))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.primary)

            HStack(spacing: 6) {
                ForEach(NanyenStore.genres, id: \.self) { genre in
                    GenreButton(genre: genre, selected: genre == entry.genre)
                }
            }

            HStack(spacing: 6) {
                AmountButton(label: "+¥1000", delta: 1000)
                AmountButton(label: "+¥100", delta: 100)
                AmountButton(label: "+¥10", delta: 10)
            }

            HStack(spacing: 6) {
                Button(intent: ClearDraftIntent()) {
                    Text("クリア")
                        .font(.system(size: 14, weight: .heavy))
                        .frame(maxWidth: .infinity, minHeight: 40)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .background(Color.gray.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button(intent: RecordIntent()) {
                    Text("記録")
                        .font(.system(size: 16, weight: .black))
                        .frame(maxWidth: .infinity, minHeight: 40)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(Color(red: 1, green: 0.16, blue: 0.58).opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

// MARK: - Widget

struct NANYENWidget: Widget {
    let kind = "NANYENWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NanyenProvider()) { entry in
            NANYENWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [
                            Color(red: 1, green: 0.94, blue: 0.86),
                            Color(red: 0.86, green: 0.97, blue: 1),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
        .configurationDisplayName("NANYEN クイック入力")
        .description("ジャンルを選んで金額をタップで記録")
        .supportedFamilies([.systemLarge, .systemMedium])
    }
}

@main
struct NANYENWidgetBundle: WidgetBundle {
    var body: some Widget {
        NANYENWidget()
    }
}
