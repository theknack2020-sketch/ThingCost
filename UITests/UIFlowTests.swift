import XCTest

final class UIFlowTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--reset-onboarding", "--reset-data", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
    }

    func testCompleteUserFlow() throws {
        // === STEP 1: ONBOARDING - Page 1 Welcome ===
        XCTAssertTrue(app.staticTexts["ThingCost"].waitForExistence(timeout: 5), "Should show app name")

        app.buttons["Next"].firstMatch.tap()
        sleep(1)

        // === STEP 2: ONBOARDING - Page 2 How it works ===
        XCTAssertTrue(app.staticTexts["Add a purchase"].waitForExistence(timeout: 3), "Page 2 steps")

        app.buttons["Next"].firstMatch.tap()
        sleep(1)

        // === STEP 3: ONBOARDING - Page 3 Get started ===
        XCTAssertTrue(app.staticTexts["Ready to start?"].waitForExistence(timeout: 3), "Page 3 ready")

        app.buttons["Add Sample & Start"].tap()
        sleep(2)

        // === STEP 4: ITEM LIST - Should have sample item ===
        XCTAssertTrue(app.navigationBars["ThingCost"].waitForExistence(timeout: 5), "Main list nav bar")
        XCTAssertTrue(app.staticTexts["iPhone"].waitForExistence(timeout: 3), "Sample iPhone item")
        XCTAssertTrue(app.staticTexts["1/3 free"].exists, "Free counter at 1")

        // === STEP 5: ADD ITEM ===
        app.buttons["addButton"].firstMatch.tap() // + button (rightmost)
        sleep(1)

        XCTAssertTrue(app.navigationBars["Add Item"].waitForExistence(timeout: 3), "Add sheet")

        let nameField = app.textFields["Name"]
        nameField.tap()
        nameField.typeText("MacBook Pro")

        let priceField = app.textFields["Price"]
        priceField.tap()
        priceField.typeText("84999")

        // Should show preview
        XCTAssertTrue(app.staticTexts["Daily Cost"].waitForExistence(timeout: 2), "Live preview")

        // Tap the toolbar Add button (confirmation action)
        app.navigationBars["Add Item"].buttons["Add"].tap()
        sleep(2)

        // === STEP 6: VERIFY 2 ITEMS ===
        XCTAssertTrue(app.staticTexts["MacBook Pro"].waitForExistence(timeout: 3), "New item in list")
        XCTAssertTrue(app.staticTexts["2/3 free"].exists, "Counter at 2")

        // === STEP 7: TAP FOR DETAIL ===
        app.staticTexts["MacBook Pro"].tap()
        sleep(1)

        XCTAssertTrue(app.staticTexts["per day"].waitForExistence(timeout: 3), "Detail daily cost")
        XCTAssertTrue(app.staticTexts["Cost Breakdown"].exists, "Cost breakdown section")
        XCTAssertTrue(app.staticTexts["Cost Over Time"].exists, "Chart section")
        XCTAssertTrue(app.staticTexts["Future Projections"].exists, "Projections section")

        // === STEP 8: SHARE CARD ===
        app.navigationBars.buttons["square.and.arrow.up"].firstMatch.tap()
        sleep(1)

        XCTAssertTrue(app.navigationBars["Share Card"].waitForExistence(timeout: 3), "Share card sheet")

        // Check style picker segments exist
        XCTAssertTrue(app.buttons["Minimal"].exists, "Minimal style")
        XCTAssertTrue(app.buttons["Bold"].exists, "Bold style")
        XCTAssertTrue(app.buttons["Gradient"].exists, "Gradient style")

        // Switch styles
        app.buttons["Minimal"].tap()
        Thread.sleep(forTimeInterval: 0.5)
        app.buttons["Gradient"].tap()
        Thread.sleep(forTimeInterval: 0.5)

        // Dismiss
        app.buttons["Done"].tap()
        sleep(1)

        // === STEP 9: EDIT ITEM ===
        app.navigationBars.buttons["Edit"].tap()
        sleep(1)

        XCTAssertTrue(app.navigationBars["Edit Item"].waitForExistence(timeout: 3), "Edit sheet")

        // Change name
        let editNameField = app.textFields["Name"]
        editNameField.tap()
        editNameField.clearAndEnterText("MacBook Pro M4")

        app.navigationBars["Edit Item"].buttons["Save"].tap()
        sleep(1)

        // Verify name changed in detail
        XCTAssertTrue(app.navigationBars["MacBook Pro M4"].waitForExistence(timeout: 3), "Updated name in nav")

        // === STEP 10: GO BACK TO LIST ===
        app.navigationBars.buttons.element(boundBy: 0).tap()
        sleep(1)

        // === STEP 11: ADD 3rd ITEM ===
        app.buttons["addButton"].firstMatch.tap()
        sleep(1)

        let nameField3 = app.textFields["Name"]
        nameField3.tap()
        nameField3.typeText("Nike Shoes")

        let priceField3 = app.textFields["Price"]
        priceField3.tap()
        priceField3.typeText("4999")

        app.navigationBars["Add Item"].buttons["Add"].tap()
        sleep(2)

        XCTAssertTrue(app.staticTexts["3/3 free"].waitForExistence(timeout: 3), "Counter at 3")

        // === STEP 12: PAYWALL (4th item) ===
        app.buttons["addButton"].firstMatch.tap()
        sleep(1)

        XCTAssertTrue(app.staticTexts["Unlock Unlimited Items"].waitForExistence(timeout: 3), "Paywall shown")

        // Feature list visible
        XCTAssertTrue(app.staticTexts["Unlimited items"].exists, "Paywall feature: unlimited")
        XCTAssertTrue(app.staticTexts["Support indie development"].exists, "Paywall feature: support")

        // Dismiss paywall
        app.buttons["Cancel"].tap()
        sleep(1)

        // === STEP 13: SORT MENU ===
        app.buttons["sortButton"].firstMatch.tap()
        sleep(1)

        let sortOption = app.buttons["Name A-Z"]
        XCTAssertTrue(sortOption.waitForExistence(timeout: 3), "Sort options menu")
        sortOption.tap()
        sleep(1)

        // === STEP 14: DELETE ITEM ===
        let nikeCell = app.staticTexts["Nike Shoes"]
        XCTAssertTrue(nikeCell.exists, "Nike exists before delete")
        nikeCell.swipeLeft()
        Thread.sleep(forTimeInterval: 0.5)

        if app.buttons["Delete"].waitForExistence(timeout: 2) {
            app.buttons["Delete"].tap()
            sleep(1)
        }

        XCTAssertFalse(app.staticTexts["Nike Shoes"].exists, "Nike deleted")
        XCTAssertTrue(app.staticTexts["2/3 free"].waitForExistence(timeout: 3), "Counter back to 2")

        // === STEP 15: SETTINGS ===
        app.buttons["settingsButton"].firstMatch.tap()
        sleep(1)

        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3), "Settings sheet")

        // Appearance section
        XCTAssertTrue(app.staticTexts["Theme"].exists, "Theme setting")

        // Purchase section
        XCTAssertTrue(app.staticTexts["Unlock Unlimited Items"].exists, "Unlock button in settings")

        // Purchases section
        XCTAssertTrue(app.buttons["Restore Purchases"].exists, "Restore in settings")

        // Legal section
        XCTAssertTrue(app.buttons["Privacy Policy"].exists, "Privacy Policy link")
        XCTAssertTrue(app.buttons["Terms of Use"].exists, "Terms of Use link")
        XCTAssertTrue(app.buttons["Contact Us"].exists, "Contact Us link")

        // About section
        XCTAssertTrue(app.staticTexts["1.0.0"].exists, "Version number")

        // Dismiss settings
        app.buttons["Done"].tap()
        sleep(1)
    }
}

// Helper to clear text field before typing
extension XCUIElement {
    func clearAndEnterText(_ text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear non-string value")
            return
        }
        
        self.tap()
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
        self.typeText(text)
    }
}
