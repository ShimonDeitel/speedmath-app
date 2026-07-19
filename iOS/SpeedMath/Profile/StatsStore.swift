import Foundation
import Observation

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
    var hapticsEnabled = true
    var displayName: String = ""
}

@Observable
@MainActor
final class StatsStore {
    private static let key = "com.deitel.speedmath.stats"

    private(set) var snapshot: StatsSnapshot

    init() {
        if CommandLine.arguments.contains("-uitest") {
            snapshot = StatsSnapshot()
        } else if let data = UserDefaults.standard.data(forKey: Self.key),
                  let decoded = try? JSONDecoder().decode(StatsSnapshot.self, from: data) {
            snapshot = decoded
        } else {
            snapshot = StatsSnapshot()
        }

        if CommandLine.arguments.contains("-screenshots") {
            loadFlatteringDemoData()
        }
    }

    var level: Int { snapshot.level }

    func recordAnswer(correct: Bool, elapsed: TimeInterval, level: Int) {
        snapshot.level = level
        snapshot.totalAnswered += 1
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

    func setHapticsEnabled(_ on: Bool) {
        snapshot.hapticsEnabled = on
        persist()
    }

    func setDisplayName(_ name: String) {
        snapshot.displayName = name
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

    /// "Performing at Grade X": the highest grade band with enough samples
    /// and >= 70% accuracy, falling back to the current level's grade.
    var performingGradeLabel: String {
        let qualifyingBands = snapshot.bandStats
            .filter { ($0.value.accuracy ?? 0) >= 0.7 }
            .map(\.key)
        if let best = qualifyingBands.max() {
            return best >= 12 ? "University" : "Grade \(best + 1)"
        }
        return GradeMap.gradeLabel(for: snapshot.level)
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: Self.key)
    }

    private func loadFlatteringDemoData() {
        var demo = StatsSnapshot()
        demo.level = 47
        demo.totalAnswered = 812
        demo.totalCorrect = 701
        demo.currentStreak = 14
        demo.bestStreak = 38
        demo.bestTimeSeconds = 1.9
        demo.totalTimeSeconds = 812 * 6.4
        demo.displayName = "Speed Racer"
        var band = BandStat()
        band.recentResults = Array(repeating: true, count: 17) + Array(repeating: false, count: 3)
        demo.bandStats[4] = band
        snapshot = demo
    }
}
