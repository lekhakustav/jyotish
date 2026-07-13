import XCTest
@testable import Jyotish

final class PanditToolsTests: XCTestCase {
    func testAnswerContractKeepsBriefRepliesAndAddsAnOptInQuestion() {
        XCTAssertTrue(PanditAnswerContract.isSatisfied(
            by: "A good date is Monday. Light a lamp.", language: .en))
        XCTAssertEqual(
            PanditAnswerContract.completed("A good date is Monday.", fallback: "Fallback", language: .en),
            "A good date is Monday.\n\nWould you like me to connect this with your dasha or an auspicious time?")
        XCTAssertTrue(PanditAnswerContract.completed("हुन्छ।", fallback: "Fallback", language: .ne)
            .contains("के तपाईं"))
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
        XCTAssertEqual(reading!.factors.count, 8)
        XCTAssertEqual(reading!.factors.reduce(0) { $0 + $1.maximum }, 36, accuracy: 0.001)
        XCTAssertEqual(reading!.factors.reduce(0) { $0 + $1.score }, reading!.gunaScore, accuracy: 0.001)
        XCTAssertTrue((0...36).contains(reading!.gunaScore))
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

        XCTAssertTrue(PanditStarter.all.contains { $0.id == "muhurta" })
        XCTAssertEqual(plan.intent, .muhurta)
        XCTAssertEqual(plan.evidence.first?.tool, "find_muhurta.requirements")
        XCTAssertFalse(plan.actions.contains { $0.kind == .addToPatro })
        XCTAssertTrue(plan.answer.contains("choose what you are planning"))
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
        XCTAssertTrue(plan.answer.contains("/36"))
        XCTAssertTrue(plan.answer.contains("Nadi"))
    }

    func testRelationshipInsightUsesBothChartsAndProvidesDosAndDonts() {
        var me = FamilyMember(name: "Sita", gender: .female, relation: .selfMember,
                              birth: BirthData(year: 1962, month: 3, day: 15,
                                               hour: 7, minute: 30, timeKnown: true,
                                               place: .kathmandu))
        var friend = FamilyMember(name: "Maya", gender: .female, relation: .friend,
                                  birth: BirthData(year: 1965, month: 8, day: 11,
                                                   hour: 9, minute: 5, timeKnown: true,
                                                   place: .kathmandu))
        me.recompute()
        friend.recompute()

        let insight = CompatibilityEngine.dailyInsight(me, friend,
                                                        date: Date(timeIntervalSince1970: 1_783_440_000),
                                                        language: .en)

        XCTAssertNotNil(insight)
        XCTAssertTrue(insight!.title.contains("Maya"))
        XCTAssertFalse(insight!.doItem.isEmpty)
        XCTAssertFalse(insight!.dontItem.isEmpty)
        XCTAssertTrue(insight!.prompt.contains("Maya's kundli"))
    }

    func testDoshaAndRemedyPlansUseDeterministicChartEvidence() {
        var me = FamilyMember(name: "Sita", gender: .female, relation: .selfMember,
                              birth: BirthData(year: 1962, month: 3, day: 15,
                                               hour: 7, minute: 30, timeKnown: true,
                                               place: .kathmandu))
        me.recompute()

        let dosha = PanditToolPlanner.plan(query: "Check Mangal Dosha and Sade Sati",
                                           family: [me], events: [], language: .en,
                                           now: Date(timeIntervalSince1970: 1_783_440_000))
        let remedy = PanditToolPlanner.plan(query: "Give me remedies, mantra, donation and gemstone guidance",
                                            family: [me], events: [], language: .en)

        XCTAssertEqual(dosha.intent, .dosha)
        XCTAssertEqual(dosha.evidence.first?.tool, "analyze_dosha")
        XCTAssertEqual(remedy.intent, .remedy)
        XCTAssertEqual(remedy.evidence.first?.tool, "get_remedies")
        XCTAssertTrue(remedy.answer.contains("Gemstone"))
        XCTAssertTrue(remedy.answer.contains("Daan"))
    }

