import Combine
import Foundation
import SwiftUI

@MainActor
final class ExpensesStore: ObservableObject {
    @Published private(set) var expenses: [MonthlyExpense] = []
    private let storage = ExpensesStorageService()

    init() {
        expenses = storage.load()
    }

    func add(_ expense: MonthlyExpense) {
        var updated = expenses
        updated.append(expense)
        apply(updated)
    }

    func update(_ expense: MonthlyExpense) {
        guard let i = expenses.firstIndex(where: { $0.id == expense.id }) else { return }
        var updated = expenses
        updated[i] = expense
        apply(updated)
    }

    func delete(_ expense: MonthlyExpense) {
        let updated = expenses.filter { $0.id != expense.id }
        apply(updated)
    }

    func expensesForMonth(_ month: Int, year: Int) -> [MonthlyExpense] {
        expenses.filter { $0.month == month && $0.year == year }
    }

    func totalForMonth(_ month: Int, year: Int) -> Int {
        expensesForMonth(month, year: year).reduce(0) { $0 + $1.totalAmount }
    }

    private func apply(_ updated: [MonthlyExpense]) {
        expenses = updated
        storage.save(updated)
    }
}
