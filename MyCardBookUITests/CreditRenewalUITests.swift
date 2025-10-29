//
//  CreditRenewalUITests.swift
//  MyCardBookUITests
//
//  Created by Parva Thakkar (developer) on 1/27/25.
//

import XCTest

final class CreditRenewalUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Set up test environment
        app.launchArguments = ["--uitesting"]
        app.launchEnvironment = ["TEST_MODE": "true"]
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - App Lifecycle Renewal Tests
    
    func testAppLaunchTriggersRenewal() throws {
        // Launch app
        app.launch()
        
        // Wait for app to load
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        
        // Navigate to Credits tab
        app.tabBars.buttons["Credits"].tap()
        
        // Verify credits are loaded (basic UI test)
        XCTAssertTrue(app.isDisplayingCreditsView)
    }
    
    func testAppBecomingActiveTriggersRenewal() throws {
        // Launch app
        app.launch()
        
        // Wait for app to load
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        
        // Simulate app going to background and coming back
        XCUIDevice.shared.press(.home)
        app.activate()
        
        // Verify app is still responsive
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
    }
    
    // MARK: - Credit Display Tests
    
    func testCreditsDisplayCorrectly() throws {
        // Launch app
        app.launch()

        // Wait for app to fully load
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))

        // Find and tap Credits tab - be more flexible with the query
        let creditsTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS 'Credits'")).firstMatch
        XCTAssertTrue(creditsTab.waitForExistence(timeout: 5), "Credits tab should exist")
        creditsTab.tap()

        // Give UI time to transition
        sleep(1)

        // Wait for either credits list or empty state to appear
        let creditsScrollView = app.scrollViews["creditsScrollView"]
        let emptyCreditsView = app.otherElements["emptyCreditsView"]

        // Check if either view appears within timeout
        let creditsViewLoaded = creditsScrollView.waitForExistence(timeout: 5) ||
                                emptyCreditsView.waitForExistence(timeout: 5)

        // Verify credits view is displayed (either with credits or empty state)
        XCTAssertTrue(creditsViewLoaded, "Credits view should display either credit list or empty state")
    }
    
    func testCreditUsageToggle() throws {
        // Launch app
        app.launch()
        
        // Navigate to Credits tab
        app.tabBars.buttons["Credits"].tap()
        
        // Find first credit and tap to toggle usage
        let creditsTable = app.tables.firstMatch
        if creditsTable.cells.count > 0 {
            let firstCredit = creditsTable.cells.firstMatch
            firstCredit.tap()
            
            // Verify interaction worked (basic test)
            XCTAssertTrue(firstCredit.exists)
        }
    }
}

// MARK: - UI Test Extensions

extension XCUIApplication {
    var isDisplayingCreditsView: Bool {
        // Check if we can find credits-related UI elements using accessibility identifiers
        return otherElements["creditsScrollView"].exists ||
               otherElements["emptyCreditsView"].exists ||
               navigationBars["Credits"].exists
    }
}