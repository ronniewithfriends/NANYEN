import AppIntents
import WidgetKit

// Each button on the widget runs one of these App Intents (iOS 17+),
// which mutates the shared draft/inbox and reloads the widget.

struct SetGenreIntent: AppIntent {
    static var title: LocalizedStringResource = "ジャンルを選ぶ"

    @Parameter(title: "genre")
    var genre: String

    init() {}
    init(genre: String) { self.genre = genre }

    func perform() async throws -> some IntentResult {
        NanyenStore.draftGenre = genre
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct AddAmountIntent: AppIntent {
    static var title: LocalizedStringResource = "金額を足す"

    @Parameter(title: "delta")
    var delta: Int

    init() {}
    init(delta: Int) { self.delta = delta }

    func perform() async throws -> some IntentResult {
        NanyenStore.addAmount(delta)
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct ClearDraftIntent: AppIntent {
    static var title: LocalizedStringResource = "クリア"

    func perform() async throws -> some IntentResult {
        NanyenStore.clearDraft()
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct RecordIntent: AppIntent {
    static var title: LocalizedStringResource = "記録する"

    func perform() async throws -> some IntentResult {
        NanyenStore.record()
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

// A do-nothing intent used to make the big amount text tappable WITHOUT
// triggering the widget's default "open app" behavior. (Opening the app is
// handled by the ↗ region via the widget's `widgetURL`.)
struct NoopIntent: AppIntent {
    static var title: LocalizedStringResource = "何もしない"

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
