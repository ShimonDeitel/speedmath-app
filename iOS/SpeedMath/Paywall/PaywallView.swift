import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(ProStore.self) private var proStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.smPaper.ignoresSafeArea()
            VStack(spacing: SMSpacing.lg) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: SMIcon.close)
                            .font(.smBody(16, weight: .bold))
                            .foregroundStyle(Color.smInk)
                            .padding(10)
                            .background(Color.white.opacity(0.6), in: Circle())
                    }
                    .accessibilityIdentifier("paywallClose")
                }

                StopwatchGlyph()
                    .stroke(Color.smTangerine, style: StrokeStyle(lineWidth: 9, lineCap: .round, lineJoin: .round))
                    .frame(width: 84, height: 84)

                VStack(spacing: SMSpacing.xs) {
                    Text("SpeedMath Pro")
                        .font(.smDisplay(30))
                        .foregroundStyle(Color.smInk)
                    Text("Go faster with zero distractions.")
                        .font(.smBody(15))
                        .foregroundStyle(Color.smInkMuted)
                }

                VStack(alignment: .leading, spacing: SMSpacing.sm) {
                    featureRow(icon: "nosign", text: "No ads, ever")
                    featureRow(icon: SMIcon.explain, text: "Ask the AI tutor to explain any question")
                    featureRow(icon: "bolt.fill", text: "A cleaner, faster screen for every round")
                }
                .padding(SMSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .smCard()

                Spacer()

                VStack(spacing: SMSpacing.sm) {
                    Button {
                        Task { await proStore.purchase() }
                    } label: {
                        HStack {
                            Spacer()
                            if proStore.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text(subscribeLabel)
                                    .font(.smBody(17, weight: .bold))
                            }
                            Spacer()
                        }
                        .padding(.vertical, 16)
                        .background(Color.smTangerine, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .foregroundStyle(.white)
                    }
                    .buttonStyle(.smPressable)
                    .disabled(proStore.isLoading || proStore.product == nil)
                    .accessibilityIdentifier("subscribeButton")

                    Button("Restore Purchases") {
                        Task { await proStore.restore() }
                    }
                    .font(.smBody(14))
                    .foregroundStyle(Color.smInkMuted)

                    Text("$4.99/month, auto-renews until canceled. Cancel anytime in Settings.")
                        .font(.smBody(11))
                        .foregroundStyle(Color.smInkMuted)
                        .multilineTextAlignment(.center)

                    HStack(spacing: SMSpacing.sm) {
                        Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/speedmath-app/privacy.html")!)
                        Text("·").foregroundStyle(Color.smInkMuted)
                        Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/speedmath-app/terms.html")!)
                    }
                    .font(.smBody(11))
                }
            }
            .padding(SMSpacing.md)
        }
        .task {
            if proStore.product == nil {
                await proStore.load()
            }
        }
    }

    private var subscribeLabel: String {
        if let price = proStore.product?.displayPrice {
            return "Subscribe — \(price)/month"
        }
        return "Subscribe"
    }

    @ViewBuilder
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: SMSpacing.sm) {
            Image(systemName: icon)
                .font(.smBody(16, weight: .semibold))
                .foregroundStyle(Color.smTangerine)
                .frame(width: 24)
            Text(text)
                .font(.smBody(15))
                .foregroundStyle(Color.smInk)
        }
    }
}

#Preview {
    PaywallView()
        .environment(ProStore())
}
