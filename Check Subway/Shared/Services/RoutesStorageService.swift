import Foundation

@MainActor
final class RoutesStorageService {
    private let key = "check_subway_routes"
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

    func load() -> [Route] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? decoder.decode([Route].self, from: data)) ?? []
    }

    func save(_ routes: [Route]) {
        guard let data = try? encoder.encode(routes) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
