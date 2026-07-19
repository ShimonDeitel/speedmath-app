import Foundation

/// The one file to edit with real AdMob IDs before submission.
///
/// These are Google's published SAMPLE ad unit IDs (safe to ship in test
/// builds; they only ever serve "Test Ad" creatives). Submitting to the App
/// Store with these still in place violates AdMob policy and is caught by
/// the CI gate in SPEC.md — `grep -r 3940256099942544 iOS/` must return only
/// this comment.
enum AdConfig {
    static let bannerUnitID = "ca-app-pub-3940256099942544/2934735716"
    static let nativeUnitID = "ca-app-pub-3940256099942544/3986624511"
    static let interstitialUnitID = "ca-app-pub-3940256099942544/4411468910"

    static let interstitialEveryNRounds = 3
    static let interstitialMinSpacing: TimeInterval = 90
}
