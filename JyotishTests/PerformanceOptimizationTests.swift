import XCTest
@testable import Jyotish

final class PerformanceOptimizationTests: XCTestCase {
    func testRashifalResultsAreCachedByDatePeriodRashiAndLanguage() {
        RashifalEngine.resetCacheForTesting()
        let date = Date(timeIntervalSince1970: 1_783_440_000)

        let first = RashifalEngine.generate(rashi: .mesh, period: .daily, date: date, lang: .en)
        let afterFirst = RashifalEngine.cacheSnapshotForTesting
        let second = RashifalEngine.generate(rashi: .mesh, period: .daily, date: date, lang: .en)
        let afterSecond = RashifalEngine.cacheSnapshotForTesting

        XCTAssertEqual(first.text, second.text)
        XCTAssertEqual(afterFirst.entries, 1)
        XCTAssertEqual(afterFirst.misses, 1)
        XCTAssertEqual(afterSecond.entries, 1)
        XCTAssertEqual(afterSecond.hits, 1)
    }

    func testRashifalStarsAreTransitBasedBoundedAndNeverAllPerfect() {
        RashifalEngine.resetCacheForTesting()
        let date = Date(timeIntervalSince1970: 1_783_440_000)

        for rashi in Rashi.allCases {
            let result = RashifalEngine.generate(rashi: rashi, period: .daily, date: date, lang: .en)
            XCTAssertEqual(Set(result.scores.keys), Set(RashifalEngine.domains))
            XCTAssertTrue(result.scores.values.allSatisfy { (1...5).contains($0) })
            XCTAssertFalse(result.scores.values.allSatisfy { $0 == 5 }, "\(rashi) should not show five perfect domains")
        }
    }

    func testPanchangaDayResultsAreCached() {
        Panchanga.resetCacheForTesting()
        let date = Date(timeIntervalSince1970: 1_783_440_000)

        let first = Panchanga.forDay(date)
        let afterFirst = Panchanga.cacheSnapshotForTesting
        let second = Panchanga.forDay(date)
        let afterSecond = Panchanga.cacheSnapshotForTesting

        XCTAssertEqual(first.tithiIndex, second.tithiIndex)
        XCTAssertEqual(first.nakshatra, second.nakshatra)
        XCTAssertEqual(afterFirst.entries, 1)
        XCTAssertEqual(afterFirst.misses, 1)
        XCTAssertEqual(afterSecond.hits, 1)
    }

    func testPanchangaYogaAndKaranaRespectNepaliLanguage() {
        let panchanga = Panchanga(tithiIndex: 6,
                                  nakshatra: .ashwini,
                                  yogaIndex: 4,
                                  karanaIndex: 0,
                                  weekday: 1,
                                  moonRashi: .mesh)

        XCTAssertEqual(panchanga.yogaName(ne: false), "Shobhana")
        XCTAssertEqual(panchanga.yogaName(ne: true), "शोभन")
        XCTAssertEqual(panchanga.karanaName(ne: false), "Bava")
        XCTAssertEqual(panchanga.karanaName(ne: true), "बव")
    }

    func testAgentContextGenerationKeepsHistoryBoundedAndScalesAcrossFamily() {
        RashifalEngine.resetCacheForTesting()
        let family = (0..<24).map { index -> FamilyMember in
            var member = FamilyMember(name: "Member \(index)",
                                      gender: index.isMultiple(of: 2) ? .female : .male,
                                      relation: index == 0 ? .selfMember : .cousin,
                                      birth: BirthData(year: 1970 + index,
                                                       month: index % 12 + 1,
                                                       day: index % 27 + 1,
                                                       hour: 6,
                                                       minute: 30,
                                                       timeKnown: true,
                                                       place: .kathmandu))
            member.recompute()
            return member
        }
        let chat = (0..<40).map { ChatMessage(isUser: $0.isMultiple(of: 2), text: "Message \($0)") }

        let request = AgentChatRequest.make(message: "How is everyone today?",
                                            localFallbackReply: "Namaste.",
                                            family: family,
                                            events: [],
                                            chat: chat,
                                            language: .en,
                                            selfMember: family.first)

        XCTAssertEqual(request.family.count, 24)
        XCTAssertEqual(request.chatHistory.count, 16)
        XCTAssertGreaterThan(RashifalEngine.cacheSnapshotForTesting.entries, 0)
        XCTAssertLessThanOrEqual(RashifalEngine.cacheSnapshotForTesting.entries, Rashi.allCases.count)
    }

    func testConfiguredURLCacheHasRoomForTempleImages() {
        AppRuntime.configureCaches()

        XCTAssertGreaterThanOrEqual(URLCache.shared.memoryCapacity, 64 * 1024 * 1024)
        XCTAssertGreaterThanOrEqual(URLCache.shared.diskCapacity, 256 * 1024 * 1024)
    }

    func testPanditMarkdownFormattingRemovesRawEmphasisMarkers() {
        let formatted = PanditTextFormatter.attributed("**Direct answer:** हल्का हरियो शुभ छ।")

        XCTAssertEqual(String(formatted.characters), "Direct answer: हल्का हरियो शुभ छ।")
        XCTAssertFalse(String(formatted.characters).contains("**"))
    }
}
