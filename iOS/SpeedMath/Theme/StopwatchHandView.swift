import SwiftUI

/// A sweeping stopwatch hand that spins continuously while `isSpinning` is
/// true (i.e. while a question is being solved) and freezes the instant it
/// becomes false, so the last angle visually marks "time's up".
struct StopwatchHandView: View {
    var isSpinning: Bool
    var size: CGFloat = 72

    var body: some View {
        TimelineView(.animation(paused: !isSpinning)) { context in
            Canvas { ctx, canvasSize in
                let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
                let radius = min(canvasSize.width, canvasSize.height) / 2

                var ring = Path()
                ring.addEllipse(in: CGRect(
                    x: center.x - radius + 3, y: center.y - radius + 3,
                    width: (radius - 3) * 2, height: (radius - 3) * 2))
                ctx.stroke(ring, with: .color(Color.smBrass.opacity(0.5)), lineWidth: 3)

                for i in 0..<12 {
                    let angle = Double(i) / 12 * 2 * .pi
                    let inner = CGPoint(x: center.x + cos(angle) * (radius - 9), y: center.y + sin(angle) * (radius - 9))
                    let outer = CGPoint(x: center.x + cos(angle) * (radius - 4), y: center.y + sin(angle) * (radius - 4))
                    var tick = Path()
                    tick.move(to: inner)
                    tick.addLine(to: outer)
                    ctx.stroke(tick, with: .color(Color.smInk.opacity(0.25)), lineWidth: 2)
                }

                let t = context.date.timeIntervalSinceReferenceDate
                let sweepPeriod = 3.0
                let angle = (t.truncatingRemainder(dividingBy: sweepPeriod)) / sweepPeriod * 2 * .pi - .pi / 2
                let tip = CGPoint(x: center.x + cos(angle) * (radius - 13), y: center.y + sin(angle) * (radius - 13))
                var hand = Path()
                hand.move(to: center)
                hand.addLine(to: tip)
                ctx.stroke(hand, with: .color(Color.smTangerine), style: StrokeStyle(lineWidth: 4, lineCap: .round))

                let hub = CGRect(x: center.x - 4, y: center.y - 4, width: 8, height: 8)
                ctx.fill(Path(ellipseIn: hub), with: .color(Color.smTangerine))
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

#Preview {
    StopwatchHandView(isSpinning: true)
        .padding()
        .background(Color.smPaper)
}
