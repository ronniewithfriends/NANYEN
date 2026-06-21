import Foundation

// Shared store backed by the App Group container.
// The widget writes here; the React Native app reads via the WidgetBridge module.
enum NanyenStore {
    static let suiteName = "group.app.nanyen.mobile"
    static let genres = ["食事", "日用品", "娯楽", "仕事"]

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    // MARK: - Draft (the in-progress entry shown on the widget)

    static var draftGenre: String {
        get { defaults?.string(forKey: "draftGenre") ?? "食事" }
        set { defaults?.set(newValue, forKey: "draftGenre") }
    }

    static var draftAmount: Int {
        get { defaults?.integer(forKey: "draftAmount") ?? 0 }
        set { defaults?.set(max(0, newValue), forKey: "draftAmount") }
    }

    static func addAmount(_ delta: Int) {
        draftAmount = max(0, draftAmount + delta)
    }

    static func clearDraft() {
        draftAmount = 0
    }

    // MARK: - Inbox (committed entries waiting for the app to pick up)

    static func record() {
        let amount = draftAmount
        guard amount > 0 else { return }
        var inbox = loadInbox()
        let entry: [String: Any] = [
            "uuid": UUID().uuidString,
            "dateKey": todayKey(),
            "genre": draftGenre,
            "amountYen": -amount,
            "createdAt": Date().timeIntervalSince1970,
        ]
        inbox.append(entry)
        saveInbox(inbox)
        draftAmount = 0
    }

    static func loadInbox() -> [[String: Any]] {
        guard let data = defaults?.data(forKey: "inbox"),
              let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else { return [] }
        return arr
    }

    static func saveInbox(_ inbox: [[String: Any]]) {
        if let data = try? JSONSerialization.data(withJSONObject: inbox) {
            defaults?.set(data, forKey: "inbox")
        }
    }

    // MARK: - Formatting helpers

    // Must match the app's dateKey() in src/utils/date.ts (local timezone, yyyy-MM-dd).
    static func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    static func formattedDraft() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let number = formatter.string(from: NSNumber(value: draftAmount)) ?? "\(draftAmount)"
        return "¥" + number
    }
}
