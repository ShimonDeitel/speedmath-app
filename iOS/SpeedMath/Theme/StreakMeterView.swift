import SwiftUI

struct StreakMeterView: View {
    var streak: Int
    var cap: Int = 10

    @State private var milestoneBounce = false

    var body: some View {
        HStack(spacing: SMSpacing.xs) {
            Image(systemName: SMIcon.streak)
                .foregroundStyle(streak > 0 ? Color.smTangerine : Color.smInkMuted)
                .font(.smBody(14, weight: .semibold))
                .scaleEffect(milestoneBounce ? 1.5 : 1)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.smInk.opacity(0.08))
                    Capsule()
                        .fill(Color.smTangerine)
                        .frame(width: geo.size.width * min(CGFloat(streak), CGFloat(cap)) / CGFloat(cap))
                }
            }
            .frame(height: 8)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: streak)

            Text("\(streak)")
                .font(.smBody(13, weight: .bold))
                .foregroundStyle(Color.smInk)
                .frame(minWidth: 20, alignment: .trailing)
        }
        .accessibilityIdentifier("streakMeter")
        .onChange(of: streak) { _, newValue in
            guard newValue > 0, newValue % 5 == 0 else { return }
            withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) { milestoneBounce = true }
            Task {
                try? await Task.sleep(for: .milliseconds(220))
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { milestoneBounce = false }
            }
        }
    }
}

#Preview {
    StreakMeterView(streak: 4)
        .padding()
        .background(Color.smPaper)
}
