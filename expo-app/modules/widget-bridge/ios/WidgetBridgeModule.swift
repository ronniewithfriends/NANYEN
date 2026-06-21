import ExpoModulesCore

// Reads the App Group "inbox" written by the widget's RecordIntent and
// returns it to JS as a raw JSON string (parsed in index.ts).
public class WidgetBridgeModule: Module {
  private let suiteName = "group.app.nanyen.mobile"
  private let inboxKey = "inbox"

  public func definition() -> ModuleDefinition {
    Name("WidgetBridge")

    AsyncFunction("getPendingEntries") { () -> String in
      guard let defaults = UserDefaults(suiteName: self.suiteName),
            let data = defaults.data(forKey: self.inboxKey),
            let json = String(data: data, encoding: .utf8)
      else {
        return "[]"
      }
      return json
    }

    AsyncFunction("clearPendingEntries") {
      UserDefaults(suiteName: self.suiteName)?.removeObject(forKey: self.inboxKey)
    }
  }
}
