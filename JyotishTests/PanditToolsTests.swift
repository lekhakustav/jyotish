import XCTest
@testable import Jyotish

final class PanditToolsTests: XCTestCase {
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
}
