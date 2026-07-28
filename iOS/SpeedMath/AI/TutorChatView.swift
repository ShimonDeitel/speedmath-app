import SwiftUI

/// Half-screen AI tutor chat, Pro-only. Seeded with an opening explanation,
/// then the player can keep asking follow-ups.
struct TutorChatView: View {
    let question: Question
    let level: Int

    @State private var messages: [ChatMessage] = []
    @State private var draft = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("AI Tutor")
                    .font(.smDisplay(18))
                    .foregroundStyle(Color.smInk)
                Spacer()
            }
            .padding(SMSpacing.md)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: SMSpacing.sm) {
                        ForEach(messages) { message in
                            bubble(message)
                                .id(message.id)
                        }
                        if isLoading {
                            HStack(spacing: SMSpacing.xs) {
                                ProgressView()
                                Text("Thinking...")
                                    .font(.smBody(13))
                                    .foregroundStyle(Color.smInkMuted)
                            }
                            .accessibilityIdentifier("tutorThinking")
                        }
                    }
                    .padding(.horizontal, SMSpacing.md)
                }
                .onChange(of: messages) { _, _ in
                    guard let last = messages.last else { return }
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }

            HStack(spacing: SMSpacing.sm) {
                TextField("Ask a follow-up...", text: $draft)
                    .font(.smBody(14))
                    .padding(.horizontal, SMSpacing.sm)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .accessibilityIdentifier("tutorChatInput")
                Button {
                    send()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.smBody(28))
                        .foregroundStyle(draft.trimmingCharacters(in: .whitespaces).isEmpty ? Color.smInkMuted : Color.smTangerine)
                }
                .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                .accessibilityIdentifier("tutorChatSend")
            }
            .padding(SMSpacing.md)
        }
        .background(Color.smPaper.ignoresSafeArea())
        .task {
            guard messages.isEmpty else { return }
            await ask(seed: true)
        }
    }

    @ViewBuilder
    private func bubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.role == .user { Spacer(minLength: 40) }
            Text(message.content)
                .font(.smBody(14))
                .foregroundStyle(message.role == .user ? .white : Color.smInk)
                .padding(SMSpacing.sm)
                .background(
                    message.role == .user ? Color.smTangerine : Color.white.opacity(0.7),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            if message.role == .assistant { Spacer(minLength: 40) }
        }
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        messages.append(ChatMessage(role: .user, content: text))
        draft = ""
        Task { await ask(seed: false) }
    }

    private func ask(seed: Bool) async {
        isLoading = true
        let history = seed
            ? [ChatMessage(role: .user, content: "Why is the answer what it is? Explain it to me.")]
            : messages
        let reply = await ExplainService.chat(question: question, level: level, history: history)
        isLoading = false
        messages.append(ChatMessage(role: .assistant, content: reply))
    }
}

#Preview {
    let q = Question(templateID: "preview", topic: "Preview", level: 5,
                      prompt: "6 × 7", spokenPrompt: "6 times 7", answer: .integer(42),
                      steps: ["Multiply 6 × 7.", "Answer: 42."])
    return TutorChatView(question: q, level: 5)
}
