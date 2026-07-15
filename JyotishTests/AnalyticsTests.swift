import XCTest
@testable import Jyotish

final class AnalyticsTests: XCTestCase {
    func testAnalyticsPersistsOfflineBeforeAnyRemoteUpload() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("jyotish-analytics-\(UUID().uuidString)", isDirectory: true)
        let analytics = AppAnalytics(baseDirectory: directory)
        let event = AnalyticsEvent(name: "feature_opened", sessionID: UUID(), installID: UUID(),
                                   properties: ["feature": "kundli_matching"])

        await analytics.recordForTesting(event)

        let queuedCount = await analytics.queuedCountForTesting()
        XCTAssertEqual(queuedCount, 1)
        let logURL = await analytics.localLogURLForTesting()
        let log = try String(contentsOf: logURL, encoding: .utf8)
        XCTAssertTrue(log.contains("feature_opened"))
        XCTAssertTrue(log.contains("kundli_matching"))
        try? FileManager.default.removeItem(at: directory)
    }
}
