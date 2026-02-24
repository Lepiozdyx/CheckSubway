import Foundation

@MainActor
final class ExpensesStorageService {
    private let key = "check_subway_expenses"
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    func load() -> [MonthlyExpense] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? decoder.decode([MonthlyExpense].self, from: data)) ?? []
    }

    func save(_ expenses: [MonthlyExpense]) {
        guard let data = try? encoder.encode(expenses) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
