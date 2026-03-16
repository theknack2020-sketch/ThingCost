import XCTest

final class PaywallScreenshot: XCTestCase {
    func testCapturePaywall() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--reset-onboarding", "--reset-data", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        sleep(2)
        
        // Skip onboarding
        app.buttons["Next"].firstMatch.tap()
        sleep(1)
        app.buttons["Next"].firstMatch.tap()
        sleep(1)
        app.buttons["Add Sample & Start"].tap()
        sleep(2)
        
        // Add 2 more items to hit 3/3 free limit
        for name in ["MacBook Pro", "Nike Air Max"] {
            app.buttons["addButton"].firstMatch.tap()
            sleep(1)
            let nameField = app.textFields.firstMatch
            nameField.tap()
            nameField.typeText(name)
            let fields = app.textFields.allElementsBoundByIndex
            if fields.count > 1 {
                fields[1].tap()
                fields[1].typeText("4999")
            }
            app.navigationBars.buttons.allElementsBoundByIndex.last?.tap()
            sleep(2)
        }
        
        // Now try to add 4th — should show paywall
        app.buttons["addButton"].firstMatch.tap()
        sleep(2)
        
        // Save paywall screenshot
        let screenshot = app.screenshot()
        let data = screenshot.pngRepresentation
        let path = "/Users/ufuk/Desktop/IOS/ThingCost/AppStore/paywall_screenshot.png"
        FileManager.default.createFile(atPath: path, contents: data)
    }
}
