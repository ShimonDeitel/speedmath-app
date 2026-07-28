import Foundation
import Observation
import WidgetKit

enum AnswerMode: String, Codable {
    case type, speed
}

struct BandStat: Codable {
    var recentResults: [Bool] = [] // most recent last, capped at 20

    mutating func record(_ correct: Bool) {
        recentResults.append(correct)
        if recentResults.count > 20 { recentResults.removeFirst() }
    }

    var accuracy: Double? {
        guard recentResults.count >= 10 else { return nil }
        let correct = recentResults.filter { $0 }.count
        return Double(correct) / Double(recentResults.count)
    }
}

struct StatsSnapshot: Codable {
    var level = 1
    var totalAnswered = 0
    var totalCorrect = 0
    var currentStreak = 0
    var bestStreak = 0
    var bestTimeSeconds: Double?
    var totalTimeSeconds: Double = 0
    var bandStats: [Int: BandStat] = [:] // keyed by grade index (0-based)
    var defaultMode: AnswerMode = .type
    var soundEnabled = true
    var hapticStyle: HapticStyle = .medium
    var displayName: String = ""
    var avatar: AvatarIcon = .stopwatch
    var dailyGoal: Int = 20
    var answeredToday: Int = 0
    var lastAnsweredDay: String = ""
    var hasCompletedOnboarding: Bool = false
    /// The level the placement quiz landed the player on. Free users may
    /// progress up to `placementLevel + StatsStore.freeLevelSpan` before
    /// hitting the hard paywall.
    var placementLevel: Int = 1
}

@Observable
@MainActor
final class StatsStore {
    private static let key = "com.deitel.speedmath.stats"

    private(set) var snapshot: StatsSnapshot
    /// Set for exactly one render pass right after a level-up, so SessionView
    /// can show a celebration and then clear it.
    private(set) var justLeveledUp = false

    init() {
        if CommandLine.arguments.contains("-uitest") {
            snapshot = StatsSnapshot()
            snapshot.hasCompletedOnboarding = true
        } else if let data = UserDefaults.standard.data(forKey: Self.key),
                  let decoded = try? JSONDecoder().decode(StatsSnapshot.self, from: data) {
            snapshot = decoded
        } else {
            snapshot = StatsSnapshot()
        }
        rolloverDailyCountIfNeeded()

        if CommandLine.arguments.contains("-screenshots") {
            loadFlatteringDemoData()
        }
    }

    var level: Int { snapshot.level }

    /// How many levels past placement a free user may reach before the app
    /// hard-blocks progress behind the paywall — "give you a taste" sizing.
    static let freeLevelSpan = 3

    var freeLevelCap: Int {
        min(snapshot.placementLevel + Self.freeLevelSpan, GradeMap.maxLevel)
    }

    func completeOnboarding(placementLevel: Int) {
        let clamped = min(max(placementLevel, GradeMap.minLevel), GradeMap.maxLevel)
        snapshot.placementLevel = clamped
        snapshot.level = clamped
        snapshot.hasCompletedOnboarding = true
        persist()
    }

    func recordAnswer(correct: Bool, elapsed: TimeInterval, level: Int) {
        rolloverDailyCountIfNeeded()
        let leveledUp = level > snapshot.level
        snapshot.level = level
        snapshot.totalAnswered += 1
        snapshot.answeredToday += 1
        snapshot.totalTimeSeconds += elapsed
        if correct {
            snapshot.totalCorrect += 1
            snapshot.currentStreak += 1
            snapshot.bestStreak = max(snapshot.bestStreak, snapshot.currentStreak)
            if snapshot.bestTimeSeconds == nil || elapsed < snapshot.bestTimeSeconds! {
                snapshot.bestTimeSeconds = elapsed
            }
        } else {
            snapshot.currentStreak = 0
        }
        let bandIndex = GradeMap.gradeIndex(for: level)
        var band = snapshot.bandStats[bandIndex] ?? BandStat()
        band.record(correct)
        snapshot.bandStats[bandIndex] = band
        persist()
        if leveledUp {
            justLeveledUp = true
        }
    }

