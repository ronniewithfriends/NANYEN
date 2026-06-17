enum CopyTemplates {
    static func headline(for type: ShareCardType, review: BudgetReview) -> String {
        switch type {
        case .savingsBrag:
            return "今日だけドヤっていいよ"
        case .overspendSelfJoke:
            return "まあ、楽しかったならヨシ"
        case .empathy:
            if let categoryHint = review.categoryHint {
                return "\(categoryHint)、みんなだいたいそう"
            }
            return "だいたい予定どおり、いい感じ"
        }
    }

    static func caption(for type: ShareCardType, review: BudgetReview, privacy: PrivacyDensity) -> String {
        if privacy == .vibeOnly {
            return "数字は伏せて、雰囲気だけ置いていくね"
        }

        switch type {
        case .savingsBrag:
            return "予算より軽めに着地。えらい、これは小さく拍手。"
        case .overspendSelfJoke:
            return "予算は越えた。でも思い出も乗ってる、たぶん。"
        case .empathy:
            return "細かいことは置いといて、今月もだいたい見えた。"
        }
    }

    static func hashtags(for type: ShareCardType, appName: String) -> [String] {
        let normalizedAppName = appName
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "　", with: "")

        switch type {
        case .savingsBrag:
            return ["#今月の\(normalizedAppName)", "#ドヤ"]
        case .overspendSelfJoke:
            return ["#今月の\(normalizedAppName)", "#反省してない"]
        case .empathy:
            return ["#今月の\(normalizedAppName)", "#あるある"]
        }
    }
}

