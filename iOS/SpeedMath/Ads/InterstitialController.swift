import Foundation
import Observation
import GoogleMobileAds

/// Preloads and presents the between-rounds interstitial. Cadence rules
/// (every N rounds, minimum spacing, never mid-question) are enforced by
/// the caller (RoundSummaryView); this type only owns load/present.
@Observable
@MainActor
final class InterstitialController: NSObject, FullScreenContentDelegate {
    private var interstitial: InterstitialAd?
    private var lastShownAt: Date?
    private var roundsSinceShown = 0

    private var isUITesting: Bool {
        CommandLine.arguments.contains("-uitest")
    }

    func preload(coordinator: AdsCoordinator) {
        guard !isUITesting, coordinator.isReady, interstitial == nil else { return }
        Task {
            interstitial = try? await InterstitialAd.load(
                with: AdConfig.interstitialUnitID, request: coordinator.makeRequest())
            interstitial?.fullScreenContentDelegate = self
        }
    }

    /// Call once per completed round. Returns true if it decided to show.
    @discardableResult
    func maybePresent(from root: UIViewController?) -> Bool {
        roundsSinceShown += 1
        guard !isUITesting else { return false }
        guard roundsSinceShown >= AdConfig.interstitialEveryNRounds else { return false }
        if let lastShownAt, Date().timeIntervalSince(lastShownAt) < AdConfig.interstitialMinSpacing {
            return false
        }
        guard let interstitial, let root else { return false }
        roundsSinceShown = 0
        lastShownAt = Date()
        interstitial.present(from: root)
        self.interstitial = nil
        return true
    }

    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in interstitial = nil }
    }
}
