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
        content.body = "Me vs Me. Time to train."
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "mvm_daily_reminder", content: content, trigger: trigger)

        try? await center.add(request)
    }

    static func removeDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["mvm_daily_reminder"])
    }
}
