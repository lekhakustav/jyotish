import XCTest
@testable import Jyotish

final class EngagementNotificationTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    func testMomentHoursRespectWakeTimeAndStayBounded() {
        XCTAssertEqual(EngagementNotificationPlanner.momentHours(wakeHour: 7, count: 4), [7, 12, 16, 21])
        XCTAssertEqual(EngagementNotificationPlanner.momentHours(wakeHour: 2, count: 8), [5, 10, 16, 21])
    }

    func testSevenDayPlanIsUniqueBoundedAndFamilyPersonalized() {
        let start = calendar.date(from: DateComponents(year: 2026, month: 7, day: 11, hour: 4))!
        var me = FamilyMember(name: "Sita", gender: .female, relation: .selfMember,
                              birth: BirthData(year: 1962, month: 3, day: 15, hour: 7, minute: 30,
                                               timeKnown: true, place: .kathmandu))
        me.recompute()
        var son = FamilyMember(name: "Aarav", gender: .male, relation: .son,
                               birth: BirthData(year: 1990, month: 6, day: 15, hour: 8, minute: 30,
                                                timeKnown: true, place: .kathmandu))
        son.recompute()
        let preferences = EngagementPreferences(enabled: true, wakeHour: 7, dailyCount: 4,
                                                familyInsights: true, calendarReminders: false)

        let plan = EngagementNotificationPlanner.make(family: [me, son], events: [],
                                                      preferences: preferences, language: .en,
                                                      start: start, days: 7, calendar: calendar)

        XCTAssertEqual(plan.count, 28)
        XCTAssertEqual(Set(plan.map(\.identifier)).count, plan.count)
        XCTAssertLessThanOrEqual(plan.count, 56)
        XCTAssertTrue(plan.contains { $0.title.contains("Aarav") && $0.destination == .pandit })
        XCTAssertTrue(plan.allSatisfy { $0.fireDate > start })
    }

    func testDisabledPreferencesProduceNoNotifications() {
        let plan = EngagementNotificationPlanner.make(family: [], events: [],
                                                      preferences: EngagementPreferences(),
                                                      language: .en)
        XCTAssertTrue(plan.isEmpty)
    }
}
