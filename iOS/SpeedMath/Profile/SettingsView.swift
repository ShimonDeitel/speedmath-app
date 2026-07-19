import SwiftUI

struct SettingsView: View {
    @Environment(StatsStore.self) private var stats
    @Environment(ProStore.self) private var proStore
    @State private var showPaywall = false

    var body: some View {
        Form {
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

            Section("Feedback") {
                Toggle(isOn: Binding(
                    get: { stats.snapshot.soundEnabled },
                    set: { stats.setSoundEnabled($0) }
                )) {
                    Label("Sound", systemImage: SMIcon.sound)
                }
                Toggle(isOn: Binding(
                    get: { stats.snapshot.hapticsEnabled },
                    set: { stats.setHapticsEnabled($0) }
                )) {
                    Label("Haptics", systemImage: SMIcon.haptics)
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
}

#Preview {
    SettingsView()
        .environment(StatsStore())
        .environment(ProStore())
}
