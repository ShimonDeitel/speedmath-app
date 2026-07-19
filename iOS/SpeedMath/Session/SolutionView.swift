import SwiftUI

struct SolutionView: View {
    let question: Question
    let correct: Bool
    let submittedText: String
    var onNext: () -> Void

    @Environment(ProStore.self) private var proStore
    @Environment(StatsStore.self) private var stats
    @State private var showExplain = false

    var body: some View {
        VStack(spacing: SMSpacing.md) {
            HStack(spacing: SMSpacing.sm) {
                Image(systemName: correct ? SMIcon.correct : SMIcon.wrong)
                    .font(.smBody(28, weight: .bold))
                    .foregroundStyle(correct ? Color.smCorrect : Color.smWrong)
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
                    }

                    if proStore.isPro {
                        Button {
                            showExplain = true
                        } label: {
                            Label("Ask the AI tutor", systemImage: SMIcon.explain)
                                .font(.smBody(14, weight: .semibold))
                        }
                        .padding(.top, SMSpacing.xs)
                        .accessibilityIdentifier("explainButton")
                    } else {
                        Button {
                            showExplain = true
                        } label: {
                            Label("Explain It — Pro", systemImage: SMIcon.lock)
                                .font(.smBody(14, weight: .semibold))
                                .foregroundStyle(Color.smInkMuted)
                        }
                        .padding(.top, SMSpacing.xs)
                        .accessibilityIdentifier("explainLockedButton")
                    }
                }
                .accessibilityIdentifier("solutionSteps")
                .padding(SMSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .smCard()

                if !proStore.isPro {
                    NativeAdCard().padding(.top, SMSpacing.sm)
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
        .sheet(isPresented: $showExplain) {
            if proStore.isPro {
                ExplainSheet(question: question)
            } else {
                PaywallView()
            }
        }
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
