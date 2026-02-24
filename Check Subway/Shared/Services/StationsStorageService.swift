import Foundation

@MainActor
final class StationsStorageService {
    private let key = "check_subway_archived_stations"
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

    func load() -> [ArchivedStation] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? decoder.decode([ArchivedStation].self, from: data)) ?? []
    }

    func save(_ stations: [ArchivedStation]) {
        guard let data = try? encoder.encode(stations) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
