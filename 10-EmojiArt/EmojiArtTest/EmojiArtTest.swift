//
//  EmojiArtTest.swift
//  EmojiArtTest
//
//  Created by Nicolas Kalousek on 07.01.21.
//  Copyright © 2021 fhnw. All rights reserved.
//

import XCTest
@testable import Emoji_Art


class EmojiArtTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAddEmoji_whenTextIsEmpty_doesNothing() throws{
        let emojiArtDocument = Emoji_Art.EmojiArtDocument.init()
        //check if app crashes. it should just do nothing
        emojiArtDocument.addEmoji("", at: CGPoint(x: 10, y: 10), size: 1)
    }
    
    func testAddEmoji_whenTextSizeGreaterThan1_doesNothing() throws{
        let emojiArtDocument = Emoji_Art.EmojiArtDocument.init()
        //check if app crashes. it should just do nothing
        emojiArtDocument.addEmoji("😊", at: CGPoint(x: 10, y: 10), size: 1000)
    }
    
    func testAddEmoji_whenInputValid_incrementsEmojiId() throws{
        //TODO
        let emojiArtDocument = Emoji_Art.EmojiArtDocument.init()
        emojiArtDocument.addEmoji("😊", at: CGPoint(x: 10, y: 10), size: 1000)
        let prevId = emojiArtDocument.emojis.first(where: { $0.text=="😊" })?.id
        emojiArtDocument.addEmoji("😄", at: CGPoint(x: 10, y: 10), size: 1000)
        let thisId = emojiArtDocument.emojis.first(where: { $0.text=="😄" })?.id
        XCTAssertTrue(prevId!+1==thisId!)
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

   

}


