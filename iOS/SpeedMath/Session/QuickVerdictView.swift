import SwiftUI

/// Speed mode's post-answer beat: just a correct/incorrect mark, no steps
/// and no "Next" button — a tap would break the speed flow, so the caller
/// auto-advances after a brief pause instead.
struct QuickVerdictView: View {
    let correct: Bool
    @State private var pop = false

    var body: some View {
        VStack {
            Spacer()
            Image(systemName: correct ? SMIcon.correct : SMIcon.wrong)
                .font(.system(size: 108, weight: .bold))
                .foregroundStyle(correct ? Color.smCorrect : Color.smWrong)
                .scaleEffect(pop ? 1 : 0.5)
                .opacity(pop ? 1 : 0)
                .accessibilityIdentifier(correct ? "verdictCorrect" : "verdictWrong")
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { pop = true }
        }
    }
}

#Preview {
    QuickVerdictView(correct: true)
        .background(Color.smPaper)
}
