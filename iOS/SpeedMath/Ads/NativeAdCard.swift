import SwiftUI
import GoogleMobileAds

/// A native ad rendered inside a cream card matching the app's own content
/// cards, with a mandatory "Ad" attribution badge. Free tier only.
struct NativeAdCard: View {
    @Environment(AdsCoordinator.self) private var adsCoordinator
    @State private var loader = NativeAdLoader()

    private var isUITesting: Bool {
        CommandLine.arguments.contains("-uitest")
    }

    var body: some View {
        Group {
            if isUITesting {
                placeholder
            } else if let ad = loader.nativeAd {
                NativeAdRepresentable(nativeAd: ad)
                    .frame(height: 96)
            } else {
                Color.clear.frame(height: 0)
            }
        }
        .accessibilityIdentifier("adSlot")
        .task {
            guard !isUITesting, adsCoordinator.isReady else { return }
            loader.load(request: adsCoordinator.makeRequest())
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color.white.opacity(0.6))
            .frame(height: 96)
            .overlay(Text("Ad").font(.smBody(11)).foregroundStyle(Color.smInkMuted))
    }
}

@Observable
@MainActor
private final class NativeAdLoader: NSObject, NativeAdLoaderDelegate {
    var nativeAd: NativeAd?
    private var loader: AdLoader?

    func load(request: Request) {
        guard nativeAd == nil, loader == nil else { return }
        let rootVC = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
        loader = AdLoader(
            adUnitID: AdConfig.nativeUnitID,
            rootViewController: rootVC,
            adTypes: [.native],
            options: nil)
        loader?.delegate = self
        loader?.load(request)
    }

    nonisolated func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        Task { @MainActor in self.nativeAd = nativeAd }
    }

    nonisolated func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        // Native ad failed to load; the card stays collapsed (nativeAd == nil).
    }
}

private struct NativeAdRepresentable: UIViewRepresentable {
    let nativeAd: NativeAd

    func makeUIView(context: Context) -> NativeAdView {
        let view = NativeAdView()
        let headline = UILabel()
        headline.font = .systemFont(ofSize: 14, weight: .semibold)
        headline.textColor = UIColor(Color.smInk)
        headline.text = nativeAd.headline
        view.headlineView = headline
        view.addSubview(headline)
        headline.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headline.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            headline.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            headline.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        view.nativeAd = nativeAd
        return view
    }

    func updateUIView(_ uiView: NativeAdView, context: Context) {}
}
