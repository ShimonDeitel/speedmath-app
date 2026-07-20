import SwiftUI
import Observation

/// Retro Stopwatch palette. Every color has a fixed value in both appearances —
/// the app is intentionally light-only (cream paper reads wrong inverted).
/// The accent (tangerine by default) is user-selectable via `ThemeManager`;
/// everything else in the palette is fixed.
extension Color {
    static let smPaper = Color(red: 0xF7 / 255, green: 0xF1 / 255, blue: 0xE1 / 255)
    static let smPaperDeep = Color(red: 0xEF / 255, green: 0xE6 / 255, blue: 0xCE / 255)
    static let smInk = Color(red: 0x1B / 255, green: 0x2A / 255, blue: 0x4A / 255)
    static let smInkMuted = Color(red: 0x1B / 255, green: 0x2A / 255, blue: 0x4A / 255).opacity(0.58)
    @MainActor static var smTangerine: Color { ThemeManager.shared.palette.base }
    @MainActor static var smTangerineDeep: Color { ThemeManager.shared.palette.deep }
    static let smBrass = Color(red: 0xD9 / 255, green: 0xA4 / 255, blue: 0x41 / 255)
    static let smCorrect = Color(red: 0x2E / 255, green: 0x7D / 255, blue: 0x5B / 255)
    static let smWrong = Color(red: 0xC0 / 255, green: 0x39 / 255, blue: 0x2B / 255)
}

/// A selectable accent palette. `base`/`deep` replace `Color.smTangerine`/
/// `smTangerineDeep` app-wide the instant the selection changes, since those
/// are computed properties reading `ThemeManager.shared`.
enum AccentPalette: String, Codable, CaseIterable, Identifiable {
    case tangerine, sky, berry, violet

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .tangerine: return "Tangerine"
        case .sky: return "Sky"
        case .berry: return "Berry"
        case .violet: return "Violet"
        }
    }

    var base: Color {
        switch self {
        case .tangerine: return Color(red: 0xFF / 255, green: 0x6B / 255, blue: 0x35 / 255)
        case .sky: return Color(red: 0x2F / 255, green: 0x80 / 255, blue: 0xC4 / 255)
        case .berry: return Color(red: 0xC4 / 255, green: 0x35 / 255, blue: 0x6B / 255)
        case .violet: return Color(red: 0x7C / 255, green: 0x5C / 255, blue: 0xC4 / 255)
        }
    }

    var deep: Color {
        switch self {
        case .tangerine: return Color(red: 0xE0 / 255, green: 0x55 / 255, blue: 0x22 / 255)
        case .sky: return Color(red: 0x23 / 255, green: 0x5F / 255, blue: 0x94 / 255)
        case .berry: return Color(red: 0x96 / 255, green: 0x28 / 255, blue: 0x4F / 255)
        case .violet: return Color(red: 0x5C / 255, green: 0x43 / 255, blue: 0x94 / 255)
        }
    }
}

/// A small set of vector avatar marks — no emoji, per the app's design rules.
enum AvatarIcon: String, Codable, CaseIterable, Identifiable {
    case stopwatch, star, bolt, flame, graduationCap, target

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .stopwatch: return "stopwatch.fill"
        case .star: return "star.fill"
        case .bolt: return "bolt.fill"
        case .flame: return "flame.fill"
        case .graduationCap: return "graduationcap.fill"
        case .target: return "scope"
        }
    }
}

/// Holds the user's chosen accent palette. A plain `@Observable` singleton
/// (not threaded through the environment) so `Color.smTangerine` can stay a
/// simple static var that every existing call site already uses unchanged —
/// SwiftUI's Observation tracking picks up the dependency wherever it's read
/// during a view body, singleton or not.
@Observable
@MainActor
final class ThemeManager {
    static let shared = ThemeManager()
    private static let key = "com.deitel.speedmath.accentPalette"

    var palette: AccentPalette {
        didSet { UserDefaults.standard.set(palette.rawValue, forKey: Self.key) }
    }

    private init() {
        if let raw = UserDefaults.standard.string(forKey: Self.key),
           let saved = AccentPalette(rawValue: raw) {
            palette = saved
        } else {
            palette = .tangerine
        }
    }
}

extension Font {
    /// Heavy condensed numerals for the flip-clock display. Falls back to the
    /// system font's condensed width — no bundled font dependency.
    static func smDisplay(_ size: CGFloat) -> Font {
        .system(size: size, weight: .black, design: .rounded).width(.condensed)
    }

    static func smBody(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

enum SMSpacing {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 12
    static let md: CGFloat = 20
    static let lg: CGFloat = 32
    static let xl: CGFloat = 48
}

struct SMCardBackground: ViewModifier {
    var color: Color = .white.opacity(0.6)
    func body(content: Content) -> some View {
        content
            .background(color, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.smInk.opacity(0.08), lineWidth: 1))
    }
}

extension View {
    func smCard(color: Color = .white.opacity(0.6)) -> some View {
        modifier(SMCardBackground(color: color))
    }
}

/// A gentle scale-down on press, matching the portfolio's pressable button feel.
struct SMPressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == SMPressableButtonStyle {
    static var smPressable: SMPressableButtonStyle { SMPressableButtonStyle() }
}

/// Vector-only iconography — no emojis anywhere in this app (owner ground rule).
enum SMIcon {
    static let start = "play.fill"
    static let profile = "person.crop.circle"
    static let settings = "gearshape.fill"
    static let type = "keyboard.fill"
    static let speed = "waveform"
    static let correct = "checkmark.circle.fill"
    static let wrong = "xmark.circle.fill"
    static let streak = "flame.fill"
    static let explain = "sparkles"
    static let lock = "lock.fill"
    static let close = "xmark"
    static let mic = "mic.fill"
    static let next = "arrow.right.circle.fill"
    static let stats = "chart.bar.fill"
    static let clock = "stopwatch"
    static let sound = "speaker.wave.2.fill"
    static let haptics = "iphone.radiowaves.left.and.right"
    static let goal = "flag.checkered"
    static let celebrate = "sparkle"
    static let palette = "paintpalette.fill"
    static let avatar = "person.crop.circle.fill"
}

/// The brand glyph: a stopwatch — ring, crown, and a sweeping hand — drawn as
/// stroked paths so it scales cleanly from app icon to inline wordmark.
struct StopwatchGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let inset = rect.width * 0.10
        let bodyRect = rect.insetBy(dx: inset, dy: inset * 1.6)
        p.addEllipse(in: bodyRect)
        let crownWidth = rect.width * 0.16
        let crownRect = CGRect(
            x: rect.midX - crownWidth / 2,
            y: rect.minY,
            width: crownWidth,
            height: rect.height * 0.12)
        p.addRoundedRect(in: crownRect, cornerSize: CGSize(width: 3, height: 3))
        p.move(to: CGPoint(x: rect.midX, y: bodyRect.midY))
        p.addLine(to: CGPoint(x: rect.midX + bodyRect.width * 0.28, y: bodyRect.midY - bodyRect.height * 0.22))
        return p
    }
}

struct SMWordmark: View {
    var color: Color = .smTangerine
    var size: CGFloat = 22

    var body: some View {
        HStack(spacing: size * 0.32) {
            StopwatchGlyph()
                .stroke(color, style: StrokeStyle(lineWidth: size * 0.11, lineCap: .round, lineJoin: .round))
                .frame(width: size, height: size)
            Text("SPEEDMATH")
                .font(.smDisplay(size * 0.72))
                .kerning(size * 0.03)
                .foregroundStyle(Color.smInk)
        }
        .accessibilityLabel("SpeedMath")
    }
}
