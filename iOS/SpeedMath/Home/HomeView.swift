import SwiftUI

struct HomeView: View {
    @Environment(ProStore.self) private var proStore
    @Environment(StatsStore.self) private var stats
    @State private var startSession = false
    @State private var showProfile = false
    @State private var showLimitPaywall = false
    @State private var breathe = false

    private var atFreeLimit: Bool {
        !proStore.isPro && stats.level >= stats.freeLevelCap
    }

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

                Spacer()

                VStack(spacing: SMSpacing.xs) {
                    Text(GradeMap.gradeLabel(for: stats.level))
                        .font(.smBody(14, weight: .semibold))
                        .foregroundStyle(Color.smInkMuted)
                    startButton
                    Text("Level \(stats.level) of \(GradeMap.maxLevel)")
                        .font(.smBody(12))
                        .foregroundStyle(Color.smInkMuted)
                    if atFreeLimit {
                        limitReachedLabel
                    } else {
                        dailyGoalLabel
                    }
                }

                Spacer()
            }
            .padding(SMSpacing.md)
        }
        .navigationDestination(isPresented: $startSession) {
            SessionView()
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .sheet(isPresented: $showLimitPaywall) {
            PaywallView()
        }
    }

    private var limitReachedLabel: some View {
        HStack(spacing: 4) {
            Image(systemName: "lock.fill")
            Text("Free limit reached — upgrade to keep going")
        }
        .font(.smBody(12, weight: .medium))
        .foregroundStyle(Color.smTangerine)
        .padding(.top, 2)
    }

    private var startButton: some View {
        Button {
            Haptics.light(stats.snapshot.hapticStyle)
            if atFreeLimit {
                showLimitPaywall = true
            } else {
                startSession = true
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.smTangerine.opacity(0.16))
                    .frame(width: 210, height: 210)
                    .scaleEffect(breathe ? 1.16 : 0.92)
                    .opacity(breathe ? 0 : 0.6)
                    .animation(.easeOut(duration: 2.6).repeatForever(autoreverses: false), value: breathe)

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
            .scaleEffect(breathe ? 1.015 : 1.0)
            .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: breathe)
        }
        .buttonStyle(.smPressable)
        .accessibilityIdentifier("startButton")
        .onAppear { breathe = true }
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
}
