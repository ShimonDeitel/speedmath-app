import Foundation

/// Grade 1-2. Levels 1...20. Counting, addition and subtraction within 100.
enum Band01Counting {
    static let range: ClosedRange<Int> = 1...20
    private static let topic = "Counting & Addition"

    static let templates: [QuestionTemplate] = [
        QuestionTemplate(id: "count.next", topic: topic, levels: range) { level, rng in
            let cap = 20 + bandProgress(level, bandStart: 1) * 10
            let n = rInt(1...cap, &rng)
            let steps = buildSteps { $0.add("Count one more than \(n).") ; $0.add("Answer: \(n + 1).") }
            return Question(templateID: "count.next", topic: topic, level: level,
                             prompt: "What comes after \(n)?", spokenPrompt: "What comes after \(n)?",
                             answer: .integer(n + 1), steps: steps)
        },
        QuestionTemplate(id: "count.before", topic: topic, levels: range) { level, rng in
            let cap = 20 + bandProgress(level, bandStart: 1) * 10
            let n = rInt(2...(cap + 1), &rng)
            let steps = buildSteps { $0.add("Count one less than \(n).") ; $0.add("Answer: \(n - 1).") }
            return Question(templateID: "count.before", topic: topic, level: level,
                             prompt: "What comes before \(n)?", spokenPrompt: "What comes before \(n)?",
                             answer: .integer(n - 1), steps: steps)
        },
        QuestionTemplate(id: "add.within20", topic: topic, levels: range) { level, rng in
            let a = rInt(1...19, &rng)
            let b = rInt(0...(20 - a), &rng)
            let steps = buildSteps { $0.add("Add \(a) and \(b).") ; $0.add("Answer: \(a + b).") }
            return Question(templateID: "add.within20", topic: topic, level: level,
                             prompt: "\(a) + \(b)", spokenPrompt: "\(a) plus \(b)",
                             answer: .integer(a + b), steps: steps)
        },
        QuestionTemplate(id: "sub.within20", topic: topic, levels: range) { level, rng in
            let a = rInt(1...20, &rng)
            let b = rInt(0...a, &rng)
            let steps = buildSteps { $0.add("Subtract \(b) from \(a).") ; $0.add("Answer: \(a - b).") }
            return Question(templateID: "sub.within20", topic: topic, level: level,
                             prompt: "\(a) - \(b)", spokenPrompt: "\(a) minus \(b)",
                             answer: .integer(a - b), steps: steps)
        },
        QuestionTemplate(id: "add.2digit.nocarry", topic: topic, levels: range) { level, rng in
            let t1 = rInt(1...8, &rng), o1 = rInt(0...9, &rng)
            let t2 = rInt(0...(9 - t1), &rng)
            let o2 = rInt(0...(9 - o1), &rng)
            let a = t1 * 10 + o1, b = t2 * 10 + o2
            let steps = buildSteps {
                $0.add("Add the ones: \(o1) + \(o2) = \(o1 + o2).")
                $0.add("Add the tens: \(t1) + \(t2) = \(t1 + t2).")
                $0.add("Answer: \(a + b).")
            }
            return Question(templateID: "add.2digit.nocarry", topic: topic, level: level,
                             prompt: "\(a) + \(b)", spokenPrompt: "\(a) plus \(b)",
                             answer: .integer(a + b), steps: steps)
        },
        QuestionTemplate(id: "add.2digit.carry", topic: topic, levels: range) { level, rng in
            let t1 = rInt(1...7, &rng), t2 = rInt(1...(8 - t1), &rng)
            let o1 = rInt(1...9, &rng)
            let o2 = rInt((10 - o1)...9, &rng)
            let a = t1 * 10 + o1, b = t2 * 10 + o2
            let onesSum = o1 + o2
            let steps = buildSteps {
                $0.add("Add the ones: \(o1) + \(o2) = \(onesSum). Write \(onesSum % 10), carry \(onesSum / 10).")
                $0.add("Add the tens: \(t1) + \(t2) + \(onesSum / 10) = \(t1 + t2 + onesSum / 10).")
                $0.add("Answer: \(a + b).")
            }
            return Question(templateID: "add.2digit.carry", topic: topic, level: level,
                             prompt: "\(a) + \(b)", spokenPrompt: "\(a) plus \(b)",
                             answer: .integer(a + b), steps: steps)
        },
        QuestionTemplate(id: "sub.2digit.noborrow", topic: topic, levels: range) { level, rng in
            let t1 = rInt(2...9, &rng), o1 = rInt(0...9, &rng)
            let t2 = rInt(0...(t1 - 1), &rng)
            let o2 = rInt(0...o1, &rng)
            let a = t1 * 10 + o1, b = t2 * 10 + o2
            let steps = buildSteps {
                $0.add("Subtract the ones: \(o1) - \(o2) = \(o1 - o2).")
                $0.add("Subtract the tens: \(t1) - \(t2) = \(t1 - t2).")
                $0.add("Answer: \(a - b).")
            }
            return Question(templateID: "sub.2digit.noborrow", topic: topic, level: level,
                             prompt: "\(a) - \(b)", spokenPrompt: "\(a) minus \(b)",
                             answer: .integer(a - b), steps: steps)
        },
        QuestionTemplate(id: "missing.addend", topic: topic, levels: range) { level, rng in
            let cap = 10 + bandProgress(level, bandStart: 1) * 5
            let b = rInt(1...cap, &rng)
            let answer = rInt(1...cap, &rng)
            let c = b + answer
            let steps = buildSteps {
                $0.add("You need a number that, added to \(b), makes \(c).")
                $0.add("\(c) - \(b) = \(answer).")
            }
            return Question(templateID: "missing.addend", topic: topic, level: level,
                             prompt: "? + \(b) = \(c)", spokenPrompt: "What number plus \(b) equals \(c)?",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "double", topic: topic, levels: range) { level, rng in
            let cap = 10 + bandProgress(level, bandStart: 1) * 8
            let n = rInt(1...cap, &rng)
            let steps = buildSteps { $0.add("Double \(n) means \(n) + \(n).") ; $0.add("Answer: \(n * 2).") }
            return Question(templateID: "double", topic: topic, level: level,
                             prompt: "Double \(n)", spokenPrompt: "What is double \(n)?",
                             answer: .integer(n * 2), steps: steps)
        },
        QuestionTemplate(id: "half", topic: topic, levels: range) { level, rng in
            let cap = 5 + bandProgress(level, bandStart: 1) * 5
            let half = rInt(1...cap, &rng)
            let n = half * 2
            let steps = buildSteps { $0.add("Half of \(n) means \(n) shared into 2 equal groups.") ; $0.add("Answer: \(half).") }
            return Question(templateID: "half", topic: topic, level: level,
                             prompt: "Half of \(n)", spokenPrompt: "What is half of \(n)?",
                             answer: .integer(half), steps: steps)
        },
        QuestionTemplate(id: "sequence.count.by", topic: topic, levels: range) { level, rng in
            let step = [2, 5, 10][rInt(0...2, &rng)]
            let start = rInt(0...20, &rng)
            let t1 = start + step, t2 = start + 2 * step, t3 = start + 3 * step
            let steps = buildSteps {
                $0.add("Each step adds \(step).")
                $0.add("\(t2) + \(step) = \(t3).")
            }
            return Question(templateID: "sequence.count.by", topic: topic, level: level,
                             prompt: "\(start), \(t1), \(t2), ?", spokenPrompt: "\(start), \(t1), \(t2), what comes next?",
                             answer: .integer(t3), steps: steps)
        },
        QuestionTemplate(id: "add.three", topic: topic, levels: range) { level, rng in
            let a = rInt(1...9, &rng), b = rInt(1...9, &rng), c = rInt(1...9, &rng)
            let steps = buildSteps {
                $0.add("Add the first two: \(a) + \(b) = \(a + b).")
                $0.add("Then add \(c): \(a + b) + \(c) = \(a + b + c).")
            }
            return Question(templateID: "add.three", topic: topic, level: level,
                             prompt: "\(a) + \(b) + \(c)", spokenPrompt: "\(a) plus \(b) plus \(c)",
                             answer: .integer(a + b + c), steps: steps)
        },
        QuestionTemplate(id: "compare.bigger", topic: topic, levels: range) { level, rng in
            let a = rInt(1...99, &rng)
            var b = rInt(1...99, &rng)
            if b == a { b += 1 }
            let bigger = max(a, b)
            let steps = buildSteps { $0.add("Compare \(a) and \(b).") ; $0.add("The bigger one is \(bigger).") }
            return Question(templateID: "compare.bigger", topic: topic, level: level,
                             prompt: "Bigger: \(a) or \(b)?", spokenPrompt: "Which is bigger, \(a) or \(b)?",
                             answer: .integer(bigger), steps: steps)
        },
    ]
}
