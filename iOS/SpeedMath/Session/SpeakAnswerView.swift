import SwiftUI

/// Speed mode's answer surface: live transcript in flip digits, a waveform
/// while listening, auto-submit on silence. Falls back to a "say it as a
/// number" hint (and re-listens) when the parser can't make sense of what
/// was heard.
struct SpeakAnswerView: View {
    var onResult: (String, AnswerValue?) -> Void
    var onSwitchToType: () -> Void

    @StateObject private var listener = SpeechListener()
    @State private var hint: String?
    @State private var didRequestPermission = false

    var body: some View {
        VStack(spacing: SMSpacing.lg) {
            Text(listener.transcript.isEmpty ? "Listening..." : listener.transcript)
                .font(.smDisplay(34))
                .foregroundStyle(Color.smInk)
                .frame(minHeight: 60)
                .accessibilityIdentifier("speakTranscript")

            WaveformView(isActive: listener.isListening)
                .frame(height: 40)

            if let hint {
                Text(hint)
                    .font(.smBody(13))
                    .foregroundStyle(Color.smWrong)
            }

            if listener.denied {
                VStack(spacing: SMSpacing.xs) {
                    Text("Microphone or speech access is off.")
                        .font(.smBody(13))
                        .foregroundStyle(Color.smInkMuted)
                    Button("Type instead", action: onSwitchToType)
                        .font(.smBody(14, weight: .semibold))
                }
            } else {
                Button("Type instead", action: onSwitchToType)
                    .font(.smBody(13))
                    .foregroundStyle(Color.smInkMuted)
            }
        }
        .onAppear { setUp() }
        .onDisappear { listener.stop() }
    }

    private func setUp() {
        listener.onAutoStop = { heard in
            let parsed = SpokenNumberParser.parse(heard)
            if parsed == nil, !heard.trimmingCharacters(in: .whitespaces).isEmpty {
                hint = "Didn't catch a number — say it again."
                listener.start()
                return
            }
            onResult(heard, parsed)
        }
        guard !didRequestPermission else {
            if listener.isAvailable { listener.start() }
            return
        }
        didRequestPermission = true
        Task {
            let granted = await listener.requestPermissions()
            if granted { listener.start() }
        }
    }
}

private struct WaveformView: View {
    var isActive: Bool
    @State private var phase: CGFloat = 0

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.08, paused: !isActive)) { context in
            HStack(spacing: 4) {
                ForEach(0..<20, id: \.self) { i in
                    Capsule()
                        .fill(Color.smTangerine.opacity(isActive ? 1 : 0.25))
                        .frame(width: 4, height: barHeight(i, at: context.date))
                }
            }
        }
    }

    private func barHeight(_ index: Int, at date: Date) -> CGFloat {
        guard isActive else { return 6 }
        let t = date.timeIntervalSinceReferenceDate
        let wave = sin(t * 6 + Double(index) * 0.6)
        return 8 + CGFloat((wave + 1) / 2) * 28
    }
}
