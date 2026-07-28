import SwiftUI

struct SolutionView: View {
    let question: Question
    let correct: Bool
    let submittedText: String
    var onNext: () -> Void

    @Environment(StatsStore.self) private var stats
    @Environment(ProStore.self) private var proStore
    @State private var iconPop = false
    @State private var revealedSteps = 0
    @State private var showTutorChat = false
    @State private var showPaywall = false

    var body: some View {
        VStack(spacing: SMSpacing.md) {
            HStack(spacing: SMSpacing.sm) {
                Image(systemName: correct ? SMIcon.correct : SMIcon.wrong)
                    .font(.smBody(28, weight: .bold))
                    .foregroundStyle(correct ? Color.smCorrect : Color.smWrong)
                    .scaleEffect(iconPop ? 1 : 0.4)
                    .opacity(iconPop ? 1 : 0)
                    .accessibilityIdentifier(correct ? "verdictCorrect" : "verdictWrong")
                VStack(alignment: .leading, spacing: 2) {
                    Text(correct ? "Correct" : "Not quite")
                        .font(.smDisplay(20))
                        .foregroundStyle(Color.smInk)
                    if !correct {
                        Text("You answered \(submittedText.isEmpty ? "nothing" : submittedText); the answer is \(question.answer.description).")
                            .font(.smBody(13))
                            .foregroundStyle(Color.smInkMuted)
                    }
                }
                Spacer()
            }
            .padding(SMSpacing.md)
            .smCard(color: (correct ? Color.smCorrect : Color.smWrong).opacity(0.12))

            ScrollView {
                VStack(alignment: .leading, spacing: SMSpacing.sm) {
                    Text("How to solve it")
                        .font(.smBody(13, weight: .bold))
                        .foregroundStyle(Color.smInkMuted)
                    ForEach(Array(question.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: SMSpacing.sm) {
                            Text("\(index + 1)")
                                .font(.smBody(12, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                                .background(Color.smTangerine, in: Circle())
                            Text(step)
                                .font(.smBody(14))
                                .foregroundStyle(Color.smInk)
                        }
                        .opacity(index < revealedSteps ? 1 : 0)
                        .offset(x: index < revealedSteps ? 0 : -14)
                    }
                }
                .accessibilityIdentifier("solutionSteps")
                .padding(SMSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .smCard()

                if !correct {
                    tutorPrompt
                }
            }

            StreakMeterView(streak: stats.snapshot.currentStreak)

            Button(action: onNext) {
                HStack {
                    Spacer()
                    Text("Next")
                        .font(.smBody(17, weight: .bold))
                    Image(systemName: SMIcon.next)
                    Spacer()
                }
                .padding(.vertical, 14)
                .background(Color.smTangerine, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .foregroundStyle(.white)
            }
            .buttonStyle(.smPressable)
            .accessibilityIdentifier("nextButton")
        }
        .padding(SMSpacing.md)
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) { iconPop = true }
            Task {
                for index in 0..<question.steps.count {
                    try? await Task.sleep(for: .milliseconds(110))
                    withAnimation(.easeOut(duration: 0.25)) { revealedSteps = index + 1 }
                }
            }
        }
        .sheet(isPresented: $showTutorChat) {
            TutorChatView(question: question, level: question.level)
                .presentationDetents([.fraction(0.55), .large])
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    @ViewBuilder
    private var tutorPrompt: some View {
        Button {
            if proStore.isPro {
                showTutorChat = true
            } else {
                showPaywall = true
            }
        } label: {
            Label(proStore.isPro ? "Ask the AI tutor" : "Unlock the AI tutor with Pro",
                  systemImage: "sparkles")
                .font(.smBody(13, weight: .semibold))
                .foregroundStyle(Color.smTangerine)
        }
        .accessibilityIdentifier("askTutorButton")
        .padding(SMSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .smCard()
        .padding(.top, SMSpacing.sm)
    }
}

#Preview {
    let q = Question(templateID: "preview", topic: "Preview", level: 5,
                      prompt: "6 × 7", spokenPrompt: "6 times 7", answer: .integer(42),
                      steps: ["Multiply 6 × 7.", "Answer: 42."])
    return SolutionView(question: q, correct: true, submittedText: "42", onNext: {})
        .background(Color.smPaper)
        .environment(ProStore())
        .environment(StatsStore())
}
