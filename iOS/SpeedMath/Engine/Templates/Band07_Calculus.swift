import Foundation

/// Grade 12. Levels 111...120. Limits, derivatives, tangent slopes.
enum Band07Calculus {
    static let range: ClosedRange<Int> = 111...120
    private static let topic = "Calculus"

    private static func signedTerm(_ coef: Int, _ variable: String) -> String {
        coef >= 0 ? " + \(coef)\(variable)" : " - \(abs(coef))\(variable)"
    }

    static let templates: [QuestionTemplate] = [
        QuestionTemplate(id: "limit.polynomial", topic: topic, levels: range) { level, rng in
            let a = rInt(1...5, &rng)
            let b = rInt(-9...9, &rng)
            let c = rInt(-10...10, &rng)
            let k = rInt(-6...6, &rng)
            let answer = a * k * k + b * k + c
            let expr = "\(a)x²\(signedTerm(b, "x"))\(signedTerm(c, ""))"
            let steps = buildSteps {
                $0.add("This polynomial is continuous, so the limit equals the value at x = \(k).")
                $0.add("\(a) × (\(k))² \(signedTerm(b, " × \(k)")) \(signedTerm(c, "")) = \(answer).")
            }
            return Question(templateID: "limit.polynomial", topic: topic, level: level,
                             prompt: "lim x→\(k) of \(expr)", spokenPrompt: "The limit as x approaches \(k) of \(expr)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "limit.removable", topic: topic, levels: range) { level, rng in
            let n = rInt(-10...10, &rng) == 0 ? 3 : rInt(-10...10, &rng)
            let answer = 2 * n
            let steps = buildSteps {
                $0.add("Factor: x² - \(n)² = (x - \(n))(x + \(n)).")
                $0.add("Cancel (x - \(n)): the expression becomes x + \(n). As x → \(n), this is \(n) + \(n) = \(answer).")
            }
            return Question(templateID: "limit.removable", topic: topic, level: level,
                             prompt: "lim x→\(n) of (x² - \(n * n))/(x - \(n))",
                             spokenPrompt: "The limit as x approaches \(n) of x squared minus \(n * n), over x minus \(n)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "derivative.power", topic: topic, levels: range) { level, rng in
            let degree = rInt(2...3, &rng)
            let a = rInt(1...6, &rng)
            let x0 = rInt(-5...5, &rng)
            let derivCoef = a * degree
            let x0Power = Int(pow(Double(x0), Double(degree - 1)))
            let answer = derivCoef * x0Power
            let steps = buildSteps {
                $0.add("The power rule: d/dx[\(a)x^\(degree)] = \(derivCoef)x^\(degree - 1).")
                $0.add("Evaluate at x = \(x0): \(derivCoef) × \(x0)^\(degree - 1) = \(answer).")
            }
            return Question(templateID: "derivative.power", topic: topic, level: level,
                             prompt: "d/dx[\(a)x^\(degree)] at x = \(x0)",
                             spokenPrompt: "The derivative of \(a) x to the \(degree), at x equals \(x0)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "tangent.slope.quadratic", topic: topic, levels: range) { level, rng in
            let a = rInt(1...5, &rng)
            let b = rInt(-8...8, &rng)
            let c = rInt(-10...10, &rng)
            let x0 = rInt(-6...6, &rng)
            let answer = 2 * a * x0 + b
            let expr = "\(a)x²\(signedTerm(b, "x"))\(signedTerm(c, ""))"
            let steps = buildSteps {
                $0.add("f'(x) = \(2 * a)x\(signedTerm(b, "")).")
                $0.add("Slope at x = \(x0): \(2 * a) × \(x0) \(signedTerm(b, "")) = \(answer).")
            }
            return Question(templateID: "tangent.slope.quadratic", topic: topic, level: level,
                             prompt: "Slope of f(x) = \(expr) at x = \(x0)",
                             spokenPrompt: "The slope of f of x equals \(expr), at x equals \(x0)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "product.rule.linear", topic: topic, levels: range) { level, rng in
            let a = rInt(-9...9, &rng)
            let b = rInt(-9...9, &rng)
            let x0 = rInt(-6...6, &rng)
            let answer = 2 * x0 + a + b
            let steps = buildSteps {
                $0.add("Product rule on (x + \(a))(x + \(b)): derivative = (x + \(b)) + (x + \(a)) = 2x + \(a + b).")
                $0.add("Evaluate at x = \(x0): 2 × \(x0) + \(a + b) = \(answer).")
            }
            return Question(templateID: "product.rule.linear", topic: topic, level: level,
                             prompt: "d/dx[(x + \(a))(x + \(b))] at x = \(x0)",
                             spokenPrompt: "The derivative of the product of x plus \(a) and x plus \(b), at x equals \(x0)",
                             answer: .integer(answer), steps: steps)
        },
    ]
}
