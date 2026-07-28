import Foundation

/// Expert. Levels 141...1500 — the long tail of the ladder. Number theory,
/// probability, implicit differentiation, means; none of these scale
/// difficulty by level, so the wide range stays fair throughout.
enum Band10Expert {
    static let range: ClosedRange<Int> = 141...1500
    private static let topic = "Expert"

    private static let pythagoreanTriples: [(Int, Int, Int)] = [
        (3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25), (20, 21, 29), (9, 40, 41),
    ]

    static let templates: [QuestionTemplate] = [
        QuestionTemplate(id: "gcd.compute", topic: topic, levels: range) { level, rng in
            let a = rInt(12...200, &rng)
            let b = rInt(12...200, &rng)
            let answer = gcdInt(a, b)
            let steps = buildSteps {
                $0.add("Use the Euclidean algorithm on \(a) and \(b).")
                $0.add("The greatest common divisor is \(answer).")
            }
            return Question(templateID: "gcd.compute", topic: topic, level: level,
                             prompt: "gcd(\(a), \(b))", spokenPrompt: "The greatest common divisor of \(a) and \(b)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "lcm.compute", topic: topic, levels: range) { level, rng in
            let a = rInt(2...30, &rng)
            let b = rInt(2...30, &rng)
            let g = gcdInt(a, b)
            let answer = a * b / g
            let steps = buildSteps {
                $0.add("lcm(a,b) = a × b ÷ gcd(a,b). gcd(\(a),\(b)) = \(g).")
                $0.add("\(a) × \(b) ÷ \(g) = \(answer).")
            }
            return Question(templateID: "lcm.compute", topic: topic, level: level,
                             prompt: "lcm(\(a), \(b))", spokenPrompt: "The least common multiple of \(a) and \(b)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "modular.arithmetic", topic: topic, levels: range) { level, rng in
            let n = rInt(20...999, &rng)
            let m = rInt(2...12, &rng)
            let answer = n % m
            let steps = buildSteps {
                $0.add("\(n) mod \(m) is the remainder after dividing \(n) by \(m).")
                $0.add("\(n) ÷ \(m) = \(n / m) remainder \(answer).")
            }
            return Question(templateID: "modular.arithmetic", topic: topic, level: level,
                             prompt: "\(n) mod \(m)", spokenPrompt: "\(n) mod \(m)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "probability.simple", topic: topic, levels: range) { level, rng in
            let totalOptions = [6, 8, 10, 12]
            let total = totalOptions[rInt(0...(totalOptions.count - 1), &rng)]
            let favorable = rInt(1...(total - 1), &rng)
            let answer = AnswerValue.reducedFraction(favorable, total)
            let steps = buildSteps {
                $0.add("Probability = favorable outcomes ÷ total outcomes = \(favorable)/\(total).")
                $0.add("Reduced: \(answer).")
            }
            return Question(templateID: "probability.simple", topic: topic, level: level,
                             prompt: "\(favorable) of \(total) equally likely outcomes — probability?",
                             spokenPrompt: "\(favorable) out of \(total) equally likely outcomes, what is the probability, as a fraction?",
                             answer: answer, steps: steps)
        },
        QuestionTemplate(id: "implicit.diff.circle", topic: topic, levels: range) { level, rng in
            let triple = pythagoreanTriples[rInt(0...(pythagoreanTriples.count - 1), &rng)]
            let k = rInt(1...3, &rng)
            let x0 = triple.0 * k, y0 = triple.1 * k
            let r2 = triple.2 * triple.2 * k * k
            let answer = AnswerValue.reducedFraction(-x0, y0)
            let steps = buildSteps {
                $0.add("For x² + y² = r², implicit differentiation gives dy/dx = -x/y.")
                $0.add("At (\(x0), \(y0)): dy/dx = -\(x0)/\(y0) = \(answer).")
            }
            return Question(templateID: "implicit.diff.circle", topic: topic, level: level,
                             prompt: "x² + y² = \(r2), dy/dx at (\(x0), \(y0))",
                             spokenPrompt: "For x squared plus y squared equals \(r2), what is dy dx at \(x0), \(y0)?",
                             answer: answer, steps: steps)
        },
        QuestionTemplate(id: "geometric.mean", topic: topic, levels: range) { level, rng in
            let a = rInt(2...20, &rng)
            let b = rInt(2...20, &rng)
            let aSq = a * a, bSq = b * b
            let answer = a * b
            let steps = buildSteps {
                $0.add("Geometric mean of x and y is √(xy). Here xy = \(aSq) × \(bSq) = \(aSq * bSq), a perfect square.")
                $0.add("√\(aSq * bSq) = \(answer).")
            }
            return Question(templateID: "geometric.mean", topic: topic, level: level,
                             prompt: "Geometric mean of \(aSq) and \(bSq)",
                             spokenPrompt: "The geometric mean of \(aSq) and \(bSq)",
                             answer: .integer(answer), steps: steps)
        },
    ]
}
