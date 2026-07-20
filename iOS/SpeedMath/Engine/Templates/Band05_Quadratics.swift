import Foundation

/// Grade 9-10. Levels 81...100. Quadratics, systems, exponent laws, logs, radicals.
enum Band05Quadratics {
    static let range: ClosedRange<Int> = 81...100
    private static let topic = "Algebra II"
    private static let subscriptDigits: [Character: Character] = [
        "0": "\u{2080}", "1": "\u{2081}", "2": "\u{2082}", "3": "\u{2083}", "4": "\u{2084}",
        "5": "\u{2085}", "6": "\u{2086}", "7": "\u{2087}", "8": "\u{2088}", "9": "\u{2089}",
    ]

    private static func subscript_(_ n: Int) -> String {
        String("\(n)".compactMap { subscriptDigits[$0] })
    }

    private static func pickDistinctRoots(_ rng: inout SeededRNG) -> (Int, Int) {
        var r1 = rInt(-10...10, &rng)
        var r2 = rInt(-10...10, &rng)
        if r1 == r2 { r2 += 1 }
        if r1 > r2 { swap(&r1, &r2) }
        return (r1, r2)
    }

    private static func quadraticPrompt(_ b: Int, _ c: Int) -> String {
        let bTerm = b == 0 ? "" : (b > 0 ? " + \(b)x" : " - \(abs(b))x")
        let cTerm = c == 0 ? "" : (c > 0 ? " + \(c)" : " - \(abs(c))")
        return "x²\(bTerm)\(cTerm) = 0"
    }

