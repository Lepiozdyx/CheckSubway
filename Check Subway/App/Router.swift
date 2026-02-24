import Combine
import SwiftUI

enum AppRoute: Hashable {
    case routeDetail(Route)
    case routeCreation
    case routeEdit(Route)
    case stationDetail(ArchivedStation)
    case stationCreation
}

@MainActor
final class Router: ObservableObject {
    @Published var path = NavigationPath()

    func showCreation() {
        path.append(AppRoute.routeCreation)
    }

    func showRouteEdit(route: Route) {
        path.append(AppRoute.routeEdit(route))
    }

    func showDetail(route: Route) {
        path.append(AppRoute.routeDetail(route))
    }

    func showStationDetail(station: ArchivedStation) {
        path.append(AppRoute.stationDetail(station))
    }

    func showStationCreation() {
        path.append(AppRoute.stationCreation)
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
