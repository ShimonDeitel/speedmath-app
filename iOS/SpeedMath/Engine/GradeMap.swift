import Foundation

/// Ten levels per grade, 1...130: levels 1-10 are Grade 1, ... 111-120 are
/// Grade 12, and 121-130 are University.
enum GradeMap {
    static let minLevel = 1
    static let maxLevel = 130

    static func gradeIndex(for level: Int) -> Int {
        let clamped = min(max(level, minLevel), maxLevel)
        return (clamped - 1) / 10 // 0-based: 0...11 grades, 12 = university
    }

    static func gradeLabel(for level: Int) -> String {
        let index = gradeIndex(for: level)
        if index >= 12 { return "University" }
        return "Grade \(index + 1)"
    }

    /// The first level of the grade band containing `level`.
    static func bandStart(for level: Int) -> Int {
        gradeIndex(for: level) * 10 + 1
    }
}
