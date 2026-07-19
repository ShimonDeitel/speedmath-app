import Foundation

/// Grade 11. Levels 101...110. Special-angle trig, Pythagorean triples, sequences.
enum Band06TrigSequences {
    static let range: ClosedRange<Int> = 101...110
    private static let topic = "Trig & Sequences"

    /// Only angle/function pairs with a clean (non-radical) exact value —
    /// every generated answer must be typeable and speakable.
    private static let trigTable: [(fn: String, angle: Int, value: AnswerValue)] = [
        ("sin", 0, .integer(0)), ("sin", 30, .fraction(num: 1, den: 2)), ("sin", 90, .integer(1)),
        ("cos", 0, .integer(1)), ("cos", 60, .fraction(num: 1, den: 2)), ("cos", 90, .integer(0)),
        ("tan", 0, .integer(0)), ("tan", 45, .integer(1)),
    ]

    private static let pythagoreanTriples: [(Int, Int, Int)] = [
        (3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25), (20, 21, 29), (9, 40, 41),
    ]

    static let templates: [QuestionTemplate] = [
        QuestionTemplate(id: "trig.special", topic: topic, levels: range) { level, rng in
            let entry = trigTable[rInt(0...(trigTable.count - 1), &rng)]
            let steps = buildSteps {
                $0.add("\(entry.fn) \(entry.angle)° is one of the standard special-angle values.")
                $0.add("Answer: \(entry.value).")
            }
            return Question(templateID: "trig.special", topic: topic, level: level,
                             prompt: "\(entry.fn) \(entry.angle)°", spokenPrompt: "\(entry.fn) of \(entry.angle) degrees",
                             answer: entry.value, steps: steps)
        },
        QuestionTemplate(id: "pythagorean.hypotenuse", topic: topic, levels: range) { level, rng in
            let triple = pythagoreanTriples[rInt(0...(pythagoreanTriples.count - 1), &rng)]
            let k = rInt(1...4, &rng)
            let a = triple.0 * k, b = triple.1 * k, c = triple.2 * k
            let steps = buildSteps {
                $0.add("By the Pythagorean theorem, hypotenuse² = \(a)² + \(b)² = \(a * a) + \(b * b) = \(a * a + b * b).")
                $0.add("√\(a * a + b * b) = \(c).")
            }
            return Question(templateID: "pythagorean.hypotenuse", topic: topic, level: level,
                             prompt: "Right triangle legs \(a), \(b) — hypotenuse?",
                             spokenPrompt: "A right triangle has legs \(a) and \(b). What is the hypotenuse?",
                             answer: .integer(c), steps: steps)
        },
        QuestionTemplate(id: "sequence.arithmetic", topic: topic, levels: range) { level, rng in
            let a1 = rInt(-10...10, &rng)
            let d = rInt(-6...6, &rng) == 0 ? 2 : rInt(-6...6, &rng)
            let n = rInt(4...20, &rng)
            let answer = a1 + (n - 1) * d
            let steps = buildSteps {
                $0.add("Term n = a₁ + (n - 1)d = \(a1) + (\(n) - 1) × \(d).")
                $0.add("= \(a1) + \(n - 1) × \(d) = \(answer).")
            }
            return Question(templateID: "sequence.arithmetic", topic: topic, level: level,
                             prompt: "Arithmetic: a₁=\(a1), d=\(d), term \(n)?",
                             spokenPrompt: "An arithmetic sequence starts at \(a1) with common difference \(d). What is term \(n)?",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "sequence.geometric", topic: topic, levels: range) { level, rng in
            let a1 = rInt(1...5, &rng)
            let r = rInt(2...4, &rng)
            let n = rInt(2...5, &rng)
            let answer = a1 * Int(pow(Double(r), Double(n - 1)))
            let steps = buildSteps {
                $0.add("Term n = a₁ × r^(n-1) = \(a1) × \(r)^\(n - 1).")
                $0.add("Answer: \(answer).")
            }
            return Question(templateID: "sequence.geometric", topic: topic, level: level,
                             prompt: "Geometric: a₁=\(a1), r=\(r), term \(n)?",
                             spokenPrompt: "A geometric sequence starts at \(a1) with ratio \(r). What is term \(n)?",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "sigma.integers", topic: topic, levels: range) { level, rng in
            let n = rInt(3...30, &rng)
            let answer = n * (n + 1) / 2
            let steps = buildSteps {
                $0.add("Sum of the first n integers = n(n+1)/2 = \(n)(\(n + 1))/2.")
                $0.add("= \(n * (n + 1)) ÷ 2 = \(answer).")
            }
            return Question(templateID: "sigma.integers", topic: topic, level: level,
                             prompt: "1 + 2 + ... + \(n)", spokenPrompt: "The sum of 1 through \(n)",
                             answer: .integer(answer), steps: steps)
        },
    ]
}
