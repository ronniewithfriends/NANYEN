import Foundation

public struct BudgetReview: Equatable, Sendable {
    public let appName: String
    public let periodLabel: String
    public let budgetYen: Int
    public let actualYen: Int
    public let categoryHint: String?

    public init(
        appName: String = "NANYEN",
        periodLabel: String,
        budgetYen: Int,
        actualYen: Int,
        categoryHint: String? = nil
    ) throws {
        guard !appName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw BudgetReviewError.emptyAppName
        }
        guard !periodLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw BudgetReviewError.emptyPeriodLabel
        }
        guard budgetYen >= 0 else {
            throw BudgetReviewError.negativeBudget
        }
        guard actualYen >= 0 else {
            throw BudgetReviewError.negativeActual
        }

        self.appName = appName
        self.periodLabel = periodLabel
        self.budgetYen = budgetYen
        self.actualYen = actualYen
        self.categoryHint = categoryHint?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
    }

    public var deltaYen: Int {
        actualYen - budgetYen
    }
}

public enum BudgetReviewError: Error, Equatable {
    case emptyAppName
    case emptyPeriodLabel
    case negativeBudget
    case negativeActual
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
