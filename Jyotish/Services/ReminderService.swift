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

struct EngagementNotification: Equatable {
    var identifier: String
    var title: String
    var body: String
    var fireDate: Date
    var destination: AppDestination
    var prompt: String?
}

/// Builds a bounded, replaceable seven-day plan. The plan is pure so timing,
/// personalization, and the iOS notification-budget ceiling can be tested
/// without prompting for system permission.
enum EngagementNotificationPlanner {
    static let identifierPrefix = "jyotish.engagement."

    static func make(family: [FamilyMember],
                     events: [PatroEvent],
                     preferences: EngagementPreferences,
                     language: Language,
                     start: Date = Date(),
                     days: Int = 7,
                     calendar: Calendar = .current) -> [EngagementNotification] {
        guard preferences.enabled, days > 0 else { return [] }
        let count = min(4, max(2, preferences.dailyCount))
        let startDay = calendar.startOfDay(for: start)
        let me = family.first { $0.relation == .selfMember }
        let relatives = family.filter { $0.relation != .selfMember && $0.kundali != nil }
        var output: [EngagementNotification] = []

        for dayOffset in 0..<days {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: startDay) else { continue }
            let hours = momentHours(wakeHour: preferences.wakeHour, count: count)
            for (slot, hour) in hours.enumerated() {
                guard let fireDate = calendar.date(bySettingHour: hour, minute: slot == 0 ? 5 : 0,
                                                   second: 0, of: day), fireDate > start else { continue }
                let content = content(slot: slot, dayOffset: dayOffset, date: day,
                                      me: me, relatives: relatives,
                                      familyInsights: preferences.familyInsights,
                                      language: language)
                output.append(EngagementNotification(
                    identifier: "\(identifierPrefix)\(dateStamp(day, calendar: calendar)).\(slot)",
                    title: content.title, body: content.body, fireDate: fireDate,
                    destination: content.destination, prompt: content.prompt))
            }
        }

