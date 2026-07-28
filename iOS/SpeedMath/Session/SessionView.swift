import SwiftUI

struct SessionView: View {
    @Environment(StatsStore.self) private var stats
    @Environment(ProStore.self) private var proStore
    @Environment(\.dismiss) private var dismiss

    @State private var controller: SessionController?
    @State private var mode: AnswerMode = .type
    @State private var keypadText = ""
    @State private var useProCalculator = false
    @State private var showLevelUp = false
    @State private var showLimitPaywall = false

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
        }
        .sheet(isPresented: $showLimitPaywall) {
            PaywallView()
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

            Group {
                switch controller.phase {
                case .asking:
                    askingBody(controller)
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)))
                case .solved(let correct, let submitted):
                    if mode == .speed {
                        QuickVerdictView(correct: correct)
                            .transition(.opacity)
                            .task(id: controller.roundsCompleted) {
                                try? await Task.sleep(for: .milliseconds(650))
                                guard !Task.isCancelled else { return }
                                completeRound(controller)
                            }
                    } else {
                        SolutionView(question: controller.question, correct: correct, submittedText: submitted) {
                            completeRound(controller)
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .opacity))
                    }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.82), value: controller.phase)
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

                Button {
                    Haptics.light(stats.snapshot.hapticStyle)
                    keypadText = ""
                    controller.skip()
                } label: {
                    Image(systemName: SMIcon.skip)
                        .font(.smBody(15, weight: .semibold))
                        .foregroundStyle(Color.smInkMuted)
                }
                .accessibilityIdentifier("skipButton")
                .accessibilityLabel("Skip question")
            }
            VStack(spacing: 2) {
                StopwatchHandView(isSpinning: controller.phase == .asking, size: 40)
                if case .asking = controller.phase {
                    liveTimer(controller)
                }
            }
        }
    }

    private func liveTimer(_ controller: SessionController) -> some View {
        TimelineView(.periodic(from: controller.questionShownAt, by: 0.1)) { context in
            Text(Format.seconds(context.date.timeIntervalSince(controller.questionShownAt)))
                .font(.smBody(11, weight: .semibold))
                .foregroundStyle(Color.smInkMuted)
                .monospacedDigit()
        }
        .accessibilityIdentifier("liveTimer")
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

            Group {
                switch mode {
                case .type:
                    VStack(spacing: SMSpacing.sm) {
                        HStack {
                            Text(keypadText.isEmpty ? " " : keypadText)
                                .font(.smDisplay(32))
                                .foregroundStyle(Color.smTangerine)
                            Spacer()
                            Button {
                                Haptics.selection(stats.snapshot.hapticStyle)
                                useProCalculator.toggle()
                            } label: {
                                Text(useProCalculator ? "Pro" : "Basic")
                                    .font(.smBody(12, weight: .semibold))
                                    .foregroundStyle(useProCalculator ? .white : Color.smInkMuted)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        useProCalculator ? Color.smTangerine : Color.white.opacity(0.7),
                                        in: Capsule())
                            }
                            .accessibilityIdentifier("calculatorModeToggle")
                        }
                        .frame(height: 40)
                        KeypadView(text: $keypadText, hapticStyle: stats.snapshot.hapticStyle, showsProRow: useProCalculator) {
                            submitTyped(controller)
                        }
                        Button {
                            Haptics.light(stats.snapshot.hapticStyle)
                            keypadText = ""
                            controller.submit(nil, displayText: "I don't know", stats: stats)
                            playFeedback(for: controller)
                        } label: {
                            Text("I don't know")
                                .font(.smBody(13, weight: .semibold))
                                .foregroundStyle(Color.smInkMuted)
                        }
                        .accessibilityIdentifier("idkButton")
                        .padding(.top, 2)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
                case .speed:
                    SpeakAnswerView(
                        onResult: { heard, parsed in
                            controller.submit(parsed, displayText: heard, stats: stats)
                            playFeedback(for: controller)
                        },
                        onSwitchToType: { mode = .type }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.85), value: mode)
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

    /// Shared by the Solution screen's "Next" tap (Type mode) and the
    /// auto-advance timer (Speed mode): score bookkeeping is already done by
    /// `submit`. If this round's level-up carried a free user past their
    /// cap, block here instead of advancing — the hard paywall check has to
    /// live post-submit since leveling up is what can cross the cap.
    private func completeRound(_ controller: SessionController) {
        keypadText = ""
        if !proStore.isPro && controller.currentLevel > stats.freeLevelCap {
            showLimitPaywall = true
            return
        }
        controller.advance()
    }
}
