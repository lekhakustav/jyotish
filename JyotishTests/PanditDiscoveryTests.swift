import XCTest
@testable import Jyotish

final class PanditDiscoveryTests: XCTestCase {
    func testHighInterestQuestionsLeadTheStarterShelf() {
        XCTAssertEqual(PanditStarter.all.prefix(3).map(\.id), ["love", "career", "health"])
        XCTAssertTrue(PanditStarter.all.contains { $0.id == "muhurta" })
        XCTAssertTrue(PanditStarter.all.contains { $0.id == "matching" })
        XCTAssertTrue(PanditStarter.all.contains { $0.id == "dosha" })
        XCTAssertTrue(PanditStarter.all.contains { $0.id == "remedies" })
        XCTAssertTrue(PanditStarter.all.contains { $0.id == "lifePhase" })
    }

    func testRashifalAlwaysGeneratesMatchingPanditInvitation() {
        let date = Date(timeIntervalSince1970: 1_719_792_000)
        let result = RashifalEngine.generate(rashi: .mesh, period: .daily,
                                             date: date, lang: .en, julianDay: 2_460_493.5)

        XCTAssertFalse(result.panditTeaser.isEmpty)
        XCTAssertTrue(result.panditCTA.hasPrefix("Ask Jyotish Baje"))
        XCTAssertTrue(result.panditPrompt.contains("rashifal"))
        XCTAssertTrue(result.panditPrompt.contains("/5"))
    }
}
