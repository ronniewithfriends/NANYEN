import NANYENCore

@main
struct NANYENCoreChecks {
    static func main() throws {
        try checkSavingsBragUsesGreenSmugCard()
        try checkOverspendUsesCoralSelfJokeWithoutBlame()
        try checkCloseToBudgetBecomesEmpathy()
        try checkVibeOnlyHidesNumbers()
        try checkCategoryHintCanDriveEmpathyCopy()
        checkInvalidNegativeActualIsRejected()

        print("NANYENCoreChecks passed")
    }

    private static func checkSavingsBragUsesGreenSmugCard() throws {
        let review = try BudgetReview(periodLabel: "2026年6月", budgetYen: 50_000, actualYen: 42_000)
        let card = ShareCardGenerator().makeCard(from: review, privacy: .amount)

        require(card.type == .savingsBrag)
        require(card.accent == .green)
        require(card.mood == .brag)
        require(card.mainLine == "だいたい -8,000円")
        require(card.hashtags == ["#今月のNANYEN", "#ドヤ"])
    }

    private static func checkOverspendUsesCoralSelfJokeWithoutBlame() throws {
        let review = try BudgetReview(periodLabel: "2026年6月", budgetYen: 30_000, actualYen: 42_000)
        let card = ShareCardGenerator().makeCard(from: review, privacy: .amount)

        require(card.type == .overspendSelfJoke)
        require(card.accent == .coral)
        require(card.mood == .selfJoke)
        require(card.mainLine == "だいたい +12,000円")
        require(!card.headline.contains("ダメ"))
        require(!card.caption.contains("使いすぎ"))
    }

    private static func checkCloseToBudgetBecomesEmpathy() throws {
        let review = try BudgetReview(periodLabel: "2026年6月", budgetYen: 100_000, actualYen: 104_000)
        let card = ShareCardGenerator().makeCard(from: review, privacy: .rounded)

        require(card.type == .empathy)
        require(card.accent == .purple)
        require(card.mood == .empathy)
        require(card.mainLine == "だいたい +4,000円 くらい")
    }

    private static func checkVibeOnlyHidesNumbers() throws {
        let review = try BudgetReview(periodLabel: "2026年6月", budgetYen: 50_000, actualYen: 65_000)
        let card = ShareCardGenerator().makeCard(from: review, privacy: .vibeOnly)

        require(card.mainLine == nil)
        require(card.caption == "数字は伏せて、雰囲気だけ置いていくね")
    }

    private static func checkCategoryHintCanDriveEmpathyCopy() throws {
        let review = try BudgetReview(
            periodLabel: "2026年6月",
            budgetYen: 0,
            actualYen: 12_000,
            categoryHint: "コンビニ"
        )
        let card = ShareCardGenerator().makeCard(from: review, privacy: .amount)

        require(card.type == .empathy)
        require(card.headline == "コンビニ、みんなだいたいそう")
    }

    private static func checkInvalidNegativeActualIsRejected() {
        do {
            _ = try BudgetReview(periodLabel: "2026年6月", budgetYen: 10_000, actualYen: -1)
            fatalError("Expected negative actual to throw")
        } catch BudgetReviewError.negativeActual {
        } catch {
            fatalError("Unexpected error: \(error)")
        }
    }

    private static func require(_ condition: @autoclosure () -> Bool) {
        guard condition() else {
            fatalError("Core check failed")
        }
    }
}
