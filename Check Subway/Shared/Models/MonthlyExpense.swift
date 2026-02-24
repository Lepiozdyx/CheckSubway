import Foundation

struct MonthlyExpense: Codable, Identifiable, Hashable {
    var id = UUID()
    var month: Int
    var year: Int
    var passCost: String = ""
    var ridesUsed: String = ""
    var totalRides: String = ""
    var singleTicketPrice: String = ""
    var createdAt = Date()

    var remainingTrips: Int {
        max(0, (Int(totalRides) ?? 0) - (Int(ridesUsed) ?? 0))
    }

    var totalAmount: Int {
        let pass = Int(passCost) ?? 0
        let used = Int(ridesUsed) ?? 0
        let price = Int(singleTicketPrice) ?? 0
        return pass + (used * price)
    }

    var averagePerWeek: Int {
        let total = totalAmount
        return total > 0 ? total / 4 : 0
    }

    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1
        guard let date = Calendar.current.date(from: comps) else { return "" }
        return formatter.string(from: date)
    }

    var weeklyBreakdown: [Int] {
        let total = totalAmount
        guard total > 0 else { return [0, 0, 0, 0] }
        let base = total / 4
        let rem = total % 4
        return (0..<4).map { i in base + (i < rem ? 1 : 0) }
    }
}
