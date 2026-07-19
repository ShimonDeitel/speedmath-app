import Foundation

/// Real AdMob IDs for the SpeedMath app (AdMob account: meir56885@gmail.com,
/// app ID ca-app-pub-5131626660617133~2408905983). Payment profile is not
/// yet complete in AdMob, so ad serving/revenue won't start until that's
/// finished there — the IDs themselves are live and correct.
enum AdConfig {
    static let bannerUnitID = "ca-app-pub-5131626660617133/7744993140"
    static let nativeUnitID = "ca-app-pub-5131626660617133/5202710428"
    static let interstitialUnitID = "ca-app-pub-5131626660617133/7002877254"

    static let interstitialEveryNRounds = 3
    static let interstitialMinSpacing: TimeInterval = 90
}
