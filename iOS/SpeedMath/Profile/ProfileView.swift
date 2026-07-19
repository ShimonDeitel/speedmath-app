import SwiftUI

struct ProfileView: View {
    @Environment(StatsStore.self) private var stats
    @Environment(ProStore.self) private var proStore
    @Environment(\.dismiss) private var dismiss
    @State private var showSettings = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.smPaper.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: SMSpacing.lg) {
                        VStack(spacing: SMSpacing.xs) {
                            Text(stats.performingGradeLabel)
                                .font(.smDisplay(34))
                                .foregroundStyle(Color.smInk)
                            Text("performing at this grade")
                                .font(.smBody(13))
                                .foregroundStyle(Color.smInkMuted)
                            Text("Currently \(GradeMap.gradeLabel(for: stats.level)) · Level \(stats.level)")
                                .font(.smBody(13, weight: .semibold))
                                .foregroundStyle(Color.smTangerine)
                        }
                        .padding(.top, SMSpacing.md)

                        HStack(spacing: SMSpacing.sm) {
                            statTile(title: "Answered", value: "\(stats.snapshot.totalAnswered)")
                            statTile(title: "Accuracy", value: Format.percent(stats.overallAccuracy))
                            statTile(title: "Best Streak", value: "\(stats.snapshot.bestStreak)")
                        }

                        HStack(spacing: SMSpacing.sm) {
                            statTile(title: "Avg Time", value: Format.seconds(stats.averageTimeSeconds))
                            statTile(title: "Best Time", value: stats.snapshot.bestTimeSeconds.map(Format.seconds) ?? "—")
                            statTile(title: "Streak Now", value: "\(stats.snapshot.currentStreak)")
                        }

                        if !proStore.isPro {
                            Button {
                                showPaywall = true
                            } label: {
                                HStack {
                                    Image(systemName: SMIcon.explain)
                                    Text("Go Pro — remove ads, unlock AI tutor")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .font(.smBody(14, weight: .semibold))
                                .padding(SMSpacing.md)
                                .foregroundStyle(.white)
                                .background(Color.smTangerine, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                            .buttonStyle(.smPressable)
                        }
                    }
                    .padding(SMSpacing.md)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: SMIcon.settings)
                    }
                    .accessibilityIdentifier("settingsButton")
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    @ViewBuilder
    private func statTile(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.smDisplay(22))
                .foregroundStyle(Color.smInk)
            Text(title)
                .font(.smBody(11))
                .foregroundStyle(Color.smInkMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SMSpacing.sm)
        .smCard()
    }
}

#Preview {
    ProfileView()
        .environment(StatsStore())
        .environment(ProStore())
}
