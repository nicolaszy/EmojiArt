//
//  EmojiArtDocumentChooserTest.swift
//  EmojiArtDocumentChooserTest
//
//  Created by Nicolas Kalousek on 07.01.21.
//  Copyright © 2021 fhnw. All rights reserved.
//

import XCTest

class EmojiArtDocumentChooserTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEditName() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        app.buttons["plus"].tap()
        app.buttons["Edit"].tap()
        let element = app.tables.cells.element(boundBy: 0)
        
        element.tap()
        
        let titleInBeginning = "Untitled" // Titel der automatisch gesetzt wird
        print("beginning")
        print(element.label)
        
        for _ in "Untitled"{
            app.keys["Löschen"].tap()
        }
        
        app.keys["T"].tap()

        app.keys["e"].tap()

        app.keys["s"].tap()

        app.keys["t"].tap()
        
        app.buttons["Done"].tap()
        
        print("end")
        print(titleInBeginning)
        print(element.label)
        
        assert(element.label != titleInBeginning)
        
    }
}
