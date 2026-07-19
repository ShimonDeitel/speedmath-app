import SwiftUI

/// A custom in-app numeric keypad — digits plus minus/point/slash, so any
/// AnswerValue (integer, fraction, decimal) is enterable without the system
/// keyboard. This is deliberate: it keeps the answer flow ad-safe (no
/// system keyboard covering the screen) and is why Settings carries a real
/// text field for the mandatory keyboard-dismiss UI test.
struct KeypadView: View {
    @Binding var text: String
    var onSubmit: () -> Void

    private let rows: [[String]] = [
        ["7", "8", "9"],
        ["4", "5", "6"],
        ["1", "2", "3"],
        ["-", "0", "."],
    ]

    var body: some View {
        VStack(spacing: SMSpacing.xs) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: SMSpacing.xs) {
                    ForEach(row, id: \.self) { key in
                        keyButton(key) { append(key) }
                    }
                }
            }
            HStack(spacing: SMSpacing.xs) {
                keyButton("/") { append("/") }
                keyButton("⌫", role: .delete) { backspace() }
                submitButton
            }
        }
    }

    private func append(_ s: String) {
        Haptics.selection()
        if s == "-" {
            if text.hasPrefix("-") {
                text.removeFirst()
            } else {
                text = "-" + text
            }
            return
        }
        if s == "." && text.contains(".") { return }
        if s == "/" && text.contains("/") { return }
        text += s
    }

    private func backspace() {
        Haptics.selection()
        guard !text.isEmpty else { return }
        text.removeLast()
    }

    private enum KeyRole { case digit, delete }

    private func keyButton(_ label: String, role: KeyRole = .digit, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.smDisplay(24))
                .foregroundStyle(role == .delete ? Color.smWrong : Color.smInk)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.smPressable)
        .accessibilityIdentifier(role == .delete ? "keypadDelete" : "keypadKey_\(label)")
    }

    private var submitButton: some View {
        Button(action: onSubmit) {
            Image(systemName: SMIcon.next)
                .font(.smBody(24, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(text.isEmpty ? Color.smInk.opacity(0.25) : Color.smTangerine,
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.smPressable)
        .disabled(text.isEmpty)
        .accessibilityIdentifier("keypadSubmit")
    }
}

#Preview {
    KeypadView(text: .constant("42"), onSubmit: {})
        .padding()
        .background(Color.smPaper)
}