    func clearLevelUpFlag() {
        justLeveledUp = false
    }

    func setLevel(_ level: Int) {
        snapshot.level = level
        persist()
    }

    func setDefaultMode(_ mode: AnswerMode) {
        snapshot.defaultMode = mode
        persist()
    }

    func setSoundEnabled(_ on: Bool) {
        snapshot.soundEnabled = on
        persist()
    }

    func setHapticStyle(_ style: HapticStyle) {
        snapshot.hapticStyle = style
        persist()
    }

    func setDisplayName(_ name: String) {
        snapshot.displayName = name
        persist()
    }

    func setAvatar(_ avatar: AvatarIcon) {
        snapshot.avatar = avatar
        persist()
    }

    func setDailyGoal(_ goal: Int) {
        snapshot.dailyGoal = goal
        persist()
    }

    var averageTimeSeconds: Double {
        guard snapshot.totalAnswered > 0 else { return 0 }
        return snapshot.totalTimeSeconds / Double(snapshot.totalAnswered)
    }

    var overallAccuracy: Double {
        guard snapshot.totalAnswered > 0 else { return 0 }
        return Double(snapshot.totalCorrect) / Double(snapshot.totalAnswered)
    }

    var dailyGoalProgress: Double {
        guard snapshot.dailyGoal > 0 else { return 0 }
        return min(1, Double(snapshot.answeredToday) / Double(snapshot.dailyGoal))
    }

    var dailyGoalMet: Bool {
        snapshot.answeredToday >= snapshot.dailyGoal
    }

    /// Per-band accuracy for every band with enough samples to be meaningful,
    /// in grade order (by band index, not alphabetically — "Grade 10" would
    /// otherwise sort before "Grade 2") — feeds the Profile breakdown list.
    var bandAccuracyBreakdown: [(label: String, accuracy: Double)] {
        snapshot.bandStats
            .compactMap { index, stat -> (Int, String, Double)? in
                guard let acc = stat.accuracy else { return nil }
                return (index, GradeMap.gradeLabel(forBandIndex: index), acc)
            }
            .sorted { $0.0 < $1.0 }
            .map { (label: $0.1, accuracy: $0.2) }
    }

    /// "Performing at Grade X": the highest band with enough samples and
    /// >= 70% accuracy, falling back to the current level's grade.
    var performingGradeLabel: String {
        let qualifyingBands = snapshot.bandStats
            .filter { ($0.value.accuracy ?? 0) >= 0.7 }
            .map(\.key)
        if let best = qualifyingBands.max() {
            return GradeMap.gradeLabel(forBandIndex: best)
        }
        return GradeMap.gradeLabel(for: snapshot.level)
    }

    private func rolloverDailyCountIfNeeded() {
        let today = Self.dayString(for: Date())
        if snapshot.lastAnsweredDay != today {
            snapshot.lastAnsweredDay = today
            snapshot.answeredToday = 0
        }
    }

    private static func dayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.string(from: date)
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: Self.key)
        guard !CommandLine.arguments.contains("-uitest") else { return }
        SharedStatsBridge.write(WidgetStatsSnapshot(
            level: snapshot.level,
            maxLevel: GradeMap.maxLevel,
            gradeLabel: GradeMap.gradeLabel(for: snapshot.level),
            currentStreak: snapshot.currentStreak,
            answeredToday: snapshot.answeredToday,
            dailyGoal: snapshot.dailyGoal))
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func loadFlatteringDemoData() {
        var demo = StatsSnapshot()
        demo.hasCompletedOnboarding = true
        demo.placementLevel = 1
        demo.level = 47
        demo.totalAnswered = 812
        demo.totalCorrect = 701
        demo.currentStreak = 14
        demo.bestStreak = 38
        demo.bestTimeSeconds = 1.9
        demo.totalTimeSeconds = 812 * 6.4
        demo.displayName = "Speed Racer"
        demo.answeredToday = 14
        demo.dailyGoal = 20
        var band = BandStat()
        band.recentResults = Array(repeating: true, count: 17) + Array(repeating: false, count: 3)
        demo.bandStats[4] = band
        snapshot = demo
    }
}
