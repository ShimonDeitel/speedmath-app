import Foundation

/// Levels 1...120 are Grade 1-12 (ten levels per grade). Beyond that, three
/// named tiers carry the rest of the ladder up to 1500: University
/// (121-130), Advanced (131-140), and Expert (141-1500) — Expert is wide
/// because its templates (number theory, probability, calculus) don't need
/// level-scaled difficulty to stay challenging, so it comfortably absorbs
/// the long tail of the ladder.
enum GradeMap {
    static let minLevel = 1
    static let maxLevel = 1500

    private static let tiers: [(name: String, start: Int, end: Int)] = [
        ("University", 121, 130),
        ("Advanced", 131, 140),
        ("Expert", 141, 1500),
    ]

    static var bandCount: Int { 12 + tiers.count }

    static func gradeIndex(for level: Int) -> Int {
        let clamped = min(max(level, minLevel), maxLevel)
        if clamped <= 120 { return (clamped - 1) / 10 } // 0-based: 0...11 grades
        for (offset, tier) in tiers.enumerated() where clamped <= tier.end {
            return 12 + offset
        }
        return 12 + tiers.count - 1
    }

    static func gradeLabel(for level: Int) -> String {
        gradeLabel(forBandIndex: gradeIndex(for: level))
    }

    static func gradeLabel(forBandIndex index: Int) -> String {
        if index < 12 { return "Grade \(index + 1)" }
        let tierIndex = min(index - 12, tiers.count - 1)
        return tiers[tierIndex].name
    }

    /// The first level of the band with this 0-based index.
    static func firstLevel(ofBandIndex index: Int) -> Int {
        if index < 12 { return index * 10 + 1 }
        let tierIndex = min(index - 12, tiers.count - 1)
        return tiers[tierIndex].start
    }

    /// The first level of the band containing `level`.
    static func bandStart(for level: Int) -> Int {
        firstLevel(ofBandIndex: gradeIndex(for: level))
    }
}