    static let templates: [QuestionTemplate] = [
        QuestionTemplate(id: "quadratic.roots.smaller", topic: topic, levels: range) { level, rng in
            let (r1, r2) = pickDistinctRoots(&rng)
            let b = -(r1 + r2), c = r1 * r2
            let eq = quadraticPrompt(b, c)
            let steps = buildSteps {
                $0.add("Factor as (x - \(r1))(x - \(r2)) = 0.")
                $0.add("The roots are \(r1) and \(r2); the smaller is \(r1).")
            }
            return Question(templateID: "quadratic.roots.smaller", topic: topic, level: level,
                             prompt: "\(eq), smaller root?", spokenPrompt: "\(eq), what is the smaller root?",
                             answer: .integer(r1), steps: steps)
        },
        QuestionTemplate(id: "quadratic.roots.larger", topic: topic, levels: range) { level, rng in
            let (r1, r2) = pickDistinctRoots(&rng)
            let b = -(r1 + r2), c = r1 * r2
            let eq = quadraticPrompt(b, c)
            let steps = buildSteps {
                $0.add("Factor as (x - \(r1))(x - \(r2)) = 0.")
                $0.add("The roots are \(r1) and \(r2); the larger is \(r2).")
            }
            return Question(templateID: "quadratic.roots.larger", topic: topic, level: level,
                             prompt: "\(eq), larger root?", spokenPrompt: "\(eq), what is the larger root?",
                             answer: .integer(r2), steps: steps)
        },
        QuestionTemplate(id: "system.2x2", topic: topic, levels: range) { level, rng in
            let a = rInt(2...6, &rng)
            let x = rInt(-10...10, &rng)
            let y = rInt(-10...10, &rng)
            let c1 = a * x + y
            let c2 = x - y
            let steps = buildSteps {
                $0.add("Add the two equations to eliminate y: (\(a)x + y) + (x - y) = \(c1) + \(c2).")
                $0.add("(\(a) + 1)x = \(c1 + c2), so x = \(c1 + c2) ÷ \(a + 1) = \(x).")
            }
            return Question(templateID: "system.2x2", topic: topic, level: level,
                             prompt: "\(a)x + y = \(c1), x - y = \(c2), x = ?",
                             spokenPrompt: "\(a) x plus y equals \(c1), x minus y equals \(c2), what is x?",
                             answer: .integer(x), steps: steps)
        },
        QuestionTemplate(id: "exponent.laws", topic: topic, levels: range) { level, rng in
            let base = rInt(2...6, &rng)
            let e1 = rInt(1...6, &rng)
            let e2 = rInt(1...6, &rng)
            let answer = e1 + e2
            let steps = buildSteps {
                $0.add("Multiplying powers with the same base adds the exponents.")
                $0.add("\(e1) + \(e2) = \(answer).")
            }
            return Question(templateID: "exponent.laws", topic: topic, level: level,
                             prompt: "\(base)^\(e1) · \(base)^\(e2) = \(base)^?",
                             spokenPrompt: "\(base) to the \(e1), times \(base) to the \(e2), equals \(base) to the what?",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "log.nice", topic: topic, levels: range) { level, rng in
            let base = [2, 3, 5][rInt(0...2, &rng)]
            let e = rInt(1...5, &rng)
            let value = Int(pow(Double(base), Double(e)))
            let steps = buildSteps {
                $0.add("log\(subscript_(base))(\(value)) asks: \(base) to what power gives \(value)?")
                $0.add("\(base)^\(e) = \(value), so the answer is \(e).")
            }
            return Question(templateID: "log.nice", topic: topic, level: level,
                             prompt: "log\(subscript_(base))(\(value))", spokenPrompt: "log base \(base) of \(value)",
                             answer: .integer(e), steps: steps)
        },
        QuestionTemplate(id: "radical.simplify", topic: topic, levels: range) { level, rng in
            let n = rInt(2...20, &rng)
            let value = n * n
            let steps = buildSteps {
                $0.add("\(value) is a perfect square: \(n) × \(n) = \(value).")
                $0.add("√\(value) = \(n).")
            }
            return Question(templateID: "radical.simplify", topic: topic, level: level,
                             prompt: "√\(value)", spokenPrompt: "The square root of \(value)",
                             answer: .integer(n), steps: steps)
        },
        QuestionTemplate(id: "function.eval.quadratic", topic: topic, levels: range) { level, rng in
            let a = rInt(1...5, &rng)
            let b = rInt(-8...8, &rng)
            let c = rInt(-10...10, &rng)
            let x = rInt(-6...6, &rng)
            let answer = a * x * x + b * x + c
            let bTerm = b == 0 ? "" : (b > 0 ? " + \(b)x" : " - \(abs(b))x")
            let cTerm = c == 0 ? "" : (c > 0 ? " + \(c)" : " - \(abs(c))")
            let steps = buildSteps {
                $0.add("Substitute x = \(x): \(a)(\(x))²\(bTerm.replacingOccurrences(of: "x", with: "(\(x))"))\(cTerm).")
                $0.add("\(a) × \(x * x) = \(a * x * x); then add \(b) × \(x) = \(b * x); then add \(c).")
                $0.add("Answer: \(answer).")
            }
            return Question(templateID: "function.eval.quadratic", topic: topic, level: level,
                             prompt: "f(x) = \(a)x²\(bTerm)\(cTerm), f(\(x)) = ?",
                             spokenPrompt: "f of x equals \(a) x squared\(bTerm)\(cTerm), what is f of \(x)?",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "vertex.x", topic: topic, levels: range) { level, rng in
            let vertexX = rInt(-10...10, &rng)
            let b = -2 * vertexX
            let c = rInt(-10...10, &rng)
            let bTerm = b == 0 ? "" : (b > 0 ? " + \(b)x" : " - \(abs(b))x")
            let cTerm = c == 0 ? "" : (c > 0 ? " + \(c)" : " - \(abs(c))")
            let steps = buildSteps {
                $0.add("For x² + bx + c, the vertex is at x = -b/2.")
                $0.add("x = -(\(b)) ÷ 2 = \(vertexX).")
            }
            return Question(templateID: "vertex.x", topic: topic, level: level,
                             prompt: "Vertex x-coordinate of x²\(bTerm)\(cTerm)",
                             spokenPrompt: "The vertex x coordinate of x squared\(bTerm)\(cTerm)",
                             answer: .integer(vertexX), steps: steps)
        },
        QuestionTemplate(id: "discriminant", topic: topic, levels: range) { level, rng in
            let a = rInt(1...4, &rng)
            let b = rInt(-9...9, &rng)
            let c = rInt(-9...9, &rng)
            let answer = b * b - 4 * a * c
            let bTerm = b >= 0 ? "+ \(b)x" : "- \(abs(b))x"
            let cTerm = c >= 0 ? "+ \(c)" : "- \(abs(c))"
            let steps = buildSteps {
                $0.add("Discriminant = b² - 4ac = (\(b))² - 4(\(a))(\(c)).")
                $0.add("= \(b * b) - \(4 * a * c) = \(answer).")
            }
            return Question(templateID: "discriminant", topic: topic, level: level,
                             prompt: "Discriminant of \(a)x² \(bTerm) \(cTerm)",
                             spokenPrompt: "The discriminant of \(a) x squared \(bTerm) \(cTerm)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "abs.value.eq", topic: topic, levels: range) { level, rng in
            let c = rInt(-10...10, &rng)
            let k = rInt(1...10, &rng)
            let larger = c + k
            let smaller = c - k
            let steps = buildSteps {
                $0.add("x - \(c) = \(k) or x - \(c) = -\(k).")
                $0.add("That gives x = \(larger) or x = \(smaller); the larger is \(larger).")
            }
            return Question(templateID: "abs.value.eq", topic: topic, level: level,
                             prompt: "|x - \(c)| = \(k), larger solution?",
                             spokenPrompt: "The absolute value of x minus \(c) equals \(k), what is the larger solution?",
                             answer: .integer(larger), steps: steps)
        },
    ]
}
