import SwiftUI

/// A flip-clock style display for the current prompt/answer. Uses SwiftUI's
/// built-in numeric content transition for a genuine rolling-digit feel
/// without hand-rolled 3D flap math.
struct FlipDigitView: View {
    var text: String
    var fontSize: CGFloat = 48
    var color: Color = .smInk

    var body: some View {
        Text(text)
            .font(.smDisplay(fontSize))
            .foregroundStyle(color)
            .contentTransition(.numericText())
            .monospacedDigit()
    }
}

#Preview {
    FlipDigitView(text: "42")
        .padding()
        .background(Color.smPaper)
}
