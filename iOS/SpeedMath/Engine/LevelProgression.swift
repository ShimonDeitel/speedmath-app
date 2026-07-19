import Foundation

/// Target answer time (seconds) per grade band — used to decide whether a
/// correct answer was "fast enough" to count toward leveling up.
enum PaceTarget {
    static func seconds(forLevel level: Int) -> Double {
        let index = GradeMap.gradeIndex(for: level)
        switch index {
        case 0...1: return 6      // Grade 1-2
        case 2...4: return 10     // Grade 3-5
        case 5: return 14         // Grade 6
        case 6...7: return 18     // Grade 7-8
        case 8...9: return 25     // Grade 9-10
        case 10: return 32        // Grade 11
        case 11: return 40        // Grade 12
        default: return 45        // University
        }
    }
}

/// Pure decision logic for leveling: 3 consecutive fast-correct answers move
/// the player up a level; 2 consecutive wrong answers move them down.
/// Level is clamped to [1, 130]; the caller owns persistence.
struct LevelProgression {
    private(set) var level: Int
    private var fastCorrectStreak = 0
    private var wrongStreak = 0

    init(level: Int) {
        self.level = min(max(level, GradeMap.minLevel), GradeMap.maxLevel)
    }

    mutating func recordAnswer(correct: Bool, elapsed: TimeInterval) {
        if correct {
            wrongStreak = 0
            if elapsed <= PaceTarget.seconds(forLevel: level) {
                fastCorrectStreak += 1
            } else {
                fastCorrectStreak = 0
            }
            if fastCorrectStreak >= 3 {
                fastCorrectStreak = 0
                level = min(level + 1, GradeMap.maxLevel)
            }
        } else {
            fastCorrectStreak = 0
            wrongStreak += 1
            if wrongStreak >= 2 {
                wrongStreak = 0
                level = max(level - 1, GradeMap.minLevel)
            }
        }
    }

    mutating func jump(toLevel newLevel: Int) {
        level = min(max(newLevel, GradeMap.minLevel), GradeMap.maxLevel)
        fastCorrectStreak = 0
        wrongStreak = 0
    }
}
