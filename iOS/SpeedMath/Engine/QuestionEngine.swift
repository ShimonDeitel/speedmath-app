import Foundation

enum QuestionEngine {
    /// All templates across every band. Registered once, lazily, in id order.
    static let registry: [QuestionTemplate] = {
        var all: [QuestionTemplate] = []
        all.append(contentsOf: Band01Counting.templates)
        all.append(contentsOf: Band02MultDivFractions.templates)
        all.append(contentsOf: Band03DecimalsPercent.templates)
        all.append(contentsOf: Band04PreAlgebra.templates)
        all.append(contentsOf: Band05Quadratics.templates)
        all.append(contentsOf: Band06TrigSequences.templates)
        all.append(contentsOf: Band07Calculus.templates)
        all.append(contentsOf: Band08University.templates)
        return all
    }()

    /// Templates whose level range contains `level`.
    static func templates(forLevel level: Int) -> [QuestionTemplate] {
        registry.filter { $0.levels.contains(level) }
    }

    /// Picks a template for `level`, avoiding the last few template ids used
    /// (for variety) when an alternative exists, then generates a question.
    static func next(
        level: Int,
        rng: inout SeededRNG,
        recentTemplateIDs: [String] = []
    ) -> Question {
        let candidates = templates(forLevel: level)
        precondition(!candidates.isEmpty, "no templates registered for level \(level)")

        let fresh = candidates.filter { !recentTemplateIDs.suffix(3).contains($0.id) }
        let pool = fresh.isEmpty ? candidates : fresh

        let index = Int(rng.next() % UInt64(pool.count))
        let template = pool[index]
        return template.make(level, &rng)
    }
}
