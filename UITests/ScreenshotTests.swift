import XCTest

final class ScreenshotTests: XCTestCase {
    var app: XCUIApplication!
    let screenshotDir = "/Users/ufuk/Desktop/IOS/ThingCost/AppStore/screenshots"
    
    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        
        // Create screenshot directory
        try? FileManager.default.createDirectory(atPath: screenshotDir, withIntermediateDirectories: true)
    }

    func testGenerateENScreenshots() throws {
        app.launchArguments = ["--reset-onboarding", "--reset-data", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        sleep(2)
        
        // 1: Onboarding
        save("en_01_onboarding")
        
        // Complete onboarding
        app.buttons["Next"].firstMatch.tap()
        sleep(1)
        app.buttons["Next"].firstMatch.tap()
        sleep(1)
        app.buttons["Add Sample & Start"].tap()
        sleep(2)
        
        // Add more items
        addItem(name: "MacBook Pro", price: "84999")
        addItem(name: "Nike Air Max", price: "4999")
        
        // 2: Item List (3 items)
        save("en_02_itemList")
        
        // 3: Detail View (iPhone — 180 days old, interesting stats)
        app.staticTexts["iPhone"].tap()
        sleep(1)
        save("en_03_detail")
        
        // 4: Share Card (Bold)
        app.navigationBars.buttons["square.and.arrow.up"].firstMatch.tap()
        sleep(1)
        save("en_04_shareCard")
        
        app.buttons["Done"].tap()
        sleep(1)
        app.navigationBars.buttons.element(boundBy: 0).tap()
        sleep(1)
        
        // 5: Settings
        app.buttons["settingsButton"].firstMatch.tap()
        sleep(1)
        save("en_05_settings")
    }

    func testGenerateTRScreenshots() throws {
        app.launchArguments = ["--reset-onboarding", "--reset-data", "-AppleLanguages", "(tr)", "-AppleLocale", "tr_TR"]
        app.launch()
        sleep(2)
        
        // 1: Onboarding TR
        save("tr_01_onboarding")
        
        // Complete onboarding
        app.buttons["İleri"].firstMatch.tap()
        sleep(1)
        app.buttons["İleri"].firstMatch.tap()
        sleep(1)
        app.buttons["Örnek Ekle ve Başla"].tap()
        sleep(2)
        
        // Add items
        addItem(name: "MacBook Pro", price: "84999")
        addItem(name: "Nike Air Max", price: "4999")
        
        // 2: Item List TR
        save("tr_02_itemList")
        
        // 3: Detail TR
        app.staticTexts["iPhone"].tap()
        sleep(1)
        save("tr_03_detail")
        
        // 4: Share Card TR
        app.navigationBars.buttons["square.and.arrow.up"].firstMatch.tap()
        sleep(1)
        save("tr_04_shareCard")
    }
    
    // MARK: - Helpers
    
    private func addItem(name: String, price: String) {
        app.buttons["addButton"].firstMatch.tap()
        sleep(1)
        
        // Name field — first text field in the form
        let nameField = app.textFields.firstMatch
        nameField.tap()
        nameField.typeText(name)
        
        // Price field — use keyboard dismiss + find second field
        // Scroll to find price field
        let allFields = app.textFields.allElementsBoundByIndex
        if allFields.count > 1 {
            allFields[1].tap()
            allFields[1].typeText(price)
        }
        
        // Tap confirmation button (rightmost in nav bar = Add/Ekle)
        let navButtons = app.navigationBars.buttons.allElementsBoundByIndex
        navButtons.last?.tap()
        sleep(2)
    }
    
    private func save(_ name: String) {
        let screenshot = app.screenshot()
        let data = screenshot.pngRepresentation
        let path = "\(screenshotDir)/\(name).png"
        FileManager.default.createFile(atPath: path, contents: data)
    }
}
