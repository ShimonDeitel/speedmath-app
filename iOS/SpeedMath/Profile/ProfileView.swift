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
                            ZStack {
                                Circle()
                                    .fill(Color.smTangerine.opacity(0.14))
                                    .frame(width: 72, height: 72)
                                Image(systemName: stats.snapshot.avatar.symbolName)
                                    .font(.smBody(30, weight: .semibold))
                                    .foregroundStyle(Color.smTangerine)
                            }
                            .padding(.bottom, SMSpacing.xs)

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

                        dailyGoalCard

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

                        if !stats.bandAccuracyBreakdown.isEmpty {
                            bandBreakdown
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

    private var dailyGoalCard: some View {
        HStack(spacing: SMSpacing.md) {
            ZStack {
                Circle()
                    .stroke(Color.smInk.opacity(0.1), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: stats.dailyGoalProgress)
                    .stroke(stats.dailyGoalMet ? Color.smCorrect : Color.smTangerine,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: stats.dailyGoalProgress)
                Image(systemName: stats.dailyGoalMet ? SMIcon.correct : SMIcon.goal)
                    .font(.smBody(16, weight: .bold))
                    .foregroundStyle(stats.dailyGoalMet ? Color.smCorrect : Color.smTangerine)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text("Today's goal")
                    .font(.smBody(13, weight: .semibold))
                    .foregroundStyle(Color.smInk)
                Text("\(stats.snapshot.answeredToday) of \(stats.snapshot.dailyGoal) questions")
                    .font(.smBody(12))
                    .foregroundStyle(Color.smInkMuted)
            }
            Spacer()
        }
        .padding(SMSpacing.md)
        .smCard()
    }

    private var bandBreakdown: some View {
        VStack(alignment: .leading, spacing: SMSpacing.sm) {
            Text("Accuracy by grade")
                .font(.smBody(13, weight: .bold))
                .foregroundStyle(Color.smInkMuted)
            ForEach(stats.bandAccuracyBreakdown, id: \.label) { entry in
                HStack(spacing: SMSpacing.sm) {
                    Text(entry.label)
                        .font(.smBody(13))
                        .foregroundStyle(Color.smInk)
                        .frame(width: 76, alignment: .leading)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.smInk.opacity(0.08))
                            Capsule()
                                .fill(entry.accuracy >= 0.7 ? Color.smCorrect : Color.smTangerine)
                                .frame(width: geo.size.width * entry.accuracy)
                        }
                    }
                    .frame(height: 8)
                    Text(Format.percent(entry.accuracy))
                        .font(.smBody(12, weight: .semibold))
                        .foregroundStyle(Color.smInkMuted)
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
        .padding(SMSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .smCard()
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
