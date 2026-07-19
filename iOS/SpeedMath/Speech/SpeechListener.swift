import Foundation
import Speech
import AVFoundation

/// On-device speech transcription for Speed mode. Audio never leaves the
/// phone. Listening auto-stops after a short pause once something has
/// actually been said. Adapted from cubby-v1-archive/Cubby/Services/SpeechListener.swift.
@MainActor
final class SpeechListener: ObservableObject {
    @Published private(set) var transcript = ""
    @Published private(set) var isListening = false
    @Published private(set) var denied = false

    /// Fires once, automatically, after `silenceWindow` of no new words.
    var onAutoStop: ((String) -> Void)?

    /// How long a pause has to be before it counts as "done talking".
    private let silenceWindow: TimeInterval = 1.0

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var task: SFSpeechRecognitionTask?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private let engine = AVAudioEngine()
    private var silenceTimer: Timer?

    var isAvailable: Bool {
        recognizer?.isAvailable ?? false
    }

    /// Asks for speech + microphone permission (system prompts, first time).
    func requestPermissions() async -> Bool {
        let speech = await withCheckedContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status == .authorized)
            }
        }
        let mic = await AVAudioApplication.requestRecordPermission()
        denied = !(speech && mic)
        return speech && mic
    }

    func start() {
        guard !isListening else { return }
        transcript = ""
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .measurement,
                                    options: [.duckOthers, .defaultToSpeaker])
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            if recognizer?.supportsOnDeviceRecognition == true {
                request.requiresOnDeviceRecognition = true
            }
            self.request = request

            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)
            input.removeTap(onBus: 0)
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                request.append(buffer)
            }
            engine.prepare()
            try engine.start()
            isListening = true

            task = recognizer?.recognitionTask(with: request) { [weak self] result, error in
                Task { @MainActor in
                    guard let self else { return }
                    if let result {
                        let text = result.bestTranscription.formattedString
                        if text != self.transcript {
                            self.transcript = text
                            self.armSilenceTimer()
                        }
                    }
                    if error != nil {
                        self.teardown()
                    }
                }
            }
        } catch {
            teardown()
        }
    }

    /// Restarts the silence countdown; fires `onAutoStop` once it elapses
    /// with no further speech.
    private func armSilenceTimer() {
        silenceTimer?.invalidate()
        guard !transcript.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        silenceTimer = Timer.scheduledTimer(withTimeInterval: silenceWindow, repeats: false) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isListening else { return }
                let heard = self.stop()
                self.onAutoStop?(heard)
            }
        }
    }

    /// Stops listening and returns whatever was heard. Safe to call
    /// mid-silence-countdown or from a manual "stop" button.
    @discardableResult
    func stop() -> String {
        let heard = transcript
        teardown()
        return heard
    }

    private func teardown() {
        silenceTimer?.invalidate()
        silenceTimer = nil
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        request?.endAudio()
        request = nil
        task?.cancel()
        task = nil
        isListening = false
        // Hand the audio session back to gentle playback mode.
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
    }
}
