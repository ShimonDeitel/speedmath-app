import SwiftUI

struct HomeView: View {
    @Binding var showProfile: Bool
    @Environment(ProStore.self) private var proStore
    @Environment(StatsStore.self) private var stats
    @State private var startSession = false

    var body: some View {
        ZStack {
            Color.smPaper.ignoresSafeArea()

            VStack(spacing: SMSpacing.lg) {
                HStack {
                    SMWordmark()
                    Spacer()
                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: SMIcon.profile)
                            .font(.smBody(22))
                            .foregroundStyle(Color.smInk)
                    }
                    .accessibilityIdentifier("profileButton")
                }
                .padding(.top, SMSpacing.sm)

                if !proStore.isPro {
                    BannerAdView()
                }

                Spacer()

                VStack(spacing: SMSpacing.xs) {
                    Text(GradeMap.gradeLabel(for: stats.level))
                        .font(.smBody(14, weight: .semibold))
                        .foregroundStyle(Color.smInkMuted)
                    startButton
                    Text("Level \(stats.level) of 130")
                        .font(.smBody(12))
                        .foregroundStyle(Color.smInkMuted)
                }

                Spacer()

                if !proStore.isPro {
                    NativeAdCard()
                }
            }
            .padding(SMSpacing.md)
        }
        .navigationDestination(isPresented: $startSession) {
            SessionView()
        }
    }

    private var startButton: some View {
        Button {
            Haptics.light()
            startSession = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color.smTangerine)
                    .frame(width: 176, height: 176)
                Circle()
                    .strokeBorder(Color.smInk.opacity(0.12), lineWidth: 6)
                    .frame(width: 192, height: 192)
                VStack(spacing: 6) {
                    Image(systemName: SMIcon.start)
                        .font(.system(size: 40, weight: .bold))
                    Text("START")
                        .font(.smDisplay(20))
                }
                .foregroundStyle(.white)
            }
        }
        .buttonStyle(.smPressable)
        .accessibilityIdentifier("startButton")
    }
}

#Preview {
    NavigationStack {
        HomeView(showProfile: .constant(false))
    }
    .environment(ProStore())
    .environment(StatsStore())
    .environment(AdsCoordinator())
}
