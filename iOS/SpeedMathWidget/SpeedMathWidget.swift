import WidgetKit
import SwiftUI

/// Small home-screen widget: current level, streak, and today's goal
/// progress — a light nudge to open the app, not a second place to answer
/// questions. Data comes from `SharedStatsBridge`, written by the host app's
/// `StatsStore` into the App Group; the widget only ever reads it.
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> StatsEntry {
        StatsEntry(snapshot: WidgetStatsSnapshot(
            level: 47, maxLevel: 1500, gradeLabel: "Grade 5",
            currentStreak: 5, answeredToday: 8, dailyGoal: 20))
    }

    func getSnapshot(in context: Context, completion: @escaping (StatsEntry) -> Void) {
        completion(StatsEntry(snapshot: SharedStatsBridge.read() ?? placeholder(in: context).snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StatsEntry>) -> Void) {
        let snapshot = SharedStatsBridge.read() ?? placeholder(in: context).snapshot
        // A single entry — the host app calls WidgetCenter.reloadAllTimelines()
        // itself every time stats change, so there's nothing to schedule here.
        completion(Timeline(entries: [StatsEntry(snapshot: snapshot)], policy: .never))
    }
}

struct StatsEntry: TimelineEntry {
    let date = Date()
    let snapshot: WidgetStatsSnapshot
}

struct SpeedMathWidgetEntryView: View {
    var entry: Provider.Entry

    private let paper = Color(red: 0xF7 / 255, green: 0xF1 / 255, blue: 0xE1 / 255)
    private let ink = Color(red: 0x1B / 255, green: 0x2A / 255, blue: 0x4A / 255)
    private let tangerine = Color(red: 0xFF / 255, green: 0x6B / 255, blue: 0x35 / 255)

    private var goalProgress: Double {
        guard entry.snapshot.dailyGoal > 0 else { return 0 }
        return min(1, Double(entry.snapshot.answeredToday) / Double(entry.snapshot.dailyGoal))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(tangerine)
                Text("SPEEDMATH")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(ink)
            }

            Text(entry.snapshot.gradeLabel)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(ink.opacity(0.6))
            Text("Level \(entry.snapshot.level)")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(ink)

            Spacer(minLength: 2)

            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(tangerine)
                Text("\(entry.snapshot.currentStreak) streak")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(ink.opacity(0.6))
            }

            ProgressView(value: goalProgress)
                .tint(tangerine)
            Text("\(entry.snapshot.answeredToday)/\(entry.snapshot.dailyGoal) today")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(ink.opacity(0.6))
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) { paper }
    }
}

struct SpeedMathWidget: Widget {
    let kind = "SpeedMathWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SpeedMathWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("SpeedMath Progress")
        .description("Your current level, streak, and today's goal.")
        .supportedFamilies([.systemSmall])
    }
}

@main
struct SpeedMathWidgetBundle: WidgetBundle {
    var body: some Widget {
        SpeedMathWidget()
    }
}
