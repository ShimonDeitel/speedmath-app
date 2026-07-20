import Foundation

/// Grade 7-8. Levels 61...80. Linear equations, ratios, expression evaluation.
enum Band04PreAlgebra {
    static let range: ClosedRange<Int> = 61...80
    private static let topic = "Pre-Algebra"

    static let templates: [QuestionTemplate] = [
        QuestionTemplate(id: "linear.onestep.add", topic: topic, levels: range) { level, rng in
            let x = rInt(-20...20, &rng)
            let a = rInt(1...30, &rng)
            let c = x + a
            let cDisplay = c < 0 ? "(\(c))" : "\(c)"
            let steps = buildSteps {
                $0.add("Subtract \(a) from both sides: x = \(c) - \(a).")
                $0.add("Answer: x = \(x).")
            }
            return Question(templateID: "linear.onestep.add", topic: topic, level: level,
                             prompt: "x + \(a) = \(cDisplay), x = ?", spokenPrompt: "x plus \(a) equals \(c), what is x?",
                             answer: .integer(x), steps: steps)
        },
        QuestionTemplate(id: "linear.onestep.mult", topic: topic, levels: range) { level, rng in
            let a = rInt(2...12, &rng)
            let x = rInt(-15...15, &rng) == 0 ? 3 : rInt(-15...15, &rng)
            let c = a * x
            let steps = buildSteps {
                $0.add("Divide both sides by \(a): x = \(c) ÷ \(a).")
                $0.add("Answer: x = \(x).")
            }
            return Question(templateID: "linear.onestep.mult", topic: topic, level: level,
                             prompt: "\(a)x = \(c), x = ?", spokenPrompt: "\(a) x equals \(c), what is x?",
                             answer: .integer(x), steps: steps)
        },
        QuestionTemplate(id: "linear.twostep", topic: topic, levels: range) { level, rng in
            let a = rInt(2...9, &rng)
            let b = rInt(-20...20, &rng)
            let x = rInt(-12...12, &rng)
            let c = a * x + b
            let bDisplay = b < 0 ? "(\(b))" : "+ \(b)"
            let cDisplay = c < 0 ? "(\(c))" : "\(c)"
            let step1RHS = c - b
            let steps = buildSteps {
                $0.add("Undo the \(b >= 0 ? "addition" : "subtraction"): \(a)x = \(c) \(b >= 0 ? "-" : "+") \(abs(b)) = \(step1RHS).")
                $0.add("Divide by \(a): x = \(step1RHS) ÷ \(a) = \(x).")
            }
            return Question(templateID: "linear.twostep", topic: topic, level: level,
                             prompt: "\(a)x \(bDisplay) = \(cDisplay), x = ?",
                             spokenPrompt: "\(a) x \(b >= 0 ? "plus" : "minus") \(abs(b)) equals \(c), what is x?",
                             answer: .integer(x), steps: steps)
        },
        QuestionTemplate(id: "ratio.solve", topic: topic, levels: range) { level, rng in
            let a = rInt(1...12, &rng)
            let b = rInt(1...12, &rng)
            let m = rInt(2...9, &rng)
            let c = a * m
            let answer = b * m
            let steps = buildSteps {
                $0.add("\(a) scales up to \(c) by multiplying by \(m).")
                $0.add("Apply the same scale to \(b): \(b) × \(m) = \(answer).")
            }
            return Question(templateID: "ratio.solve", topic: topic, level: level,
                             prompt: "\(a):\(b) = \(c):?", spokenPrompt: "\(a) to \(b) equals \(c) to what?",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "evaluate.expr", topic: topic, levels: range) { level, rng in
            let a = rInt(2...9, &rng)
            let b = rInt(-15...15, &rng)
            let x = rInt(-10...10, &rng)
            let answer = a * x + b
            let bDisplay = b < 0 ? "- \(abs(b))" : "+ \(b)"
            let steps = buildSteps {
                $0.add("Substitute x = \(x): \(a) × \(x) \(bDisplay).")
                $0.add("\(a) × \(x) = \(a * x), then \(a * x) \(bDisplay) = \(answer).")
            }
            return Question(templateID: "evaluate.expr", topic: topic, level: level,
                             prompt: "\(a)x \(bDisplay), at x = \(x)", spokenPrompt: "\(a) x \(b < 0 ? "minus" : "plus") \(abs(b)), at x equals \(x)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "exponent.eval", topic: topic, levels: range) { level, rng in
            let base = rInt(2...6, &rng)
            let exp = rInt(2...4, &rng)
            let answer = Int(pow(Double(base), Double(exp)))
            let expansion = Array(repeating: "\(base)", count: exp).joined(separator: " × ")
            let steps = buildSteps {
                $0.add("\(base)^\(exp) means \(expansion).")
                $0.add("Answer: \(answer).")
            }
            return Question(templateID: "exponent.eval", topic: topic, level: level,
                             prompt: "\(base)^\(exp)", spokenPrompt: "\(base) to the power of \(exp)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "distribute.evaluate", topic: topic, levels: range) { level, rng in
            let a = rInt(2...9, &rng)
            let b = rInt(1...12, &rng)
            let x = rInt(-10...10, &rng)
            let answer = a * (x + b)
            let steps = buildSteps {
                $0.add("Distribute: \(a)(x + \(b)) = \(a)x + \(a * b).")
                $0.add("Substitute x = \(x): \(a * x) + \(a * b) = \(answer).")
            }
            return Question(templateID: "distribute.evaluate", topic: topic, level: level,
                             prompt: "\(a)(x + \(b)), at x = \(x)", spokenPrompt: "\(a) times, x plus \(b), at x equals \(x)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "proportion.solve", topic: topic, levels: range) { level, rng in
            let d1 = rInt(2...9, &rng)
            let k = rInt(2...6, &rng)
            let n1 = rInt(1...(d1 - 1), &rng)
            let d2 = d1 * k
            let answer = n1 * k
            let steps = buildSteps {
                $0.add("\(d1) scales up to \(d2) by multiplying by \(k).")
                $0.add("Do the same to the top: \(n1) × \(k) = \(answer).")
            }
            return Question(templateID: "proportion.solve", topic: topic, level: level,
                             prompt: "\(n1)/\(d1) = x/\(d2), x = ?", spokenPrompt: "\(n1) over \(d1) equals x over \(d2), what is x?",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "expo.zero.one", topic: topic, levels: range) { level, rng in
            let base = rInt(2...12, &rng)
            let useZero = Bool.random(using: &rng)
            let exp = useZero ? 0 : 1
            let answer = useZero ? 1 : base
            let steps = buildSteps {
                if useZero {
                    $0.add("Any nonzero number to the power of 0 is 1.")
                } else {
                    $0.add("Any number to the power of 1 is itself.")
                }
            }
            return Question(templateID: "expo.zero.one", topic: topic, level: level,
                             prompt: "\(base)^\(exp)", spokenPrompt: "\(base) to the power of \(exp)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "combine.like.terms", topic: topic, levels: range) { level, rng in
            let a = rInt(1...9, &rng), b = rInt(1...9, &rng)
            let x = rInt(-8...8, &rng)
            let combined = a + b
            let answer = combined * x
            let steps = buildSteps {
                $0.add("Combine like terms first: \(a)x + \(b)x = \(combined)x.")
                $0.add("Evaluate at x = \(x): \(combined) × \(x) = \(answer).")
            }
            return Question(templateID: "combine.like.terms", topic: topic, level: level,
                             prompt: "\(a)x + \(b)x, at x = \(x)", spokenPrompt: "\(a) x plus \(b) x, at x equals \(x)",
                             answer: .integer(answer), steps: steps)
        },
    ]
}
