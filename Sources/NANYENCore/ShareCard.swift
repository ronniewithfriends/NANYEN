public struct ShareCard: Equatable, Sendable {
    public let appName: String
    public let periodLabel: String
    public let type: ShareCardType
    public let privacy: PrivacyDensity
    public let accent: CardAccent
    public let mood: CardMood
    public let headline: String
    public let mainLine: String?
    public let caption: String
    public let hashtags: [String]

    public init(
        appName: String,
        periodLabel: String,
        type: ShareCardType,
        privacy: PrivacyDensity,
        accent: CardAccent,
        mood: CardMood,
        headline: String,
        mainLine: String?,
        caption: String,
        hashtags: [String]
    ) {
        self.appName = appName
        self.periodLabel = periodLabel
        self.type = type
        self.privacy = privacy
        self.accent = accent
        self.mood = mood
        self.headline = headline
        self.mainLine = mainLine
        self.caption = caption
        self.hashtags = hashtags
    }
}

public enum ShareCardType: String, Equatable, Sendable {
    case savingsBrag
    case overspendSelfJoke
    case empathy
}

public enum PrivacyDensity: String, CaseIterable, Equatable, Sendable {
    case amount
    case rounded
    case vibeOnly
}

public enum CardAccent: String, Equatable, Sendable {
    case green
    case coral
    case purple
}

public enum CardMood: String, Equatable, Sendable {
    case neutral
    case brag
    case selfJoke
    case empathy
    case welcomeBack
}
