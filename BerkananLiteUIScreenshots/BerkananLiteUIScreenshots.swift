//
//  Created by Zsombor Szabo on 05/01/2020.
//  Copyright © 2020 IZE. All rights reserved.
//

import XCTest

class BerkananLiteUIScreenshots: XCTestCase {
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testScreenshots() {
    // UI tests must launch the application that they test.
    let app = XCUIApplication()
    setupSnapshot(app)
    app.launch()
    
    // Bug workaround to skip swiping keyboard tutorial by iOS
    app.textFields.firstMatch.tap()
    app.buttons["gear"].tap()
    app.buttons["chevron.down"].tap()
                            
    var screenshotNumber = 1
    app.textFields.firstMatch.tap()
    snapshot(String(format: "%02d", screenshotNumber))
    screenshotNumber += 1
    
    app.buttons["gear"].tap()
    snapshot(String(format: "%02d", screenshotNumber))
    screenshotNumber += 1
  }
}
