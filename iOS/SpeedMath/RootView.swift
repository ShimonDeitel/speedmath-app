import SwiftUI

struct RootView: View {
    @Environment(StatsStore.self) private var stats
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if stats.snapshot.hasCompletedOnboarding {
                NavigationStack {
                    HomeView()
                }
                .tint(Color.smTangerine)
            } else {
                OnboardingView()
            }
        }
        .task { remindLaterIfOnboarded() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { remindLaterIfOnboarded() }
        }
    }

    private func remindLaterIfOnboarded() {
        guard stats.snapshot.hasCompletedOnboarding else { return }
        ReminderScheduler.rescheduleOnAppOpen(level: stats.level)
    }
}

#Preview {
    RootView()
        .environment(ProStore())
        .environment(StatsStore())
}
