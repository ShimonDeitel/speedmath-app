import SwiftUI

struct SessionView: View {
    @Environment(StatsStore.self) private var stats
    @Environment(ProStore.self) private var proStore
    @Environment(AdsCoordinator.self) private var adsCoordinator
    @Environment(\.dismiss) private var dismiss

    @State private var controller: SessionController?
    @State private var mode: AnswerMode = .type
    @State private var keypadText = ""
    @State private var interstitial = InterstitialController()
    @State private var showLevelUp = false

    var body: some View {
        ZStack {
            Color.smPaper.ignoresSafeArea()

            if let controller {
                content(controller)
            } else {
                brandedLoading
            }

            if showLevelUp {
                LevelUpOverlay(level: stats.level)
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Home") { dismiss() }
            }
        }
        .task {
            guard controller == nil else { return }
            controller = SessionController(startingLevel: stats.level)
            mode = stats.snapshot.defaultMode
            if !proStore.isPro { interstitial.preload(coordinator: adsCoordinator) }
        }
        .onChange(of: stats.justLeveledUp) { _, leveledUp in
            guard leveledUp else { return }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { showLevelUp = true }
            Task {
                try? await Task.sleep(for: .seconds(1.8))
                withAnimation(.easeOut(duration: 0.3)) { showLevelUp = false }
                stats.clearLevelUpFlag()
            }
        }
    }

    private var brandedLoading: some View {
        VStack(spacing: SMSpacing.sm) {
            StopwatchHandView(isSpinning: true, size: 56)
            Text("Getting ready...")
                .font(.smBody(13))
                .foregroundStyle(Color.smInkMuted)
        }
    }

    @ViewBuilder
    private func content(_ controller: SessionController) -> some View {
        VStack(spacing: SMSpacing.md) {
            header(controller)

            if !proStore.isPro {
                BannerAdView()
            }

            switch controller.phase {
            case .asking:
                askingBody(controller)
            case .solved(let correct, let submitted):
                SolutionView(question: controller.question, correct: correct, submittedText: submitted) {
                    keypadText = ""
                    let shownInterstitial = !proStore.isPro && interstitial.maybePresent(from: rootViewController())
                    controller.advance()
                    if !proStore.isPro {
                        interstitial.preload(coordinator: adsCoordinator)
                    }
                    _ = shownInterstitial
                }
            }
        }
        .padding(.horizontal, SMSpacing.md)
        .padding(.bottom, SMSpacing.md)
    }

    @ViewBuilder
    private func header(_ controller: SessionController) -> some View {
        HStack(spacing: SMSpacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text(GradeMap.gradeLabel(for: controller.currentLevel))
                    .font(.smBody(12, weight: .semibold))
                    .foregroundStyle(Color.smInkMuted)
                Text("Level \(controller.currentLevel)")
                    .font(.smBody(11))
                    .foregroundStyle(Color.smInkMuted)
            }
            Spacer()
            if case .asking = controller.phase {
                Picker("Mode", selection: $mode) {
                    Label("Type", systemImage: SMIcon.type).tag(AnswerMode.type)
                    Label("Speed", systemImage: SMIcon.speed).tag(AnswerMode.speed)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 140)
                .accessibilityIdentifier("modePicker")
            }
            StopwatchHandView(isSpinning: controller.phase == .asking, size: 40)
        }
    }

    @ViewBuilder
    private func askingBody(_ controller: SessionController) -> some View {
        VStack(spacing: SMSpacing.lg) {
            Spacer(minLength: SMSpacing.md)

            FlipDigitView(text: controller.question.prompt, fontSize: 40)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier("answerDisplay")

            Spacer(minLength: SMSpacing.sm)

            switch mode {
            case .type:
                VStack(spacing: SMSpacing.sm) {
                    Text(keypadText.isEmpty ? " " : keypadText)
                        .font(.smDisplay(32))
                        .foregroundStyle(Color.smTangerine)
                        .frame(height: 40)
                    KeypadView(text: $keypadText, hapticStyle: stats.snapshot.hapticStyle) {
                        submitTyped(controller)
                    }
                }
            case .speed:
                SpeakAnswerView(
                    onResult: { heard, parsed in
                        controller.submit(parsed, displayText: heard, stats: stats)
                        playFeedback(for: controller)
                    },
                    onSwitchToType: { mode = .type }
                )
            }
        }
    }

    private func submitTyped(_ controller: SessionController) {
        let value = AnswerValue.parse(display: keypadText)
        controller.submit(value, displayText: keypadText, stats: stats)
        playFeedback(for: controller)
    }

    private func playFeedback(for controller: SessionController) {
        guard case .solved(let correct, _) = controller.phase else { return }
        let style = stats.snapshot.hapticStyle
        correct ? Haptics.success(style) : Haptics.failure(style)
        correct ? Sound.correct(enabled: stats.snapshot.soundEnabled) : Sound.wrong(enabled: stats.snapshot.soundEnabled)
    }

    private func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
    }
}