        if preferences.calendarReminders {
            output.append(contentsOf: eventNotifications(events: events, language: language,
                                                         start: start, days: days,
                                                         calendar: calendar))
        }
        return Array(output.sorted { $0.fireDate < $1.fireDate }.prefix(56))
    }

    static func momentHours(wakeHour: Int, count: Int) -> [Int] {
        let wake = min(10, max(5, wakeHour))
        let total = min(4, max(2, count))
        let end = 21
        return (0..<total).map { index in
            Int((Double(wake) + Double(index) * Double(end - wake) / Double(total - 1)).rounded())
        }
    }

    private static func content(slot: Int, dayOffset: Int, date: Date,
                                me: FamilyMember?, relatives: [FamilyMember],
                                familyInsights: Bool,
                                language: Language) -> (title: String, body: String, destination: AppDestination, prompt: String?) {
        let ne = language == .ne
        let selfRashi = me?.kundali?.moonRashi ?? .mesh
        let reading = RashifalEngine.generate(rashi: selfRashi, period: .daily, date: date, lang: language)
        switch slot {
        case 0:
            return (ne ? "आजको राशिफल तयार छ" : "Your morning rashifal is ready",
                    firstSentence(reading.text, nepali: ne), .rashifal, nil)
        case 1:
            let starters = Array(PanditStarter.all.prefix(4))
            let starter = starters[dayOffset % starters.count]
            let rashiName = ne ? selfRashi.nameNE : selfRashi.shortEN
            return (starter.title(language: language),
                    ne ? "\(rashiName) राशि र हालको दशाबाट व्यक्तिगत उत्तर हेर्नुहोस्।"
                       : "See the personal answer from your \(rashiName) chart and current dasha.",
                    .pandit, starter.prompt(language: language))
        case 2 where familyInsights && !relatives.isEmpty:
            let relative = relatives[dayOffset % relatives.count]
            let relativeRashi = relative.kundali?.moonRashi ?? .mesh
            let relativeReading = RashifalEngine.generate(rashi: relativeRashi, period: .daily,
                                                          date: date, lang: language)
            let title = ne ? "आज \(relative.name)लाई के चाहिन्छ?" : "What might \(relative.name) need today?"
            let body = firstSentence(relativeReading.text, nepali: ne)
            let prompt = ne
                ? "\(relative.name)को आजको राशिफल र कुण्डली हेरेर परिवारले कसरी सहयोग गर्न सक्छ?"
                : "Using \(relative.name)'s chart and today's rashifal, how can the family support them?"
            return (title, body, .pandit, prompt)
        default:
            return (ne ? "आजको एउटा संकेत बाँकी छ" : "One detail is still worth asking about",
                    reading.panditTeaser, .pandit, reading.panditPrompt)
        }
    }

    private static func eventNotifications(events: [PatroEvent], language: Language,
                                           start: Date, days: Int,
                                           calendar: Calendar) -> [EngagementNotification] {
        let limit = calendar.date(byAdding: .day, value: days, to: start) ?? start
        return events.compactMap { event in
            guard let date = nextDate(for: event, start: start, days: days, calendar: calendar),
                  let previousDay = calendar.date(byAdding: .day, value: -1, to: date),
                  let fireDate = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: previousDay),
                  fireDate > start, fireDate < limit else { return nil }
            return EngagementNotification(
                identifier: "\(identifierPrefix)event.\(event.id.uuidString).\(dateStamp(date, calendar: calendar))",
                title: event.title,
                body: language == .ne ? "भोलिको पात्रो कार्यक्रमका लागि तयारी गर्नुहोस्।" : "Prepare for tomorrow's Patro event.",
                fireDate: fireDate, destination: .patro, prompt: nil)
        }
    }

    private static func nextDate(for event: PatroEvent, start: Date, days: Int,
                                 calendar: Calendar) -> Date? {
        let first = calendar.startOfDay(for: start)
        for offset in 0...days {
            guard let day = calendar.date(byAdding: .day, value: offset, to: first) else { continue }
            if event.occurs(on: BikramSambat.toBS(day)) { return day }
        }
        return nil
    }

    private static func firstSentence(_ text: String, nepali: Bool) -> String {
        let marker: Character = nepali ? "।" : "."
        guard let index = text.firstIndex(of: marker) else { return text }
        return String(text[...index])
    }

    private static func dateStamp(_ date: Date, calendar: Calendar) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d%02d%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }
}

enum EngagementNotificationService {
    static func setEnabled(_ enabled: Bool,
                           family: [FamilyMember], events: [PatroEvent],
                           preferences: EngagementPreferences,
                           language: Language) async throws {
        let center = UNUserNotificationCenter.current()
        if enabled {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            guard granted else { throw ReminderServiceError.permissionDenied }
            try await refresh(family: family, events: events,
                              preferences: preferences, language: language)
        } else {
            let ids = await pendingEngagementIdentifiers(center: center)
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    static func refresh(family: [FamilyMember], events: [PatroEvent],
                        preferences: EngagementPreferences,
                        language: Language) async throws {
        guard preferences.enabled else { return }
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return }
        let previous = await pendingEngagementIdentifiers(center: center)
        center.removePendingNotificationRequests(withIdentifiers: previous)
        for item in EngagementNotificationPlanner.make(family: family, events: events,
                                                       preferences: preferences,
                                                       language: language) {
            let content = UNMutableNotificationContent()
            content.title = item.title
            content.body = item.body
            content.sound = .default
            content.userInfo = ["destination": item.destination.rawValue,
                                "prompt": item.prompt ?? ""]
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],
                                                               from: item.fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            try await center.add(UNNotificationRequest(identifier: item.identifier,
                                                       content: content, trigger: trigger))
        }
    }

    private static func pendingEngagementIdentifiers(center: UNUserNotificationCenter) async -> [String] {
        await center.pendingNotificationRequests()
            .map(\.identifier)
            .filter { $0.hasPrefix(EngagementNotificationPlanner.identifierPrefix) }
    }
}
