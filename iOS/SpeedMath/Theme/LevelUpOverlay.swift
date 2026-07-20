import SwiftUI

/// A brief celebratory card shown right after a level-up. The caller owns
/// the timing — this view just renders; `SessionView` shows it for a couple
/// of seconds and clears `StatsStore.justLeveledUp` itself.
struct LevelUpOverlay: View {
    let level: Int
    var body: some View {
        VStack(spacing: SMSpacing.sm) {
            ZStack {
                Circle()
                    .fill(Color.smTangerine.opacity(0.15))
                    .frame(width: 120, height: 120)
                StopwatchGlyph()
                    .stroke(Color.smTangerine, style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                    .frame(width: 64, height: 64)
                Image(systemName: SMIcon.celebrate)
                    .font(.smBody(20, weight: .bold))
                    .foregroundStyle(Color.smBrass)
                    .offset(x: 40, y: -40)
            }
            Text("Level Up!")
                .font(.smDisplay(26))
                .foregroundStyle(Color.smInk)
            Text(GradeMap.gradeLabel(for: level))
                .font(.smBody(15, weight: .semibold))
                .foregroundStyle(Color.smTangerine)
        }
        .padding(SMSpacing.lg)
        .background(Color.smPaper, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.smInk.opacity(0.08), lineWidth: 1))
        .shadow(color: Color.smInk.opacity(0.18), radius: 24, y: 12)
        .accessibilityIdentifier("levelUpOverlay")
        .accessibilityLabel("Level up! Now \(GradeMap.gradeLabel(for: level))")
    }
}

#Preview {
    LevelUpOverlay(level: 21)
        .padding()
        .background(Color.smPaperDeep)
}
