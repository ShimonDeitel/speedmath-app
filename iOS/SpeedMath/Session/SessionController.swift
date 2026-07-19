import Foundation
import Observation

enum SessionPhase: Equatable {
    case asking
    case solved(correct: Bool, submitted: String)
}

/// Owns the round state machine: generate a question, accept an answer,
/// score it, advance. Persistence (level, stats) is delegated to the
/// `StatsStore` the caller passes into `submit`.
@Observable
@MainActor
final class SessionController {
    private(set) var question: Question
    private(set) var phase: SessionPhase = .asking
    private(set) var questionShownAt = Date()
    private(set) var roundsCompleted = 0

    private var rng: SeededRNG
    private var progression: LevelProgression
    private var recentTemplateIDs: [String] = []

    init(startingLevel: Int) {
        let isUITesting = CommandLine.arguments.contains("-uitest")
        var localRNG = isUITesting ? SeededRNG(seed: 42) : SeededRNG(seed: .random(in: .min ... .max))
        let clampedLevel = min(max(startingLevel, GradeMap.minLevel), GradeMap.maxLevel)
        let firstQuestion = QuestionEngine.next(level: clampedLevel, rng: &localRNG)

        progression = LevelProgression(level: clampedLevel)
        question = firstQuestion
        rng = localRNG
        recentTemplateIDs = [firstQuestion.templateID]
    }

    var currentLevel: Int { progression.level }

    /// Elapsed time since the current question appeared, measured from the
    /// moment the answer stopped changing (so Speed mode's silence window
    /// doesn't get counted as "thinking time").
    func elapsed(answeredAt: Date = Date()) -> TimeInterval {
        answeredAt.timeIntervalSince(questionShownAt)
    }

    @discardableResult
    func submit(_ value: AnswerValue?, displayText: String, stats: StatsStore, answeredAt: Date = Date()) -> Bool {
        guard case .asking = phase else { return false }
        let correct = value.map { question.answer.matches($0) } ?? false
        let time = elapsed(answeredAt: answeredAt)
        progression.recordAnswer(correct: correct, elapsed: time)
        stats.recordAnswer(correct: correct, elapsed: time, level: progression.level)
        phase = .solved(correct: correct, submitted: displayText)
        return correct
    }

    func advance() {
        roundsCompleted += 1
        question = QuestionEngine.next(level: progression.level, rng: &rng, recentTemplateIDs: recentTemplateIDs)
        recentTemplateIDs.append(question.templateID)
        if recentTemplateIDs.count > 5 { recentTemplateIDs.removeFirst() }
        questionShownAt = Date()
        phase = .asking
    }
}
