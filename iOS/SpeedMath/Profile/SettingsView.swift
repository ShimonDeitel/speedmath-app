import SwiftUI

struct SettingsView: View {
    @Environment(StatsStore.self) private var stats
    @Environment(ProStore.self) private var proStore
    @State private var showPaywall = false

    private let dailyGoalOptions = [10, 20, 30, 50, 100]

    var body: some View {
        Form {
            Section("Appearance") {
                VStack(alignment: .leading, spacing: SMSpacing.xs) {
                    Label("Accent color", systemImage: SMIcon.palette)
                    HStack(spacing: SMSpacing.sm) {
                        ForEach(AccentPalette.allCases) { palette in
                            accentSwatch(palette)
                        }
                    }
                    .padding(.vertical, 4)
                }

                VStack(alignment: .leading, spacing: SMSpacing.xs) {
                    Label("Avatar", systemImage: SMIcon.avatar)
                    HStack(spacing: SMSpacing.sm) {
                        ForEach(AvatarIcon.allCases) { icon in
                            avatarSwatch(icon)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Section("Answer mode") {
                Picker("Default mode", selection: Binding(
                    get: { stats.snapshot.defaultMode },
                    set: { stats.setDefaultMode($0) }
                )) {
                    Label("Type", systemImage: SMIcon.type).tag(AnswerMode.type)
                    Label("Speed", systemImage: SMIcon.speed).tag(AnswerMode.speed)
                }
                .pickerStyle(.segmented)
            }

            Section("Difficulty") {
                Picker("Start at grade", selection: Binding(
                    get: { GradeMap.gradeIndex(for: stats.snapshot.level) },
                    set: { stats.setLevel($0 * 10 + 1) }
                )) {
                    ForEach(0..<12) { index in
                        Text("Grade \(index + 1)").tag(index)
                    }
                    Text("University").tag(12)
                }
            }

            Section("Daily goal") {
                Picker("Questions per day", selection: Binding(
                    get: { stats.snapshot.dailyGoal },
                    set: { stats.setDailyGoal($0) }
                )) {
                    ForEach(dailyGoalOptions, id: \.self) { goal in
                        Text("\(goal)").tag(goal)
                    }
                }
                .pickerStyle(.segmented)
                Label("\(stats.snapshot.answeredToday) of \(stats.snapshot.dailyGoal) answered today", systemImage: SMIcon.goal)
                    .font(.smBody(13))
                    .foregroundStyle(Color.smInkMuted)
            }

            Section("Feedback") {
                Toggle(isOn: Binding(
                    get: { stats.snapshot.soundEnabled },
                    set: { stats.setSoundEnabled($0) }
                )) {
                    Label("Sound", systemImage: SMIcon.sound)
                }
                Picker("Haptics", selection: Binding(
                    get: { stats.snapshot.hapticStyle },
                    set: { stats.setHapticStyle($0) }
                )) {
                    ForEach(HapticStyle.allCases) { style in
                        Text(style.displayName).tag(style)
                    }
                }
            }

            Section("Profile") {
                TextField("Display name", text: Binding(
                    get: { stats.snapshot.displayName },
                    set: { stats.setDisplayName($0) }
                ))
                .accessibilityIdentifier("displayNameField")
            }

            Section {
                if proStore.isPro {
                    Label("You're Pro — ads removed", systemImage: SMIcon.correct)
                        .foregroundStyle(Color.smCorrect)
                } else {
                    Button {
                        showPaywall = true
                    } label: {
                        Label("Upgrade to Pro", systemImage: "sparkles")
                    }
                    .accessibilityIdentifier("upgradeButton")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.smPaper)
        .dismissKeyboardOnTap()
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    @ViewBuilder
    private func accentSwatch(_ palette: AccentPalette) -> some View {
        let isSelected = ThemeManager.shared.palette == palette
        Button {
            Haptics.selection(stats.snapshot.hapticStyle)
            ThemeManager.shared.palette = palette
        } label: {
            Circle()
                .fill(palette.base)
                .frame(width: 32, height: 32)
                .overlay(
                    Circle().strokeBorder(Color.smInk, lineWidth: isSelected ? 2.5 : 0)
                        .padding(-3))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(palette.displayName)
        .accessibilityIdentifier("accentSwatch_\(palette.rawValue)")
    }

    @ViewBuilder
    private func avatarSwatch(_ icon: AvatarIcon) -> some View {
        let isSelected = stats.snapshot.avatar == icon
        Button {
            Haptics.selection(stats.snapshot.hapticStyle)
            stats.setAvatar(icon)
        } label: {
            Image(systemName: icon.symbolName)
                .font(.smBody(18, weight: .semibold))
                .foregroundStyle(isSelected ? .white : Color.smInk)
                .frame(width: 40, height: 40)
                .background(
                    isSelected ? Color.smTangerine : Color.smInk.opacity(0.08),
                    in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(icon.rawValue)
        .accessibilityIdentifier("avatarSwatch_\(icon.rawValue)")
    }
}

#Preview {
    SettingsView()
        .environment(StatsStore())
        .environment(ProStore())
}
