import Foundation

/// Turns whatever SFSpeechRecognizer heard into an `AnswerValue`. The
/// recognizer often already emits digits/fractions/decimals as symbols
/// ("42", "3/4", "2.5") — that's tried first. Word forms ("forty two",
/// "three quarters", "two point five", "minus seven") are parsed as a
/// fallback. Returns nil for anything that isn't a clean match.
enum SpokenNumberParser {
    private static let fillerPrefixes = [
        "the answer is", "answer is", "it's", "its", "i think it's",
        "um", "uh", "well", "it is",
    ]

    private static let ones: [String: Int] = [
        "zero": 0, "one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
        "six": 6, "seven": 7, "eight": 8, "nine": 9,
    ]
    private static let teens: [String: Int] = [
        "ten": 10, "eleven": 11, "twelve": 12, "thirteen": 13, "fourteen": 14,
        "fifteen": 15, "sixteen": 16, "seventeen": 17, "eighteen": 18, "nineteen": 19,
    ]
    private static let tens: [String: Int] = [
        "twenty": 20, "thirty": 30, "forty": 40, "fifty": 50,
        "sixty": 60, "seventy": 70, "eighty": 80, "ninety": 90,
    ]
    private static let scales: [String: Int] = ["hundred": 100, "thousand": 1000]

    /// Spoken fraction denominators: word -> denominator.
    private static let fractionWords: [String: Int] = [
        "half": 2, "halves": 2,
        "third": 3, "thirds": 3,
        "quarter": 4, "quarters": 4, "fourth": 4, "fourths": 4,
        "fifth": 5, "fifths": 5,
        "sixth": 6, "sixths": 6,
        "seventh": 7, "sevenths": 7,
        "eighth": 8, "eighths": 8,
        "ninth": 9, "ninths": 9,
        "tenth": 10, "tenths": 10,
    ]

    static func parse(_ raw: String) -> AnswerValue? {
        let cleaned = clean(raw)
        guard !cleaned.isEmpty else { return nil }

        if let direct = AnswerValue.parse(display: cleaned.replacingOccurrences(of: " ", with: "")) {
            return direct
        }

        let words = cleaned.split(separator: " ").map(String.init)
        guard !words.isEmpty else { return nil }

        var isNegative = false
        var rest = words
        if let first = rest.first, first == "minus" || first == "negative" {
            isNegative = true
            rest.removeFirst()
        }
        guard !rest.isEmpty else { return nil }

        if let decimal = parseDecimal(rest) {
            return .decimal(isNegative ? -decimal : decimal)
        }

        if let fraction = parseFraction(rest) {
            let value = isNegative ? AnswerValue.reducedFraction(-fraction.0, fraction.1)
                                    : AnswerValue.reducedFraction(fraction.0, fraction.1)
            return value
        }

        if let n = wordsToInt(rest) {
            return .integer(isNegative ? -n : n)
        }

        return nil
    }

    private static func clean(_ raw: String) -> String {
        var s = raw.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        s = s.trimmingCharacters(in: CharacterSet(charactersIn: ".!?"))
        for prefix in fillerPrefixes where s.hasPrefix(prefix) {
            s = String(s.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
        }
        s = s.replacingOccurrences(of: "-", with: " ")
        s = s.replacingOccurrences(of: "  ", with: " ")
        return s
    }

    /// "two point five" -> 2.5, "one point two five" -> 1.25
    private static func parseDecimal(_ words: [String]) -> Double? {
        guard let pointIndex = words.firstIndex(of: "point") else { return nil }
        let wholeWords = Array(words[..<pointIndex])
        let fractionalWords = Array(words[(pointIndex + 1)...])
        guard !fractionalWords.isEmpty else { return nil }

        let whole = wholeWords.isEmpty ? 0 : (wordsToInt(wholeWords) ?? 0)

        var digits = ""
        for word in fractionalWords {
            if let d = ones[word] {
                digits += String(d)
            } else {
                return nil
            }
        }
        guard let fractionalValue = Double("0." + digits) else { return nil }
        return Double(whole) + fractionalValue
    }

    /// "three quarters" -> (3, 4); "one over eight" -> (1, 8)
    private static func parseFraction(_ words: [String]) -> (Int, Int)? {
        if let overIndex = words.firstIndex(of: "over"), overIndex > 0, overIndex < words.count - 1 {
            let numWords = Array(words[..<overIndex])
            let denWords = Array(words[(overIndex + 1)...])
            guard let num = wordsToInt(numWords), let den = wordsToInt(denWords), den != 0 else { return nil }
            return (num, den)
        }

        guard let last = words.last, let den = fractionWords[last] else { return nil }
        let leading = Array(words.dropLast())
        if leading.isEmpty || leading == ["a"] || leading == ["an"] {
            return (1, den) // "half" or "a half"
        }
        guard let num = wordsToInt(leading) else { return nil }
        return (num, den)
    }

    /// Standard English integer word parsing: "one hundred twelve" -> 112.
    private static func wordsToInt(_ words: [String]) -> Int? {
        guard !words.isEmpty else { return nil }
        var total = 0
        var current = 0
        var matchedAny = false

        for word in words {
            if word == "and" { continue }
            if let n = ones[word] {
                current += n
                matchedAny = true
            } else if let n = teens[word] {
                current += n
                matchedAny = true
            } else if let n = tens[word] {
                current += n
                matchedAny = true
            } else if let scale = scales[word] {
                current = current == 0 ? scale : current * scale
                matchedAny = true
                if scale == 1000 {
                    total += current
                    current = 0
                }
            } else {
                return nil
            }
        }

        guard matchedAny else { return nil }
        return total + current
    }
}
