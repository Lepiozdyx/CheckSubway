import Combine
import Foundation
import SwiftUI

@MainActor
final class StationsStore: ObservableObject {
    @Published private(set) var stations: [ArchivedStation] = []
    private let storage = StationsStorageService()

    init() {
        stations = storage.load()
    }

    func add(_ station: ArchivedStation) {
        var updated = stations
        updated.append(station)
        apply(updated)
    }

    func update(_ station: ArchivedStation) {
        guard let i = stations.firstIndex(where: { $0.id == station.id }) else { return }
        var updated = stations
        updated[i] = station
        apply(updated)
    }

    func delete(_ station: ArchivedStation) {
        let updated = stations.filter { $0.id != station.id }
        apply(updated)
    }

    func station(byId id: UUID) -> ArchivedStation? {
        stations.first { $0.id == id }
    }

    func station(byName name: String) -> ArchivedStation? {
        stations.first { $0.name == name }
    }

    private func apply(_ updated: [ArchivedStation]) {
        stations = updated
        storage.save(updated)
    }
}
