import Foundation
import UserNotifications

enum NotificationManager {
    static func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func scheduleDailyReminder(at date: Date) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["mvm_daily_reminder"])

        let content = UNMutableNotificationContent()
        content.title = "MVM Fitness"
        content.body = randomDailyMessage
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "mvm_daily_reminder", content: content, trigger: trigger)

        try? await center.add(request)
    }

    static func removeDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["mvm_daily_reminder"])
    }

    static func scheduleStreakReminder(streak: Int) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["mvm_streak_protect"])

        guard streak >= 3 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Don't Break Your Streak"
        content.body = "You're on a \(streak)-day streak. One workout keeps it alive."
        content.sound = .default

        var components = DateComponents()
        components.hour = 19
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "mvm_streak_protect", content: content, trigger: trigger)

        try? await center.add(request)
    }

    static func scheduleWeeklySummary(workoutsCompleted: Int, streak: Int) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["mvm_weekly_summary"])

        let content = UNMutableNotificationContent()
        content.title = "Weekly Training Report"
        if workoutsCompleted > 0 {
            content.body = "\(workoutsCompleted) workouts this week. \(streak > 0 ? "\(streak)-day streak." : "") Keep building."
        } else {
            content.body = "No workouts logged this week. A fresh start begins today."
        }
        content.sound = .default

        var components = DateComponents()
        components.weekday = 2
        components.hour = 7
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "mvm_weekly_summary", content: content, trigger: trigger)

        try? await center.add(request)
    }

    private static var randomDailyMessage: String {
        let messages = [
            "Me vs Me. Time to train.",
            "Your workout is waiting. Show up.",
            "Discipline beats motivation. Let's go.",
            "The only easy day was yesterday.",
            "PT doesn't do itself. Fall in.",
            "One workout closer to your goal.",
            "Today's the day. Get after it.",
            "Your future self will thank you.",
            "Standards don't lower themselves. Train.",
            "Consistency wins. Time to move."
        ]
        return messages.randomElement() ?? messages[0]
    }
}
