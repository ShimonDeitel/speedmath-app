import AudioToolbox

/// Short system-sound cues gated by the sound setting. No bundled audio
/// assets — these map to stock AudioToolbox system sound IDs.
enum Sound {
    private static let tickID: SystemSoundID = 1104
    private static let flipID: SystemSoundID = 1123
    private static let correctID: SystemSoundID = 1025
    private static let wrongID: SystemSoundID = 1053

    static func tick(enabled: Bool) {
        guard enabled else { return }
        AudioServicesPlaySystemSound(tickID)
    }

    static func flip(enabled: Bool) {
        guard enabled else { return }
        AudioServicesPlaySystemSound(flipID)
    }

    static func correct(enabled: Bool) {
        guard enabled else { return }
        AudioServicesPlaySystemSound(correctID)
    }

    static func wrong(enabled: Bool) {
        guard enabled else { return }
        AudioServicesPlaySystemSound(wrongID)
    }
}
