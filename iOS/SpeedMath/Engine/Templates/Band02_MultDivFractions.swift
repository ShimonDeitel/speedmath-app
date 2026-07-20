import Foundation

/// Grade 3-4. Levels 21...40. Multiplication, division, intro fractions.
enum Band02MultDivFractions {
    static let range: ClosedRange<Int> = 21...40
    private static let topic = "Multiplication & Fractions"
    private static let niceDenoms = [2, 3, 4, 5, 6, 8, 10, 12]

    static let templates: [QuestionTemplate] = [
        QuestionTemplate(id: "times.table", topic: topic, levels: range) { level, rng in
            let a = rInt(1...12, &rng), b = rInt(1...12, &rng)
            let steps = buildSteps { $0.add("Multiply \(a) × \(b).") ; $0.add("Answer: \(a * b).") }
            return Question(templateID: "times.table", topic: topic, level: level,
                             prompt: "\(a) × \(b)", spokenPrompt: "\(a) times \(b)",
                             answer: .integer(a * b), steps: steps)
        },
        QuestionTemplate(id: "mult.2digit.1digit", topic: topic, levels: range) { level, rng in
            let a = rInt(11...99, &rng), b = rInt(2...9, &rng)
            let steps = buildSteps {
                $0.add("Multiply \(a) × \(b) by breaking \(a) into tens and ones.")
                $0.add("Answer: \(a * b).")
            }
            return Question(templateID: "mult.2digit.1digit", topic: topic, level: level,
                             prompt: "\(a) × \(b)", spokenPrompt: "\(a) times \(b)",
                             answer: .integer(a * b), steps: steps)
        },
        QuestionTemplate(id: "div.exact", topic: topic, levels: range) { level, rng in
            let b = rInt(2...12, &rng), q = rInt(2...12, &rng)
            let a = b * q
            let steps = buildSteps { $0.add("\(a) ÷ \(b) divides evenly.") ; $0.add("Answer: \(q).") }
            return Question(templateID: "div.exact", topic: topic, level: level,
                             prompt: "\(a) ÷ \(b)", spokenPrompt: "\(a) divided by \(b)",
                             answer: .integer(q), steps: steps)
        },
        QuestionTemplate(id: "div.remainder", topic: topic, levels: range) { level, rng in
            let b = rInt(3...9, &rng)
            let q = rInt(2...12, &rng)
            let r = rInt(1...(b - 1), &rng)
            let a = b * q + r
            let steps = buildSteps {
                $0.add("\(b) goes into \(a) \(q) times, using \(b * q).")
                $0.add("What's left over: \(a) - \(b * q) = \(r).")
            }
            return Question(templateID: "div.remainder", topic: topic, level: level,
                             prompt: "Remainder of \(a) ÷ \(b)", spokenPrompt: "What is the remainder of \(a) divided by \(b)?",
                             answer: .integer(r), steps: steps)
        },
        QuestionTemplate(id: "fraction.of.whole", topic: topic, levels: range) { level, rng in
            let d = niceDenoms[rInt(0...(niceDenoms.count - 1), &rng)]
            let k = rInt(1...10, &rng)
            let whole = d * k
            let n = rInt(1...(d - 1), &rng)
            let answer = n * k
            let steps = buildSteps {
                $0.add("Divide \(whole) into \(d) equal parts: \(whole) ÷ \(d) = \(k).")
                $0.add("Take \(n) of those parts: \(n) × \(k) = \(answer).")
            }
            return Question(templateID: "fraction.of.whole", topic: topic, level: level,
                             prompt: "\(n)/\(d) of \(whole)", spokenPrompt: "What is \(n) over \(d) of \(whole)?",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "equivalent.fraction", topic: topic, levels: range) { level, rng in
            let d = rInt(2...9, &rng)
            let n = rInt(1...(d - 1), &rng)
            let m = rInt(2...6, &rng)
            let targetDen = d * m
            let answer = n * m
            let steps = buildSteps {
                $0.add("\(d) × \(m) = \(targetDen), so multiply the top by \(m) too.")
                $0.add("\(n) × \(m) = \(answer).")
            }
            return Question(templateID: "equivalent.fraction", topic: topic, level: level,
                             prompt: "\(n)/\(d) = ?/\(targetDen)", spokenPrompt: "\(n) over \(d) equals what over \(targetDen)?",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "add.fraction.samedenom", topic: topic, levels: range) { level, rng in
            let d = rInt(2...12, &rng)
            let n1 = rInt(1...(d - 1), &rng)
            let n2 = rInt(1...(d - 1), &rng)
            let sum = AnswerValue.reducedFraction(n1 + n2, d)
            let steps = buildSteps {
                $0.add("Same denominator, so add the numerators: \(n1) + \(n2) = \(n1 + n2).")
                $0.add("\(n1 + n2)/\(d) simplified is \(sum).")
            }
            return Question(templateID: "add.fraction.samedenom", topic: topic, level: level,
                             prompt: "\(n1)/\(d) + \(n2)/\(d)", spokenPrompt: "\(n1) over \(d) plus \(n2) over \(d)",
                             answer: sum, steps: steps)
        },
        QuestionTemplate(id: "mult.fraction.integer", topic: topic, levels: range) { level, rng in
            let d = niceDenoms[rInt(0...(niceDenoms.count - 1), &rng)]
            let mult = rInt(2...8, &rng)
            let k = d * mult
            let n = rInt(1...(d - 1), &rng)
            let answer = n * mult
            let steps = buildSteps {
                $0.add("\(n)/\(d) × \(k) = \(n) × (\(k) ÷ \(d)) = \(n) × \(mult).")
                $0.add("Answer: \(answer).")
            }
            return Question(templateID: "mult.fraction.integer", topic: topic, level: level,
                             prompt: "\(n)/\(d) × \(k)", spokenPrompt: "\(n) over \(d) times \(k)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "square.small", topic: topic, levels: range) { level, rng in
            let n = rInt(2...12, &rng)
            let steps = buildSteps { $0.add("\(n)² means \(n) × \(n).") ; $0.add("Answer: \(n * n).") }
            return Question(templateID: "square.small", topic: topic, level: level,
                             prompt: "\(n)²", spokenPrompt: "\(n) squared",
                             answer: .integer(n * n), steps: steps)
        },
        QuestionTemplate(id: "mult.by.10.100", topic: topic, levels: range) { level, rng in
            let a = rInt(2...99, &rng)
            let mult = [10, 100][rInt(0...1, &rng)]
            let steps = buildSteps { $0.add("Multiplying by \(mult) shifts the digits over.") ; $0.add("Answer: \(a * mult).") }
            return Question(templateID: "mult.by.10.100", topic: topic, level: level,
                             prompt: "\(a) × \(mult)", spokenPrompt: "\(a) times \(mult)",
                             answer: .integer(a * mult), steps: steps)
        },
        QuestionTemplate(id: "fraction.simplify", topic: topic, levels: range) { level, rng in
            let denomChoices = [2, 3, 4, 5]
            let rd = denomChoices[rInt(0...(denomChoices.count - 1), &rng)]
            let rn = rInt(1...(rd - 1), &rng)
            let k = rInt(2...6, &rng)
            let n = rn * k, d = rd * k
            let answer = AnswerValue.reducedFraction(rn, rd)
            let steps = buildSteps {
                $0.add("\(n) and \(d) share a common factor of \(k).")
                $0.add("\(n) ÷ \(k) = \(rn), \(d) ÷ \(k) = \(rd), giving \(answer).")
            }
            return Question(templateID: "fraction.simplify", topic: topic, level: level,
                             prompt: "Simplify \(n)/\(d)", spokenPrompt: "Simplify \(n) over \(d)",
                             answer: answer, steps: steps)
        },
    ]
}
