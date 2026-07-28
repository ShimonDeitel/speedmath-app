import Foundation
import UserNotifications

/// Local re-engagement reminders — no server, no push infrastructure. Every
/// time the app becomes active it cancels whatever's still pending and lays
/// down a fresh three-notification chain, one per day, with the tone
/// softening each step: friendly nudge, gentler nudge, then a "we'll stop
/// bugging you" goodbye. Nothing is scheduled past that third message, so
/// reminders go silent on their own until the player reopens the app — which
/// immediately reschedules the chain and starts the cycle over.
enum ReminderScheduler {
    private static let center = UNUserNotificationCenter.current()
    private static let identifiers = ["reminder.day1", "reminder.day2", "reminder.day3"]

    private static var isUITesting: Bool {
        CommandLine.arguments.contains("-uitest")
    }

    static func requestAuthorizationIfNeeded() {
        guard !isUITesting else { return }
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        }
    }

    /// Call whenever the app becomes active (cold launch or foregrounding).
    static func rescheduleOnAppOpen(level: Int) {
        guard !isUITesting else { return }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                schedule(level: level)
            }
        }
    }

    private static func schedule(level: Int) {
        let messages: [(title: String, body: String)] = [
            ("Ready for another round?",
             "You're at level \(level) — a few quick questions keeps it sharp."),
            ("Still there?",
             "Your level \(level) streak is waiting. A couple of minutes is all it takes."),
            ("We'll stop bugging you",
             "No pressure — come back whenever you're ready. We'll be here."),
        ]
        for (index, identifier) in identifiers.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = messages[index].title
            content.body = messages[index].body
            content.sound = .default

            let daysOut = Double(index + 1)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60 * 60 * 24 * daysOut, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            center.add(request)
        }
    }
}
