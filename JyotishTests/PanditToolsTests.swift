import XCTest
@testable import Jyotish

final class PanditToolsTests: XCTestCase {
    func testAnswerContractRejectsStaleUnstructuredBackendReplies() {
        XCTAssertFalse(PanditAnswerContract.isSatisfied(
            by: "A good date is Monday. Light a lamp.", language: .en))
        XCTAssertTrue(PanditAnswerContract.isSatisfied(
            by: "Direct answer\nYes\nWhy Baje says this\nEvidence\nWhat to do\nPlan\nOptional practice\nA lamp",
            language: .en))
        XCTAssertTrue(PanditAnswerContract.isSatisfied(
            by: "सीधा उत्तर\nहुन्छ\nबाजेले यसो भन्नुको कारण\nआधार\nअब के गर्ने\nकाम\nवैकल्पिक साधना\nदीप",
            language: .ne))
    }
    func testAgentActionConvertsConfirmedDateAndAvoidsImmediateReminder() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 8, day: 15))!
        let event = PanditActionResolver.event(title: "  Griha Pravesh  ", date: date)
        XCTAssertEqual(event.title, "Griha Pravesh")
        XCTAssertEqual(event.bsDate, BikramSambat.toBS(date))

        let now = Calendar.current.date(from: DateComponents(year: 2026, month: 8, day: 10, hour: 9))!
        let fire = PanditActionResolver.reminderFireDate(for: date, now: now)
        XCTAssertEqual(Calendar.current.component(.hour, from: fire), 18)
        XCTAssertEqual(Calendar.current.dateComponents([.day], from: now, to: fire).day, 4)
    }
    func testMuhurtaFinderReturnsRankedPanchangaEvidence() {
        let start = Date(timeIntervalSince1970: 1_783_440_000)
        let results = MuhurtaEngine.find(purpose: .grihaPravesh,
                                         from: start,
                                         days: 30,
                                         place: .kathmandu,
                                         language: .ne)

        XCTAssertEqual(results.count, 3)
        XCTAssertGreaterThanOrEqual(results[0].score, results[1].score)
        XCTAssertGreaterThanOrEqual(results[1].score, results[2].score)
        XCTAssertTrue(results.allSatisfy { !$0.reasons.isEmpty })
        XCTAssertTrue(results.allSatisfy { $0.purpose == .grihaPravesh })
        XCTAssertTrue(results.flatMap(\.reasons).allSatisfy { !$0.contains("(panchanga") && !$0.contains("(weekday)") })
    }

    func testCompatibilityUsesVisibleChartFactorsAndStaysBounded() {
        var first = FamilyMember(name: "Sita", gender: .female, relation: .selfMember,
                                 birth: BirthData(year: 1962, month: 3, day: 15,
                                                  hour: 7, minute: 30, timeKnown: true,
                                                  place: .kathmandu))
        var second = FamilyMember(name: "Hari", gender: .male, relation: .husband,
                                  birth: BirthData(year: 1960, month: 9, day: 2,
                                                   hour: 6, minute: 0, timeKnown: false,
                                                   place: .kathmandu))
        first.recompute()
        second.recompute()

        let reading = CompatibilityEngine.compare(first, second, language: .en)

        XCTAssertNotNil(reading)
        XCTAssertTrue((0...100).contains(reading!.score))
        XCTAssertFalse(reading!.summary.isEmpty)
        XCTAssertNotNil(reading!.uncertainty)
    }

    func testDevotionalKnowledgeExplainsEkadashiWithoutFearOrCommerce() {
        let panchanga = Panchanga(tithiIndex: 10,
                                  nakshatra: .rohini,
                                  yogaIndex: 4,
                                  karanaIndex: 0,
                                  weekday: 2,
                                  moonRashi: .vrish)
        let guidance = DevotionalKnowledge.guidance(for: panchanga, language: .ne)

        XCTAssertEqual(guidance.title, "एकादशी व्रत")
        XCTAssertTrue(guidance.practice.contains("स्वास्थ्यअनुसार"))
        XCTAssertFalse(guidance.practice.contains("किन्नुहोस्"))
    }

    func testPanchangaCacheSeparatesPlaces() {
        Panchanga.resetCacheForTesting()
        let date = Date(timeIntervalSince1970: 1_783_440_000)

        _ = Panchanga.forDay(date, place: .kathmandu)
        _ = Panchanga.forDay(date, place: BirthPlace.presets.first { $0.name == "London, UK" }!)

        XCTAssertEqual(Panchanga.cacheSnapshotForTesting.entries, 2)
    }

    func testPlannerRoutesMuhuratThroughDeterministicEvidenceAndActions() {
        var me = FamilyMember(name: "Sita", gender: .female, relation: .selfMember,
                              birth: BirthData(year: 1962, month: 3, day: 15,
                                               hour: 7, minute: 30, timeKnown: true,
                                               place: .kathmandu))
        me.recompute()

        let plan = PanditToolPlanner.plan(query: "When is a good date for griha pravesh?",
                                          family: [me],
                                          events: [],
                                          language: .en,
                                          now: Date(timeIntervalSince1970: 1_783_440_000))

        XCTAssertEqual(plan.intent, .muhurta)
        XCTAssertEqual(plan.evidence.first?.tool, "find_muhurta")
        XCTAssertTrue(plan.actions.contains { $0.kind == .addToPatro && $0.date != nil })
        XCTAssertTrue(plan.actions.contains { $0.kind == .remind && $0.date != nil })
        XCTAssertTrue(plan.answer.contains("**Direct answer**"))
        XCTAssertTrue(plan.answer.contains("**Why Baje says this**"))
        XCTAssertTrue(plan.answer.contains("**What to do**"))
        XCTAssertTrue(plan.answer.contains("**Optional practice**"))
        XCTAssertTrue(plan.answer.contains("**Uncertainty**"))
    }

    func testFriendlyShubhTimeStarterStillCallsMuhurtaTool() {
        let starter = PanditStarter.all.first { $0.id == "muhurta" }!
        let plan = PanditToolPlanner.plan(query: starter.prompt(language: .en),
                                          family: [],
                                          events: [],
                                          language: .en,
                                          now: Date(timeIntervalSince1970: 1_783_440_000))

        XCTAssertEqual(PanditStarter.all.count, 3)
        XCTAssertEqual(plan.intent, .muhurta)
        XCTAssertEqual(plan.evidence.first?.tool, "find_muhurta")
        XCTAssertTrue(plan.actions.contains { $0.kind == .addToPatro })
    }

    func testPlannerBuildsCompatibilityFromTwoFamilyCharts() {
        var first = FamilyMember(name: "Aarav", gender: .male, relation: .son,
                                 birth: BirthData(year: 1990, month: 6, day: 15,
                                                  hour: 8, minute: 30, timeKnown: true,
                                                  place: .kathmandu))
        var second = FamilyMember(name: "Priya", gender: .female, relation: .daughter,
                                  birth: BirthData(year: 1993, month: 11, day: 2,
                                                   hour: 14, minute: 10, timeKnown: true,
                                                   place: .kathmandu))
        first.recompute()
        second.recompute()

        let plan = PanditToolPlanner.plan(query: "Compare Aarav and Priya compatibility",
                                          family: [first, second],
                                          events: [],
                                          language: .en)

        XCTAssertEqual(plan.intent, .compatibility)
        XCTAssertEqual(plan.evidence.first?.tool, "compare_kundli")
        XCTAssertTrue(plan.actions.contains { $0.kind == .compare })
        XCTAssertTrue(plan.answer.contains("Aarav + Priya"))
    }
}
