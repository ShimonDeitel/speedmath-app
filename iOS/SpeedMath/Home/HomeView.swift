import SwiftUI

struct HomeView: View {
    @Environment(ProStore.self) private var proStore
    @Environment(StatsStore.self) private var stats
    @State private var startSession = false
    @State private var showProfile = false

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
                    dailyGoalLabel
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
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
    }

    private var startButton: some View {
        Button {
            Haptics.light(stats.snapshot.hapticStyle)
            startSession = true
        } label: {
            ZStack {
                Circle()
                    .stroke(Color.smInk.opacity(0.08), lineWidth: 6)
                    .frame(width: 208, height: 208)
                Circle()
                    .trim(from: 0, to: stats.dailyGoalProgress)
                    .stroke(stats.dailyGoalMet ? Color.smCorrect : Color.smBrass,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 208, height: 208)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: stats.dailyGoalProgress)

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

    private var dailyGoalLabel: some View {
        HStack(spacing: 4) {
            Image(systemName: stats.dailyGoalMet ? SMIcon.correct : SMIcon.goal)
                .foregroundStyle(stats.dailyGoalMet ? Color.smCorrect : Color.smBrass)
            Text(stats.dailyGoalMet
                 ? "Daily goal complete!"
                 : "\(stats.snapshot.answeredToday)/\(stats.snapshot.dailyGoal) today")
        }
        .font(.smBody(12, weight: .medium))
        .foregroundStyle(Color.smInkMuted)
        .padding(.top, 2)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(ProStore())
    .environment(StatsStore())
    .environment(AdsCoordinator())
}
