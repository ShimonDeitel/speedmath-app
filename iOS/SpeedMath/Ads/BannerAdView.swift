import SwiftUI
import GoogleMobileAds

/// An adaptive banner. In free tier only — callers gate on `!proStore.isPro`.
/// Under `-uitest` this renders a static labeled placeholder instead of
/// initializing the ad SDK, so UI tests stay deterministic.
struct BannerAdView: View {
    @Environment(AdsCoordinator.self) private var adsCoordinator

    private var isUITesting: Bool {
        CommandLine.arguments.contains("-uitest")
    }

    var body: some View {
        Group {
            if isUITesting {
                placeholder
            } else if adsCoordinator.isReady {
                BannerRepresentable(adsCoordinator: adsCoordinator)
                    .frame(height: 50)
            } else {
                Color.clear.frame(height: 0)
            }
        }
        .accessibilityIdentifier("adSlot")
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color.smInk.opacity(0.06))
            .frame(height: 50)
            .overlay(Text("Ad").font(.smBody(11)).foregroundStyle(Color.smInkMuted))
    }
}

private struct BannerRepresentable: UIViewRepresentable {
    let adsCoordinator: AdsCoordinator

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = AdConfig.bannerUnitID
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
        banner.load(adsCoordinator.makeRequest())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}
