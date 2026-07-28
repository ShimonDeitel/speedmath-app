import Foundation

struct ChatMessage: Identifiable, Equatable {
    enum Role { case user, assistant }
    let id = UUID()
    let role: Role
    let content: String
}

/// Powers the Pro-only AI tutor chat — a real back-and-forth about a missed
/// question, scoped to how far along the player is (level, not age).
/// Backed by the shared no-client-key apps-ai-proxy Worker (see
/// pulse/apps-ai-proxy) — no secret ships in the binary; abuse is bounded
/// server-side by a per-IP rate limit.
enum ExplainService {
    private static let endpoint = URL(string: "https://apps-ai-proxy.s0533495227.workers.dev/text")!

    static func chat(question: Question, level: Int, history: [ChatMessage]) async -> String {
        let systemPrompt = """
        You are a patient math tutor helping someone who just got a problem \
        wrong. Explain so it genuinely clicks — plain, concrete language, no \
        jargon beyond what's needed. Match your depth and vocabulary to \
        someone practicing at difficulty level \(level) out of 1500 (higher \
        means more advanced). Keep each reply under 100 words. Plain text \
        only — no markdown, no emojis.

        Problem: \(question.prompt)
        Correct answer: \(question.answer.description)
        """

        var messages: [[String: String]] = [["role": "system", "content": systemPrompt]]
        messages.append(contentsOf: history.map {
            ["role": $0.role == .user ? "user" : "assistant", "content": $0.content]
        })

        let body: [String: Any] = [
            "messages": messages,
            "max_tokens": 250,
            "temperature": 0.3,
        ]

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                return "The tutor is busy right now — try again in a moment."
            }
            let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
            return decoded.choices.first?.message.content ?? "Couldn't get an explanation this time."
        } catch {
            return "Couldn't reach the tutor — check your connection and try again."
        }
    }

    private struct ChatResponse: Decodable {
        struct Choice: Decodable {
            struct Message: Decodable { let content: String }
            let message: Message
        }
        let choices: [Choice]
    }
}
