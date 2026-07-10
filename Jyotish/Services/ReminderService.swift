import Foundation
import UserNotifications

enum ReminderServiceError: LocalizedError {
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Notification permission is required to set a reminder."
        }
    }
}

/// Resolves Pandit actions into app-owned values before any side effect occurs.
/// The UI always confirms the title and date first; this type keeps conversion
/// and scheduling deterministic and independently testable.
enum PanditActionResolver {
    static func event(title: String, date: Date) -> PatroEvent {
        PatroEvent(title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                   note: "Added with Pandit-ji",
                   bsDate: BikramSambat.toBS(date))
    }

    static func reminderFireDate(for date: Date, now: Date = Date(), calendar: Calendar = .current) -> Date {
        let start = calendar.startOfDay(for: date)
        if let previousEvening = calendar.date(byAdding: .day, value: -1, to: start),
           let atSix = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: previousEvening),
           atSix > now.addingTimeInterval(60) {
            return atSix
        }
        return max(date, now.addingTimeInterval(60))
    }
}

enum ReminderService {
    static func schedule(title: String, date: Date, language: Language) async throws {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .sound])
        guard granted else { throw ReminderServiceError.permissionDenied }

        let fireDate = PanditActionResolver.reminderFireDate(for: date)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = language == .ne
            ? "पण्डितजीले सम्झाउनुभएको समय नजिकिँदै छ।"
            : "The time Pandit-ji helped you plan is approaching."
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],
                                                           from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        try await center.add(UNNotificationRequest(identifier: UUID().uuidString,
                                                   content: content,
                                                   trigger: trigger))
    }
}
