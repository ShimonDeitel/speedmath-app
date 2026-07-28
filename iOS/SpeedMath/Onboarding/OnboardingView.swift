import SwiftUI

/// First-launch flow: a couple of "how it works" screens, then an adaptive
/// placement quiz that picks a starting level. No sign-in, no age — the quiz
/// itself, question by question, is what places you.
struct OnboardingView: View {
    private enum Step: Equatable {
        case intro(Int)
        case quiz
    }

    @Environment(StatsStore.self) private var stats

    @State private var step: Step = .intro(0)

    // Adaptive placement state: each question steps the working level up or
    // down, with the step size halving every round — converges like a
    // binary search rather than scoring a fixed batch after the fact, so a
    // string of wrong answers immediately serves easier questions instead of
    // waiting until the whole quiz is graded.
    private static let quizQuestionCount = 8
    private static let startingLevel = 21 // neutral: Grade 3
    private static let startingStep = 24

    @State private var quizLevel = OnboardingView.startingLevel
    @State private var quizStep = OnboardingView.startingStep
    @State private var quizAnswered = 0
    @State private var quizRNG = SeededRNG(seed: .random(in: .min ... .max))
    @State private var quizRecentIDs: [String] = []
    @State private var currentQuestion: Question?
    @State private var quizAnswerText = ""

    private let introPages: [(icon: String, title: String, body: String)] = [
        ("bolt.fill", "Answer as fast as you can",
         "Type or say your answer out loud. SpeedMath times every round and moves you up through 1,500 levels — Grade 1 all the way to Expert."),
        ("target", "We start you at the right level",
         "A short adaptive quiz places you where you actually belong. Answer, and it gets harder. Miss one, and it gets easier — no wasted time either way."),
    ]

    var body: some View {
        ZStack {
            Color.smPaper.ignoresSafeArea()

            switch step {
            case .intro(let index):
                introPage(index)
                    .transition(.opacity)
            case .quiz:
                quizPage
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: step)
    }

    // MARK: - Intro

    private func introPage(_ index: Int) -> some View {
        let page = introPages[index]
        return VStack(spacing: SMSpacing.lg) {
            Spacer()
            StopwatchGlyph()
                .stroke(Color.smTangerine, style: StrokeStyle(lineWidth: 9, lineCap: .round, lineJoin: .round))
                .frame(width: 72, height: 72)
            Image(systemName: page.icon)
                .font(.smBody(30, weight: .semibold))
                .foregroundStyle(Color.smTangerine)
                .padding(.top, SMSpacing.sm)
            Text(page.title)
                .font(.smDisplay(26))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.smInk)
            Text(page.body)
                .font(.smBody(15))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.smInkMuted)
                .padding(.horizontal, SMSpacing.lg)
            Spacer()
            primaryButton("Continue") {
                if index + 1 < introPages.count {
                    step = .intro(index + 1)
                } else {
                    startQuiz()
                }
            }
            pageDots(current: index, count: introPages.count)
        }
        .padding(SMSpacing.md)
    }

    // MARK: - Placement quiz

    private var quizPage: some View {
        VStack(spacing: SMSpacing.lg) {
            VStack(spacing: SMSpacing.xs) {
                Text("Quick placement check")
                    .font(.smBody(13, weight: .semibold))
                    .foregroundStyle(Color.smInkMuted)
                quizProgressBar
            }
            .padding(.top, SMSpacing.md)

            Spacer(minLength: SMSpacing.md)

            if let currentQuestion {
                FlipDigitView(text: currentQuestion.prompt, fontSize: 40)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .accessibilityIdentifier("placementAnswerDisplay")
            }

            Spacer(minLength: SMSpacing.sm)

            VStack(spacing: SMSpacing.sm) {
                Text(quizAnswerText.isEmpty ? " " : quizAnswerText)
                    .font(.smDisplay(32))
                    .foregroundStyle(Color.smTangerine)
                    .frame(height: 40)
                KeypadView(text: $quizAnswerText) {
                    submitQuizAnswer(correct: currentQuestionCorrect())
                }
                Button {
                    submitQuizAnswer(correct: false)
                } label: {
                    Text("I don't know")
                        .font(.smBody(14, weight: .semibold))
                        .foregroundStyle(Color.smInkMuted)
                }
                .accessibilityIdentifier("placementIDontKnow")
                .padding(.top, 2)
            }
            .padding(.bottom, SMSpacing.md)
        }
        .padding(SMSpacing.md)
    }

    private var quizProgressBar: some View {
        HStack(spacing: 4) {
            ForEach(0..<Self.quizQuestionCount, id: \.self) { index in
                Capsule()
                    .fill(index < quizAnswered ? Color.smTangerine : Color.white.opacity(0.7))
                    .overlay(
                        Capsule().strokeBorder(Color.smInk.opacity(0.1), lineWidth: 1))
                    .frame(height: 8)
            }
        }
        .accessibilityIdentifier("placementProgressBar")
    }

    private func currentQuestionCorrect() -> Bool {
        guard let currentQuestion, let value = AnswerValue.parse(display: quizAnswerText) else { return false }
        return currentQuestion.answer.matches(value)
    }

    private func startQuiz() {
        quizLevel = Self.startingLevel
        quizStep = Self.startingStep
        quizAnswered = 0
        quizRecentIDs = []
        quizAnswerText = ""
        currentQuestion = nextQuizQuestion()
        step = .quiz
    }

    private func nextQuizQuestion() -> Question {
        let clamped = min(max(quizLevel, GradeMap.minLevel), GradeMap.maxLevel)
        let question = QuestionEngine.next(level: clamped, rng: &quizRNG, recentTemplateIDs: quizRecentIDs)
        quizRecentIDs.append(question.templateID)
        if quizRecentIDs.count > 3 { quizRecentIDs.removeFirst() }
        return question
    }

    private func submitQuizAnswer(correct: Bool) {
        guard currentQuestion != nil else { return }
        quizLevel += correct ? quizStep : -quizStep
        quizLevel = min(max(quizLevel, GradeMap.minLevel), GradeMap.maxLevel)
        quizStep = max(quizStep / 2, 3)
        quizAnswered += 1
        quizAnswerText = ""

        if quizAnswered >= Self.quizQuestionCount {
            let placement = GradeMap.bandStart(for: quizLevel)
            stats.completeOnboarding(placementLevel: placement)
            ReminderScheduler.requestAuthorizationIfNeeded()
        } else {
            currentQuestion = nextQuizQuestion()
        }
    }

    // MARK: - Shared pieces

    private func primaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(title).font(.smBody(17, weight: .bold))
                Spacer()
            }
            .padding(.vertical, 16)
            .background(Color.smTangerine, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .foregroundStyle(.white)
        }
        .buttonStyle(.smPressable)
        .accessibilityIdentifier("onboardingContinue")
    }

    private func pageDots(current: Int, count: Int) -> some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == current ? Color.smTangerine : Color.smInk.opacity(0.15))
                    .frame(width: 6, height: 6)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(StatsStore())
}
