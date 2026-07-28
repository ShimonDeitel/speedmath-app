import Foundation

/// The only thing shared between the app and the widget extension — they
/// run in separate containers, so this is the one channel between them: an
/// App Group UserDefaults suite holding a small read-only snapshot of the
/// stats the widget needs. The app writes it on every `StatsStore.persist()`
/// and pokes `WidgetCenter` to reload; the widget only ever reads.
enum AppGroup {
    static let identifier = "group.com.deitel.speedmath"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: identifier) ?? .standard
    }
}

struct WidgetStatsSnapshot: Codable {
    var level: Int
    var maxLevel: Int
    var gradeLabel: String
    var currentStreak: Int
    var answeredToday: Int
    var dailyGoal: Int
}

enum SharedStatsBridge {
    private static let key = "com.deitel.speedmath.widgetSnapshot"

    static func write(_ snapshot: WidgetStatsSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        AppGroup.defaults.set(data, forKey: key)
    }

    static func read() -> WidgetStatsSnapshot? {
        guard let data = AppGroup.defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(WidgetStatsSnapshot.self, from: data)
    }
}
