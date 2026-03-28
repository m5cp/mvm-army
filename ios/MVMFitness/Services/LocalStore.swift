import Foundation

enum LocalStore {
    static func save<T: Codable>(_ value: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load<T: Codable>(_ type: T.Type, forKey key: String, fallback: T) -> T {
        guard let data = UserDefaults.standard.data(forKey: key) else { return fallback }
        let decoder = JSONDecoder()
        return (try? decoder.decode(type, from: data)) ?? fallback
    }
}
