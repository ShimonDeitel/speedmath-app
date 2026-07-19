import Foundation

/// University. Levels 121...130. Integrals, series, determinants, linear algebra.
enum Band08University {
    static let range: ClosedRange<Int> = 121...130
    private static let topic = "University"

    static let templates: [QuestionTemplate] = [
        QuestionTemplate(id: "integral.definite", topic: topic, levels: range) { level, rng in
            let a = rInt(1...6, &rng)
            let b = rInt(1...5, &rng)
            let numerator = a * b * b * b
            let answer = AnswerValue.reducedFraction(numerator, 3)
            let steps = buildSteps {
                $0.add("∫ \(a)x² dx = \(a)x³/3. Evaluate from 0 to \(b).")
                $0.add("\(a) × \(b)³ ÷ 3 = \(numerator)/3 = \(answer).")
            }
            return Question(templateID: "integral.definite", topic: topic, level: level,
                             prompt: "∫₀^\(b) \(a)x² dx", spokenPrompt: "The integral from 0 to \(b) of \(a) x squared, d x",
                             answer: answer, steps: steps)
        },
        QuestionTemplate(id: "series.geometric.infinite", topic: topic, levels: range) { level, rng in
            let n = rInt(2...6, &rng)
            let k = rInt(1...10, &rng)
            let a1 = k * (n - 1)
            let answer = k * n
            let steps = buildSteps {
                $0.add("Sum to infinity = a₁ ÷ (1 - r) = \(a1) ÷ (1 - 1/\(n)).")
                $0.add("1 - 1/\(n) = \(n - 1)/\(n), so the sum is \(a1) × \(n)/\(n - 1) = \(answer).")
            }
            return Question(templateID: "series.geometric.infinite", topic: topic, level: level,
                             prompt: "a₁ = \(a1), r = 1/\(n), sum to infinity?",
                             spokenPrompt: "First term \(a1), ratio one over \(n), what is the sum to infinity?",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "determinant.2x2", topic: topic, levels: range) { level, rng in
            let a = rInt(-9...9, &rng), b = rInt(-9...9, &rng)
            let c = rInt(-9...9, &rng), d = rInt(-9...9, &rng)
            let answer = a * d - b * c
            let steps = buildSteps {
                $0.add("det = ad - bc = (\(a) × \(d)) - (\(b) × \(c)).")
                $0.add("= \(a * d) - \(b * c) = \(answer).")
            }
            return Question(templateID: "determinant.2x2", topic: topic, level: level,
                             prompt: "det [[\(a),\(b)],[\(c),\(d)]]", spokenPrompt: "The determinant of the matrix, row one \(a) \(b), row two \(c) \(d)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "determinant.3x3", topic: topic, levels: range) { level, rng in
            let a = rInt(-4...4, &rng), b = rInt(-4...4, &rng), c = rInt(-4...4, &rng)
            let d = rInt(-4...4, &rng), e = rInt(-4...4, &rng), f = rInt(-4...4, &rng)
            let g = rInt(-4...4, &rng), h = rInt(-4...4, &rng), iVal = rInt(-4...4, &rng)
            let m1 = e * iVal - f * h
            let m2 = d * iVal - f * g
            let m3 = d * h - e * g
            let answer = a * m1 - b * m2 + c * m3
            let steps = buildSteps {
                $0.add("Expand along the top row: \(a)(\(e)×\(iVal) − \(f)×\(h)) − \(b)(\(d)×\(iVal) − \(f)×\(g)) + \(c)(\(d)×\(h) − \(e)×\(g)).")
                $0.add("= \(a) × \(m1) − \(b) × \(m2) + \(c) × \(m3) = \(answer).")
            }
            return Question(templateID: "determinant.3x3", topic: topic, level: level,
                             prompt: "det [[\(a),\(b),\(c)],[\(d),\(e),\(f)],[\(g),\(h),\(iVal)]]",
                             spokenPrompt: "The determinant of the three by three matrix",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "dot.product", topic: topic, levels: range) { level, rng in
            let a1 = rInt(-9...9, &rng), a2 = rInt(-9...9, &rng), a3 = rInt(-9...9, &rng)
            let b1 = rInt(-9...9, &rng), b2 = rInt(-9...9, &rng), b3 = rInt(-9...9, &rng)
            let answer = a1 * b1 + a2 * b2 + a3 * b3
            let steps = buildSteps {
                $0.add("Multiply matching components and add: (\(a1)×\(b1)) + (\(a2)×\(b2)) + (\(a3)×\(b3)).")
                $0.add("= \(a1 * b1) + \(a2 * b2) + \(a3 * b3) = \(answer).")
            }
            return Question(templateID: "dot.product", topic: topic, level: level,
                             prompt: "(\(a1),\(a2),\(a3)) · (\(b1),\(b2),\(b3))",
                             spokenPrompt: "The dot product of vector \(a1) \(a2) \(a3), and vector \(b1) \(b2) \(b3)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "matrix.trace", topic: topic, levels: range) { level, rng in
            let a = rInt(-15...15, &rng), e = rInt(-15...15, &rng), iVal = rInt(-15...15, &rng)
            let b = rInt(-9...9, &rng), c = rInt(-9...9, &rng), f = rInt(-9...9, &rng)
            let answer = a + e + iVal
            let steps = buildSteps {
                $0.add("The trace is the sum of the diagonal entries: \(a) + \(e) + \(iVal).")
                $0.add("Answer: \(answer).")
            }
            return Question(templateID: "matrix.trace", topic: topic, level: level,
                             prompt: "trace [[\(a),\(b),\(c)],[·,\(e),\(f)],[·,·,\(iVal)]]",
                             spokenPrompt: "The trace of a three by three matrix with diagonal \(a), \(e), \(iVal)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "eigenvalue.triangular", topic: topic, levels: range) { level, rng in
            let a = rInt(-10...10, &rng)
            var d = rInt(-10...10, &rng)
            if a == d { d += 1 }
            let b = rInt(-9...9, &rng)
            let answer = max(a, d)
            let steps = buildSteps {
                $0.add("For an upper-triangular matrix, the eigenvalues are exactly the diagonal entries: \(a) and \(d).")
                $0.add("The larger one is \(answer).")
            }
            return Question(templateID: "eigenvalue.triangular", topic: topic, level: level,
                             prompt: "Larger eigenvalue of [[\(a),\(b)],[0,\(d)]]",
                             spokenPrompt: "The larger eigenvalue of the upper triangular matrix with diagonal \(a) and \(d)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "partial.derivative", topic: topic, levels: range) { level, rng in
            let a = rInt(1...6, &rng)
            let x0 = rInt(-6...6, &rng)
            let y0 = rInt(-6...6, &rng)
            let answer = 2 * a * x0 * y0
            let steps = buildSteps {
                $0.add("∂f/∂x of \(a)x²y treats y as a constant: ∂f/∂x = \(2 * a)xy.")
                $0.add("Evaluate at (\(x0), \(y0)): \(2 * a) × \(x0) × \(y0) = \(answer).")
            }
            return Question(templateID: "partial.derivative", topic: topic, level: level,
                             prompt: "∂/∂x [\(a)x²y] at (\(x0), \(y0))",
                             spokenPrompt: "The partial derivative with respect to x of \(a) x squared y, at x equals \(x0), y equals \(y0)",
                             answer: .integer(answer), steps: steps)
        },
    ]
}
