import XCTest
@testable import Jyotish

final class ChatConversationTests: XCTestCase {
    func testConversationAppendUpdatesMessagesAndTimestamp() {
        let start = Date(timeIntervalSince1970: 1_000)
        let replyDate = Date(timeIntervalSince1970: 2_000)
        var conversation = ChatConversation(title: "Career", createdAt: start, updatedAt: start)
        let reply = ChatMessage(isUser: false, text: "A focused answer", timestamp: replyDate)

        conversation.append(reply)

        XCTAssertEqual(conversation.messages, [reply])
        XCTAssertEqual(conversation.updatedAt, replyDate)
    }

    func testSchemaOneHouseholdWithoutConversationsStillDecodes() throws {
        let json = #"{"schemaVersion":1,"family":[],"events":[],"chat":[],"language":"en","theme":"system"}"#

        let household = try JSONDecoder().decode(Household.self, from: Data(json.utf8))

        XCTAssertNil(household.conversations)
        XCTAssertEqual(household.schemaVersion, 1)
    }
}
