import Foundation
import Observation
import AppTrackingTransparency
import GoogleMobileAds
import UserMessagingPlatform

/// Owns ATT + UMP consent + SDK startup for the whole app. Every ad-showing
/// view reads `isReady` and `nonPersonalizedOnly` from this instead of
/// touching the SDK directly.
@Observable
@MainActor
final class AdsCoordinator {
    private(set) var isReady = false
    private(set) var nonPersonalizedOnly = false

    private var isUITesting: Bool {
        CommandLine.arguments.contains("-uitest")
    }

    func start() async {
        guard !isUITesting else { return }

        if #available(iOS 14, *) {
            let status = await ATTrackingManager.requestTrackingAuthorization()
            nonPersonalizedOnly = status != .authorized
        }

        await requestConsentIfNeeded()

        MobileAds.shared.requestConfiguration.maxAdContentRating = .general

        await MobileAds.shared.start()
        isReady = true
    }

    /// A ready-to-use ad request honoring the current consent state.
    func makeRequest() -> Request {
        let request = Request()
        if nonPersonalizedOnly {
            let extras = Extras()
            extras.additionalParameters = ["npa": "1"]
            request.register(extras)
        }
        return request
    }

    private func requestConsentIfNeeded() async {
        let parameters = RequestParameters()
        parameters.isTaggedForUnderAgeOfConsent = false

        await withCheckedContinuation { continuation in
            ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { _ in
                continuation.resume()
            }
        }

        guard ConsentInformation.shared.formStatus == .available else { return }

        await withCheckedContinuation { continuation in
            ConsentForm.loadAndPresentIfRequired(from: nil) { _ in
                continuation.resume()
            }
        }
    }
}
