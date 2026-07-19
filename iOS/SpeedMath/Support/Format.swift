import Foundation

enum Format {
    /// "3.2s" style short duration for round summaries and stats.
    static func seconds(_ interval: TimeInterval) -> String {
        if interval < 10 {
            return String(format: "%.1fs", interval)
        }
        return String(format: "%.0fs", interval)
    }

    static func percent(_ fraction: Double) -> String {
        "\(Int((fraction * 100).rounded()))%"
    }
}
