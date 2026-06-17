import Foundation

public struct ShareCardGenerator: Sendable {
    public var closeToBudgetThresholdPercent: Int

    public init(closeToBudgetThresholdPercent: Int = 5) {
        self.closeToBudgetThresholdPercent = max(0, closeToBudgetThresholdPercent)
    }

    public func makeCard(from review: BudgetReview, privacy: PrivacyDensity) -> ShareCard {
        let type = classify(review)
        let style = style(for: type)
        let mainLine = MoneyCopy.mainLine(deltaYen: review.deltaYen, privacy: privacy)

        return ShareCard(
            appName: review.appName,
            periodLabel: review.periodLabel,
            type: type,
            privacy: privacy,
            accent: style.accent,
            mood: style.mood,
            headline: CopyTemplates.headline(for: type, review: review),
            mainLine: mainLine,
            caption: CopyTemplates.caption(for: type, review: review, privacy: privacy),
            hashtags: CopyTemplates.hashtags(for: type, appName: review.appName)
        )
    }

    public func classify(_ review: BudgetReview) -> ShareCardType {
        guard review.budgetYen > 0 else {
            return .empathy
        }

        let absoluteDelta = abs(review.deltaYen)
        let threshold = review.budgetYen * closeToBudgetThresholdPercent / 100

        if absoluteDelta <= threshold {
            return .empathy
        }

        return review.actualYen < review.budgetYen ? .savingsBrag : .overspendSelfJoke
    }

    private func style(for type: ShareCardType) -> (accent: CardAccent, mood: CardMood) {
        switch type {
        case .savingsBrag:
            return (.green, .brag)
        case .overspendSelfJoke:
            return (.coral, .selfJoke)
        case .empathy:
            return (.purple, .empathy)
        }
    }
}

private enum MoneyCopy {
    static func mainLine(deltaYen: Int, privacy: PrivacyDensity) -> String? {
        switch privacy {
        case .amount:
            return "だいたい \(signedYen(deltaYen))"
        case .rounded:
            return "だいたい \(signedRoundedYen(deltaYen)) くらい"
        case .vibeOnly:
            return nil
        }
    }

    private static func signedYen(_ value: Int) -> String {
        let sign = value > 0 ? "+" : value < 0 ? "-" : ""
        return "\(sign)\(formatted(abs(value)))円"
    }

    private static func signedRoundedYen(_ value: Int) -> String {
        let sign = value > 0 ? "+" : value < 0 ? "-" : ""
        let rounded = roundedToThousand(abs(value))
        return "\(sign)\(formatted(rounded))円"
    }

    private static func roundedToThousand(_ value: Int) -> Int {
        ((value + 500) / 1_000) * 1_000
    }

    private static func formatted(_ value: Int) -> String {
        value.formatted(.number.grouping(.automatic))
    }
}
