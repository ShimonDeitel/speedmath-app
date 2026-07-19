import SwiftUI

struct ExplainSheet: View {
    let question: Question
    @Environment(\.dismiss) private var dismiss
    @State private var explanation: String?
    @State private var errorMessage: String?
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color.smPaper.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: SMSpacing.md) {
                        HStack(spacing: SMSpacing.xs) {
                            Image(systemName: SMIcon.explain)
                                .foregroundStyle(Color.smTangerine)
                            Text("AI Tutor")
                                .font(.smBody(15, weight: .bold))
                                .foregroundStyle(Color.smInk)
                        }

                        Text(question.prompt)
                            .font(.smDisplay(20))
                            .foregroundStyle(Color.smInk)

                        if isLoading {
                            HStack {
                                ProgressView()
                                Text("Thinking it through...")
                                    .font(.smBody(14))
                                    .foregroundStyle(Color.smInkMuted)
                            }
                            .padding(.top, SMSpacing.sm)
                        } else if let errorMessage {
                            Text(errorMessage)
                                .font(.smBody(14))
                                .foregroundStyle(Color.smWrong)
                        } else if let explanation {
                            Text(explanation)
                                .font(.smBody(15))
                                .foregroundStyle(Color.smInk)
                                .lineSpacing(4)
                        }
                    }
                    .padding(SMSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .smCard()
                    .padding(SMSpacing.md)
                }
            }
            .navigationTitle("Explain It")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .task {
            await load()
        }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            explanation = try await ExplainService.explain(question: question)
        } catch ExplainError.rateLimited {
            errorMessage = "The tutor is busy right now. Try again in a minute."
        } catch {
            errorMessage = "Couldn't reach the tutor. Check your connection and try again."
        }
        isLoading = false
    }
}
