import Foundation
import SwiftUI

struct Route: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var walkTimeMinutes: Int
    var metroTimeMinutes: Int
    var stationNames: [String]
    var createdAt: Date

    var totalTimeMinutes: Int {
        walkTimeMinutes + metroTimeMinutes
    }

    init(
        id: UUID = UUID(),
        name: String,
        walkTimeMinutes: Int = 0,
        metroTimeMinutes: Int = 0,
        stationNames: [String] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.walkTimeMinutes = walkTimeMinutes
        self.metroTimeMinutes = metroTimeMinutes
        self.stationNames = stationNames
        self.createdAt = createdAt
    }
}

struct ArchivedStation: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var lineColorHex: String
    var rating: Int
    var notes: String
    var photoData: Data?
    var createdAt: Date

    var lineColor: Color {
        Color(hex: lineColorHex) ?? .yellow
    }

    init(
        id: UUID = UUID(),
        name: String,
        lineColorHex: String = "FFDC04",
        rating: Int = 0,
        notes: String = "",
        photoData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.lineColorHex = lineColorHex
        self.rating = rating
        self.notes = notes
        self.photoData = photoData
        self.createdAt = createdAt
    }
}

extension Color {
    init?(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard cleaned.count == 6 else { return nil }
        var rgb: UInt64 = 0
        guard Scanner(string: cleaned).scanHexInt64(&rgb) else { return nil }
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}
