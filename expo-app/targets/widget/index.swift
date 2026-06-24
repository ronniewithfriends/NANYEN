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

// MARK: - Palette
// Explicit colors (not .primary/.secondary) so contrast holds on our light
// background in both light and dark mode.

private let pink = Color(red: 0.86, green: 0.12, blue: 0.52)
private let cyan = Color(red: 0.06, green: 0.52, blue: 0.62)
private let ink = Color(red: 0.11, green: 0.12, blue: 0.16)

// MARK: - Small reusable buttons

private struct AddButton: View {
    let label: String
    let delta: Int

    var body: some View {
        Button(intent: AddAmountIntent(delta: delta)) {
            Text(label)
                .font(.system(size: 12, weight: .black))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .frame(maxWidth: .infinity, minHeight: 26)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(cyan)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - View

struct NANYENWidgetView: View {
    var entry: NanyenEntry

    private var prevGenre: String {
        let genres = NanyenStore.genres
        let index = genres.firstIndex(of: entry.genre) ?? 0
        return genres[(index - 1 + genres.count) % genres.count]
    }

    private var nextGenre: String {
        let genres = NanyenStore.genres
        let index = genres.firstIndex(of: entry.genre) ?? 0
        return genres[(index + 1) % genres.count]
    }

    var body: some View {
        VStack(spacing: 5) {
            // Genre selector + open-app button
            HStack(spacing: 2) {
                Button(intent: SetGenreIntent(genre: prevGenre)) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .black))
                        .frame(width: 22, height: 24)
                }
                .buttonStyle(.plain)
                .foregroundStyle(ink)

                Text(entry.genre)
                    .font(.system(size: 13, weight: .heavy))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(pink)

                Button(intent: SetGenreIntent(genre: nextGenre)) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .black))
                        .frame(width: 22, height: 24)
                }
                .buttonStyle(.plain)
                .foregroundStyle(ink)

                Button(intent: OpenAppIntent()) {
                    Image(systemName: "arrow.up.forward")
                        .font(.system(size: 13, weight: .black))
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(pink)
                .clipShape(RoundedRectangle(cornerRadius: 7))
            }

            // Amount — the largest element
            Text(entry.amountText)
                .font(.system(size: 34, weight: .black))
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(ink)

            // Amount add buttons
            HStack(spacing: 4) {
                AddButton(label: "+1000", delta: 1000)
                AddButton(label: "+100", delta: 100)
                AddButton(label: "+10", delta: 10)
            }

            // Actions
            HStack(spacing: 4) {
                Button(intent: ClearDraftIntent()) {
                    Text("クリア")
                        .font(.system(size: 12, weight: .heavy))
                        .frame(maxWidth: .infinity, minHeight: 26)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(ink.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                Button(intent: RecordIntent()) {
                    Text("記録")
                        .font(.system(size: 13, weight: .black))
                        .frame(maxWidth: .infinity, minHeight: 26)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(pink)
                .clipShape(RoundedRectangle(cornerRadius: 8))
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
                            Color(red: 1, green: 0.95, blue: 0.88),
                            Color(red: 0.84, green: 0.96, blue: 1),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
        .configurationDisplayName("NANYEN クイック入力")
        .description("ジャンルを選んで金額をタップで記録")
        .supportedFamilies([.systemSmall])
    }
}

@main
struct NANYENWidgetBundle: WidgetBundle {
    var body: some Widget {
        NANYENWidget()
    }
}
