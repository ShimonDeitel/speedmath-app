import Foundation

enum ExplainError: Error {
    case rateLimited
    case badResponse
}

/// Pro-only "explain it" tutor. Posts to the shared, no-client-key
/// apps-ai-proxy Worker (pulse/apps-ai-proxy) — same /text contract every
/// app in the Animated Ten batch uses. No route change needed there; the
/// tutor system prompt lives entirely on this side.
enum ExplainService {
    private static let endpoint = URL(string: "https://apps-ai-proxy.s0533495227.workers.dev/text")!

    private struct ChatMessage: Encodable {
        let role: String
        let content: String
    }

    private struct RequestBody: Encodable {
        let messages: [ChatMessage]
        let max_tokens: Int
        let temperature: Double
    }

    private struct ResponseChoiceMessage: Decodable { let content: String }
    private struct ResponseChoice: Decodable { let message: ResponseChoiceMessage }
    private struct ResponseBody: Decodable { let choices: [ResponseChoice] }

    static func explain(question: Question) async throws -> String {
        let system = """
        You are a patient math tutor. Explain step by step, in plain \
        language, how to solve the given problem for a student at the \
        stated grade level. Keep it under 150 words. Use plain text only, \
        no markdown, no emojis.
        """
        let user = """
        Grade level: \(GradeMap.gradeLabel(for: question.level))
        Question: \(question.prompt)
        Correct answer: \(question.answer)
        """

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(RequestBody(
            messages: [
                ChatMessage(role: "system", content: system),
                ChatMessage(role: "user", content: user),
            ],
            max_tokens: 400,
            temperature: 0.3))

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw ExplainError.badResponse }
        if http.statusCode == 429 { throw ExplainError.rateLimited }
        guard http.statusCode == 200 else { throw ExplainError.badResponse }

        let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
        guard let content = decoded.choices.first?.message.content, !content.isEmpty else {
            throw ExplainError.badResponse
        }
        return content
    }
}
