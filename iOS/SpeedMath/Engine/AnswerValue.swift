import Foundation

/// An answer the engine can generate and the player can enter, in any of
/// three representations. All three compare for mathematical equivalence,
/// not representation equality, so "1/2", "0.5", and a future "2/4" all match.
enum AnswerValue: Equatable, CustomStringConvertible {
    case integer(Int)
    case fraction(num: Int, den: Int)
    case decimal(Double)

    /// Normalizes a fraction to lowest terms with a positive denominator.
    static func reducedFraction(_ num: Int, _ den: Int) -> AnswerValue {
        precondition(den != 0, "fraction denominator must be non-zero")
        var n = num
        var d = den
        if d < 0 { n = -n; d = -d }
        let g = Self.gcd(abs(n), d)
        if g > 1 { n /= g; d /= g }
        if d == 1 { return .integer(n) }
        return .fraction(num: n, den: d)
    }

    private static func gcd(_ a: Int, _ b: Int) -> Int {
        var a = a, b = b
        while b != 0 { (a, b) = (b, a % b) }
        return max(a, 1)
    }

    /// The value as a Double, for equivalence comparison across representations.
    var doubleValue: Double {
        switch self {
        case .integer(let n): return Double(n)
        case .fraction(let n, let d): return Double(n) / Double(d)
        case .decimal(let v): return v
        }
    }

    /// Mathematical equivalence, tolerant of the small rounding error that
    /// can appear when a template's exact fraction doesn't terminate cleanly
    /// at 2 decimal places (templates are constructed to avoid this, but the
    /// comparison stays defensive).
    static func == (lhs: AnswerValue, rhs: AnswerValue) -> Bool {
        abs(lhs.doubleValue - rhs.doubleValue) < 0.005
    }

    func matches(_ input: AnswerValue) -> Bool {
        self == input
    }

    var description: String {
        switch self {
        case .integer(let n):
            return String(n)
        case .fraction(let n, let d):
            return "\(n)/\(d)"
        case .decimal(let v):
            // Templates guarantee <= 2 decimal places; trim to the shortest
            // clean representation (6.1, not 6.10).
            let rounded = (v * 100).rounded() / 100
            if rounded == rounded.rounded() {
                return String(format: "%.0f", rounded)
            }
            var s = String(format: "%.2f", rounded)
            while s.hasSuffix("0") { s.removeLast() }
            if s.hasSuffix(".") { s.removeLast() }
            return s
        }
    }

    /// Parses free-form keypad text: digits, an optional leading "-", an
    /// optional decimal point, or an optional "/" for a fraction. Returns
    /// nil for anything that isn't a clean match to one of the three forms.
    static func parse(display raw: String) -> AnswerValue? {
        let s = raw.trimmingCharacters(in: .whitespaces)
        guard !s.isEmpty else { return nil }

        if s.contains("/") {
            let parts = s.split(separator: "/", maxSplits: 1)
            guard parts.count == 2,
                  let n = Int(parts[0]),
                  let d = Int(parts[1]),
                  d != 0
            else { return nil }
            return reducedFraction(n, d)
        }

        if s.contains(".") {
            guard let v = Double(s) else { return nil }
            return .decimal(v)
        }

        guard let n = Int(s) else { return nil }
        return .integer(n)
    }
}
