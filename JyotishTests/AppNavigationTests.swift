import XCTest
@testable import Jyotish

final class AppNavigationTests: XCTestCase {
    func testPrimaryTabsKeepPatroAndPanditOutOfBottomNavigation() {
        XCTAssertEqual(AppTab.allCases, [.family, .rashifal, .home])
        XCTAssertFalse(AppTab.allCases.contains { $0.destination == .patro })
        XCTAssertFalse(AppTab.allCases.contains { $0.destination == .pandit })
    }

    func testKundliSharingIsTheDefaultFirstTab() {
        XCTAssertEqual(AppTab.fromLaunchIndex(0), .family)
        XCTAssertEqual(AppTab.fromLaunchIndex(1), .rashifal)
        XCTAssertEqual(AppTab.fromLaunchIndex(2), .home)
        XCTAssertEqual(AppTab.fromLaunchIndex(3), .family)
    }

    func testHiddenDestinationsRemainReachableFromHomeAndRashifal() {
        XCTAssertEqual(AppDestination.patro.presentationStyle, .pushed)
        XCTAssertEqual(AppDestination.pandit.presentationStyle, .modal)
    }
}