    func testPanchangaDayDetailsProduceOrderedLocationBasedWindows() {
        let date = Date(timeIntervalSince1970: 1_783_440_000)
        let details = PanchangaDayCalculator.details(for: date, place: .kathmandu, language: .en)

        XCTAssertLessThan(details.sunrise, details.sunset)
        XCTAssertLessThan(details.rahuKaal.start, details.rahuKaal.end)
        XCTAssertGreaterThanOrEqual(details.rahuKaal.start, details.sunrise)
        XCTAssertLessThanOrEqual(details.rahuKaal.end, details.sunset)
        XCTAssertLessThan(details.abhijitMuhurat.start, details.abhijitMuhurat.end)
        XCTAssertTrue(details.moonTimesAreApproximate)
    }

    func testEveryRashifalHorizonHasActionableDosAndDonts() {
        for period in RashifalPeriod.allCases {
            let reading = RashifalEngine.generate(rashi: .mithun, period: period,
                                                  date: Date(timeIntervalSince1970: 1_783_440_000),
                                                  lang: .en)
            XCTAssertEqual(reading.dos.count, 2)
            XCTAssertEqual(reading.donts.count, 2)
            XCTAssertTrue(reading.dos.allSatisfy { !$0.isEmpty })
            XCTAssertTrue(reading.donts.allSatisfy { !$0.isEmpty })
        }
    }

    func testParivarShareCodeRoundTripsBirthProfile() throws {
        let member = FamilyMember(name: "Maya", gender: .female, relation: .friend,
                                  birth: BirthData(year: 1991, month: 8, day: 11,
                                                   hour: 9, minute: 5, timeKnown: true,
                                                   place: .kathmandu))

        let payload = try FamilySharePayload(member: member)
        let decoded = try FamilySharePayload.decode(payload.encodedString())

        XCTAssertEqual(decoded, payload)
        XCTAssertEqual(decoded.name, "Maya")
        XCTAssertEqual(decoded.birth.place.name, BirthPlace.kathmandu.name)
    }

    func testNepaliModeTransliteratesLatinNamesWithoutChangingStoredIdentity() {
        let aarav = FamilyMember(name: "Aarav", gender: .male, relation: .friend)
        let priya = FamilyMember(name: "Priya", gender: .female, relation: .friend)
        let native = FamilyMember(name: "माया", gender: .female, relation: .friend)

        XCTAssertEqual(aarav.displayName(.ne), "आरव")
        XCTAssertEqual(priya.displayName(.ne), "प्रिया")
        XCTAssertEqual(native.displayName(.ne), "माया")
        XCTAssertEqual(aarav.displayName(.en), "Aarav")
        XCTAssertEqual(aarav.name, "Aarav")
    }

    func testRashifalShubhTimingMatchesEachHorizon() {
        let date = Date(timeIntervalSince1970: 1_783_440_000)
        let daily = RashifalEngine.generate(rashi: .mithun, period: .daily, date: date, lang: .en)
        let weekly = RashifalEngine.generate(rashi: .mithun, period: .weekly, date: date, lang: .en)
        let monthly = RashifalEngine.generate(rashi: .mithun, period: .monthly, date: date, lang: .en)
        let yearly = RashifalEngine.generate(rashi: .mithun, period: .yearly, date: date, lang: .en)

        XCTAssertTrue(daily.luckyDay.contains(":"))
        XCTAssertFalse(weekly.luckyDay.contains("month"))
        XCTAssertTrue(monthly.luckyDay.lowercased().contains("month") || monthly.luckyDay.lowercased().contains("days"))
        XCTAssertTrue(yearly.luckyDay.lowercased().contains("months"))
        XCTAssertEqual(L10n.t("rashifal.shubh.time", .ne), "शुभ समय")
        XCTAssertEqual(L10n.t("rashifal.shubh.period", .ne), "शुभ अवधि")
    }
}
