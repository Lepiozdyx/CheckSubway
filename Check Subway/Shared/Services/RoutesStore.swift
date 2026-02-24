import Combine
import Foundation
import SwiftUI

@MainActor
final class RoutesStore: ObservableObject {
    @Published private(set) var routes: [Route] = []
    private let storage = RoutesStorageService()

    init() {
        routes = storage.load()
    }

    func add(_ route: Route) {
        var updated = routes
        updated.append(route)
        apply(updated)
    }

    func update(_ route: Route) {
        guard let i = routes.firstIndex(where: { $0.id == route.id }) else { return }
        var updated = routes
        updated[i] = route
        apply(updated)
    }

    func delete(_ route: Route) {
        let updated = routes.filter { $0.id != route.id }
        apply(updated)
    }

    func route(byId id: UUID) -> Route? {
        routes.first { $0.id == id }
    }

    private func apply(_ updated: [Route]) {
        routes = updated
        storage.save(updated)
    }
}
