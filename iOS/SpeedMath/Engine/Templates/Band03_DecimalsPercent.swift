import Foundation

/// Grade 5-6. Levels 41...60. Decimals, percents, negatives, order of operations.
enum Band03DecimalsPercent {
    static let range: ClosedRange<Int> = 41...60
    private static let topic = "Decimals & Percents"

    static let templates: [QuestionTemplate] = [
        QuestionTemplate(id: "decimal.add", topic: topic, levels: range) { level, rng in
            let x = rInt(10...200, &rng), y = rInt(10...200, &rng)
            let a = Double(x) / 10.0, b = Double(y) / 10.0
            let sumTenths = x + y
            let steps = buildSteps {
                $0.add("Line up the decimal points and add: \(x) + \(y) tenths = \(sumTenths) tenths.")
                $0.add("Answer: \(AnswerValue.decimal(Double(sumTenths) / 10.0)).")
            }
            return Question(templateID: "decimal.add", topic: topic, level: level,
                             prompt: "\(AnswerValue.decimal(a)) + \(AnswerValue.decimal(b))",
                             spokenPrompt: "\(AnswerValue.decimal(a)) plus \(AnswerValue.decimal(b))",
                             answer: .decimal(Double(sumTenths) / 10.0), steps: steps)
        },
        QuestionTemplate(id: "decimal.sub", topic: topic, levels: range) { level, rng in
            let x = rInt(20...300, &rng)
            let y = rInt(10...(x - 1), &rng)
            let a = Double(x) / 10.0, b = Double(y) / 10.0
            let diffTenths = x - y
            let steps = buildSteps {
                $0.add("Line up the decimal points and subtract: \(x) - \(y) tenths = \(diffTenths) tenths.")
                $0.add("Answer: \(AnswerValue.decimal(Double(diffTenths) / 10.0)).")
            }
            return Question(templateID: "decimal.sub", topic: topic, level: level,
                             prompt: "\(AnswerValue.decimal(a)) - \(AnswerValue.decimal(b))",
                             spokenPrompt: "\(AnswerValue.decimal(a)) minus \(AnswerValue.decimal(b))",
                             answer: .decimal(Double(diffTenths) / 10.0), steps: steps)
        },
        QuestionTemplate(id: "decimal.mult.int", topic: topic, levels: range) { level, rng in
            let x = rInt(11...99, &rng)
            let m = rInt(2...9, &rng)
            let a = Double(x) / 10.0
            let productTenths = x * m
            let steps = buildSteps {
                $0.add("Multiply as whole numbers: \(x) × \(m) = \(productTenths).")
                $0.add("Put the decimal point back one place: \(AnswerValue.decimal(Double(productTenths) / 10.0)).")
            }
            return Question(templateID: "decimal.mult.int", topic: topic, level: level,
                             prompt: "\(AnswerValue.decimal(a)) × \(m)", spokenPrompt: "\(AnswerValue.decimal(a)) times \(m)",
                             answer: .decimal(Double(productTenths) / 10.0), steps: steps)
        },
        QuestionTemplate(id: "percent.of", topic: topic, levels: range) { level, rng in
            let pctSteps10 = rInt(1...19, &rng)
            let pct = pctSteps10 * 5
            let base = rInt(2...40, &rng) * 20
            let answer = base * pct / 100
            let steps = buildSteps {
                $0.add("\(pct)% means \(pct)/100.")
                $0.add("\(base) × \(pct) ÷ 100 = \(answer).")
            }
            return Question(templateID: "percent.of", topic: topic, level: level,
                             prompt: "\(pct)% of \(base)", spokenPrompt: "What is \(pct) percent of \(base)?",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "negative.addsub", topic: topic, levels: range) { level, rng in
            let a = rInt(-30...30, &rng)
            let b = rInt(-30...30, &rng)
            let useAdd = Bool.random(using: &rng)
            let answer = useAdd ? a + b : a - b
            let opSymbol = useAdd ? "+" : "-"
            let bDisplay = b < 0 ? "(\(b))" : "\(b)"
            let steps = buildSteps {
                if useAdd {
                    $0.add("Adding a negative moves left on the number line.")
                } else {
                    $0.add("Subtracting a negative moves right on the number line.")
                }
                $0.add("Answer: \(answer).")
            }
            return Question(templateID: "negative.addsub", topic: topic, level: level,
                             prompt: "\(a) \(opSymbol) \(bDisplay)", spokenPrompt: "\(a) \(useAdd ? "plus" : "minus") \(b)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "negative.mult", topic: topic, levels: range) { level, rng in
            let a = rInt(-12...12, &rng) == 0 ? 3 : rInt(-12...12, &rng)
            let b = rInt(-12...12, &rng) == 0 ? 4 : rInt(-12...12, &rng)
            let answer = a * b
            let steps = buildSteps {
                $0.add("Same signs give a positive product; different signs give a negative product.")
                $0.add("\(a) × \(b) = \(answer).")
            }
            return Question(templateID: "negative.mult", topic: topic, level: level,
                             prompt: "\(a) × \(b)", spokenPrompt: "\(a) times \(b)",
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "order.ops", topic: topic, levels: range) { level, rng in
            let a = rInt(2...20, &rng)
            let b = rInt(2...9, &rng)
            let c = rInt(2...9, &rng)
            let addFirst = Bool.random(using: &rng)
            let product = b * c
            let answer = addFirst ? a + product : product - a
            let prompt = addFirst ? "\(a) + \(b) × \(c)" : "\(b) × \(c) - \(a)"
            let steps = buildSteps {
                $0.add("Multiply first: \(b) × \(c) = \(product).")
                $0.add(addFirst ? "Then add: \(a) + \(product) = \(answer)." : "Then subtract: \(product) - \(a) = \(answer).")
            }
            return Question(templateID: "order.ops", topic: topic, level: level,
                             prompt: prompt, spokenPrompt: prompt,
                             answer: .integer(answer), steps: steps)
        },
        QuestionTemplate(id: "unit.rate", topic: topic, levels: range) { level, rng in
            let rate = rInt(2...20, &rng)
            let count = rInt(2...12, &rng)
            let total = rate * count
            let steps = buildSteps {
                $0.add("Divide the total by the count to find the rate for one: \(total) ÷ \(count).")
                $0.add("Answer: \(rate).")
            }
            return Question(templateID: "unit.rate", topic: topic, level: level,
                             prompt: "\(total) for \(count) — price per one?", spokenPrompt: "\(total) split \(count) ways, how much is one share?",
                             answer: .integer(rate), steps: steps)
        },
    ]
}
