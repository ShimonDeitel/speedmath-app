import Foundation

/// Advanced. Levels 131...140. Complex numbers, eigenvalues, linear
/// approximation, combinatorics.
enum Band09Advanced {
    static let range: ClosedRange<Int> = 131...140
    private static let topic = "Advanced"

    private static func factorial(_ n: Int) -> Int {
        n <= 1 ? 1 : n * factorial(n - 1)
    }

    static let templates: [QuestionTemplate] = [
        QuestionTemplate(id: "complex.multiply.real", topic: topic, levels: range) { level, rng in
            let a = rInt(-9...9, &rng), b = rInt(-9...9, &rng)
            let c = rInt(-9...9, &rng), d = rInt(-9...9, &rng)
            let answer = a * c - b * d
            let steps = buildSteps {
                $0.add("The real part of (a+bi)(c+di) is ac − bd.")
                $0.add("\(a) × \(c) − \(b) × \(d) = \(a * c) − \(b * d) = \(answer).")
            }
            return Question(templateID: "complex.multiply.real", topic: topic, level: level,
                             prompt: "Real part of (\(a) + \(b)i)(\(c) + \(d)i)",
                             spokenPrompt: "The real part of \(a) plus \(b) i, times \(c) plus \(d) i",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "complex.multiply.imag", topic: topic, levels: range) { level, rng in
            let a = rInt(-9...9, &rng), b = rInt(-9...9, &rng)
            let c = rInt(-9...9, &rng), d = rInt(-9...9, &rng)
            let answer = a * d + b * c
            let steps = buildSteps {
                $0.add("The imaginary part of (a+bi)(c+di) is ad + bc.")
                $0.add("\(a) × \(d) + \(b) × \(c) = \(a * d) + \(b * c) = \(answer).")
            }
            return Question(templateID: "complex.multiply.imag", topic: topic, level: level,
                             prompt: "Imaginary part of (\(a) + \(b)i)(\(c) + \(d)i)",
                             spokenPrompt: "The imaginary part of \(a) plus \(b) i, times \(c) plus \(d) i",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "complex.magnitude.squared", topic: topic, levels: range) { level, rng in
            let a = rInt(-12...12, &rng), b = rInt(-12...12, &rng)
            let answer = a * a + b * b
            let steps = buildSteps {
                $0.add("|a + bi|² = a² + b² = \(a)² + \(b)².")
                $0.add("= \(a * a) + \(b * b) = \(answer).")
            }
            return Question(templateID: "complex.magnitude.squared", topic: topic, level: level,
                             prompt: "|\(a) + \(b)i|²", spokenPrompt: "The squared magnitude of \(a) plus \(b) i",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "eigenvalue.2x2.general", topic: topic, levels: range) { level, rng in
            var lambda1 = rInt(-6...6, &rng)
            var lambda2 = rInt(-6...6, &rng)
            if lambda1 == lambda2 { lambda2 += 1 }
            let a = rInt(-8...8, &rng)
            let d = (lambda1 + lambda2) - a
            let det = lambda1 * lambda2
            let b = a * d - det
            let trace = a + d
            let larger = max(lambda1, lambda2)
            let steps = buildSteps {
                $0.add("trace = a + d = \(a) + \(d) = \(trace); det = ad − bc = \(a * d) − \(b) = \(det).")
                $0.add("Eigenvalues solve λ² − \(trace)λ + \(det) = 0, giving λ = \(lambda1) and λ = \(lambda2).")
            }
            return Question(templateID: "eigenvalue.2x2.general", topic: topic, level: level,
                             prompt: "Larger eigenvalue of [[\(a),\(b)],[1,\(d)]]",
                             spokenPrompt: "The larger eigenvalue of the matrix with rows \(a), \(b) and 1, \(d)",
                             answer: .integer(larger), steps: steps)
        },
        QuestionTemplate(id: "taylor.linear.approx", topic: topic, levels: range) { level, rng in
            let a = rInt(-8...8, &rng)
            let x = rInt(-8...8, &rng)
            let answer = a * a + 2 * a * (x - a)
            let steps = buildSteps {
                $0.add("Linear approximation of f(x) = x² at a: f(a) + f'(a)(x − a) = \(a)² + \(2 * a)(x − \(a)).")
                $0.add("At x = \(x): \(a * a) + \(2 * a) × \(x - a) = \(answer).")
            }
            return Question(templateID: "taylor.linear.approx", topic: topic, level: level,
                             prompt: "Linear approx. of x² at a=\(a), evaluated at x=\(x)",
                             spokenPrompt: "The linear approximation of x squared at a equals \(a), evaluated at x equals \(x)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "binomial.coefficient", topic: topic, levels: range) { level, rng in
            let n = rInt(4...10, &rng)
            let k = rInt(1...(n - 1), &rng)
            let answer = factorial(n) / (factorial(k) * factorial(n - k))
            let steps = buildSteps {
                $0.add("C(n,k) = n! ÷ (k!(n-k)!) = \(n)! ÷ (\(k)! × \(n - k)!).")
                $0.add("Answer: \(answer).")
            }
            return Question(templateID: "binomial.coefficient", topic: topic, level: level,
                             prompt: "C(\(n), \(k))", spokenPrompt: "\(n) choose \(k)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "permutations", topic: topic, levels: range) { level, rng in
            let n = rInt(3...8, &rng)
            let k = rInt(1...n, &rng)
            let answer = factorial(n) / factorial(n - k)
            let steps = buildSteps {
                $0.add("P(n,k) = n! ÷ (n-k)! = \(n)! ÷ \(n - k)!.")
                $0.add("Answer: \(answer).")
            }
            return Question(templateID: "permutations", topic: topic, level: level,
                             prompt: "P(\(n), \(k))", spokenPrompt: "\(n) permute \(k)",
                             answer: .integer(answer), steps: steps)
        },
    ]
}
