import Foundation

struct Question: Equatable {
    let templateID: String
    let topic: String
    let level: Int
    let prompt: String
    let spokenPrompt: String
    let answer: AnswerValue
    let steps: [String]

    static func == (lhs: Question, rhs: Question) -> Bool {
        lhs.templateID == rhs.templateID && lhs.prompt == rhs.prompt && lhs.answer == rhs.answer
    }
}

struct QuestionTemplate {
    let id: String
    let topic: String
    let levels: ClosedRange<Int>
    let make: (_ level: Int, _ rng: inout SeededRNG) -> Question
}

/// A tiny step-list builder so template bodies read as a sentence, not a
/// hand-built array literal with manual commas.
struct Steps {
    private(set) var lines: [String] = []

    mutating func add(_ line: String) {
        lines.append(line)
    }
}

func buildSteps(_ body: (inout Steps) -> Void) -> [String] {
    var steps = Steps()
    body(&steps)
    return steps.lines
}
