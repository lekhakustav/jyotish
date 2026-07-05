import XCTest
@testable import Jyotish

final class AppNavigationTests: XCTestCase {
    func testPrimaryTabsKeepPatroAndPanditOutOfBottomNavigation() {
        XCTAssertEqual(AppTab.allCases, [.home, .rashifal, .family])
        XCTAssertFalse(AppTab.allCases.contains { $0.destination == .patro })
        XCTAssertFalse(AppTab.allCases.contains { $0.destination == .pandit })
    }

    func testHiddenDestinationsRemainReachableFromHomeAndRashifal() {
        XCTAssertEqual(AppDestination.patro.presentationStyle, .pushed)
        XCTAssertEqual(AppDestination.pandit.presentationStyle, .modal)
    }
}
