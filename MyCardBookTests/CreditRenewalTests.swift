//
//  CreditRenewalTests.swift
//  MyCardBookTests
//
//  Created by Parva Thakkar (developer) on 1/27/25.
//

import Testing
import CoreData
@testable import MyCardBook

struct CreditRenewalTests {

    // Shared persistence controller for all tests to keep context alive
    static let testPersistenceController = PersistenceController(inMemory: true)

    // MARK: - Basic Renewal Logic Tests
    
    @Test("Monthly credit should renew on calendar boundaries")
    func testMonthlyRenewal() async throws {
        let calendar = Calendar.current

        // Test case: Credit from January period, check in February
        let jan1 = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!

        let creditEntity = createTestCreditEntity(
            frequency: "Monthly",
            renewalDate: jan1,  // Period start: Jan 1
            isUsed: true,
            usedAt: jan1
        )

        // Test that shouldRenew works correctly (we're now in October, different period than Jan)
        let shouldRenew = creditEntity.shouldRenew()
        #expect(shouldRenew == true)

        // Test renewal
        creditEntity.renew()
        #expect(creditEntity.isUsed == false)
        #expect(creditEntity.usedAt == nil)
    }
    
    @Test("Quarterly credit should renew at quarter boundaries")
    func testQuarterlyRenewal() async throws {
        let calendar = Calendar.current

        // Test case: Credit from Q1 (Jan-Mar), check in Q2 (Apr-Jun)
        let jan1 = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!  // Q1 start

        let creditEntity = createTestCreditEntity(
            frequency: "Quarterly",
            renewalDate: jan1,  // Period start: Q1 (Jan 1)
            isUsed: true,
            usedAt: jan1
        )

        let shouldRenew = creditEntity.shouldRenew()
        #expect(shouldRenew == true)

        creditEntity.renew()
        #expect(creditEntity.isUsed == false)
    }
    
    @Test("Semi-annual credit should renew at half-year boundaries")
    func testSemiAnnualRenewal() async throws {
        let calendar = Calendar.current

        // Test case: Credit from Jul-Dec 2024 period, check in Jan 2025
        let jul1_2024 = calendar.date(from: DateComponents(year: 2024, month: 7, day: 1))!

        let creditEntity = createTestCreditEntity(
            frequency: "Semi-annual",
            renewalDate: jul1_2024,  // Period start: Jul 1
            isUsed: true,
            usedAt: jul1_2024
        )

        let shouldRenew = creditEntity.shouldRenew()
        #expect(shouldRenew == true)

        creditEntity.renew()
        #expect(creditEntity.isUsed == false)
    }
    
    @Test("Annual credit should renew on January 1st")
    func testAnnualRenewal() async throws {
        let calendar = Calendar.current

        // Test case: Credit from 2024, check in 2025
        let jan1_2024 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!

        let creditEntity = createTestCreditEntity(
            frequency: "Annual",
            renewalDate: jan1_2024,  // Period start: Jan 1, 2024
            isUsed: true,
            usedAt: jan1_2024
        )

        let shouldRenew = creditEntity.shouldRenew()
        #expect(shouldRenew == true)

        creditEntity.renew()
        #expect(creditEntity.isUsed == false)
    }
    
    // MARK: - Edge Cases
    
    @Test("Manual credits (Per Stay, Every 4 Years) do not auto-renew")
    func testManualCreditsDoNotRenew() async throws {
        let calendar = Calendar.current
        let jan1 = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        
        // Test Per Stay credit
        let perStayCredit = createTestCreditEntity(
            frequency: "Per Stay",
            renewalDate: calendar.date(from: DateComponents(year: 2024, month: 12, day: 31))!,
            isUsed: true,
            usedAt: calendar.date(from: DateComponents(year: 2024, month: 12, day: 31))!
        )
        
        let shouldRenewPerStay = perStayCredit.shouldRenew()
        #expect(shouldRenewPerStay == false)
        
        // Test Every 4 Years credit
        let every4YearsCredit = createTestCreditEntity(
            frequency: "Every 4 Years",
            renewalDate: calendar.date(from: DateComponents(year: 2024, month: 12, day: 31))!,
            isUsed: true,
            usedAt: calendar.date(from: DateComponents(year: 2024, month: 12, day: 31))!
        )
        
        let shouldRenewEvery4Years = every4YearsCredit.shouldRenew()
        #expect(shouldRenewEvery4Years == false)
    }
    
    @Test("Unused credits SHOULD renew when crossing period boundaries")
    func testUnusedCreditsRenewAcrossPeriods() async throws {
        let calendar = Calendar.current

        // Test case: Credit was never used but we're now in a different period
        // The credit should renew to show current period dates
        let dec1_2024 = calendar.date(from: DateComponents(year: 2024, month: 12, day: 1))!  // Period start: Dec 1

        let creditEntity = createTestCreditEntity(
            frequency: "Monthly",
            renewalDate: dec1_2024,  // December 2024
            isUsed: false,  // Never used
            usedAt: nil
        )

        // We're now in a different period (current date is in 2025)
        // Unused credits SHOULD renew to reflect the current period
        let shouldRenew = creditEntity.shouldRenew()
        #expect(shouldRenew == true)

        // After renewal, credit should be available for the current period
        creditEntity.renew()
        #expect(creditEntity.isUsed == false)
        #expect(creditEntity.usedAt == nil)

        // Dates should be updated to current period (calculated dynamically based on current date)
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.nanosecond = 0
        let currentPeriodStart = calendar.date(from: components)!
        let timeDiff = abs(creditEntity.renewalDate!.timeIntervalSince(currentPeriodStart))
        #expect(timeDiff < 1.0, "Renewal date should be within 1 second of current period start")
    }
    
    @Test("Credits do not renew within the same period")
    func testNoRenewalWithinSamePeriod() async throws {
        let calendar = Calendar.current
        
        // Test with a credit that was renewed recently (within current period)
        // This test verifies that credits don't renew multiple times within the same period
        let currentDate = Date()
        let creditEntity = createTestCreditEntity(
            frequency: "Monthly",
            renewalDate: currentDate,
            isUsed: true,
            usedAt: currentDate
        )
        
        // Since the credit was just renewed (renewalDate = currentDate), 
        // it should not need renewal again
        let shouldRenew = creditEntity.shouldRenew()
        #expect(shouldRenew == false)
    }
    
    @Test("Usage tracking works correctly")
    func testUsageTracking() async throws {
        let creditEntity = createTestCreditEntity(
            frequency: "Monthly",
            renewalDate: Date(),
            isUsed: false,
            usedAt: nil
        )
        
        // Initially unused
        #expect(creditEntity.isUsed == false)
        #expect(creditEntity.usedAt == nil)
        
        // Mark as used
        creditEntity.markAsUsed()
        #expect(creditEntity.isUsed == true)
        #expect(creditEntity.usedAt != nil)
        
        // Mark as unused
        creditEntity.markAsUnused()
        #expect(creditEntity.isUsed == false)
        #expect(creditEntity.usedAt == nil)
        
        // Toggle usage
        creditEntity.toggleUsage()
        #expect(creditEntity.isUsed == true)
        
        creditEntity.toggleUsage()
        #expect(creditEntity.isUsed == false)
    }
    
    // MARK: - Comprehensive Scenario Tests

    @Test("Semi-annual credit NOT used till Dec 31, shows correctly on Jan 1")
    func testSemiAnnualUnusedCreditRenewsOnJan1() async throws {
        let calendar = Calendar.current

        // Scenario: User has a semi-annual credit, didn't use it in Jul-Dec 2024 period
        // When we check now (any date after Dec 31, 2024), it should renew to current period
        let creditEntity = createTestCreditEntity(
            frequency: "Semi-annual",
            renewalDate: calendar.date(from: DateComponents(year: 2024, month: 7, day: 1))!,  // Jul 1, 2024 start
            isUsed: false,  // NOT used in Jul-Dec period
            usedAt: nil
        )

        // Set expiration to end of Dec 2024
        creditEntity.expirationDate = calendar.date(from: DateComponents(year: 2024, month: 12, day: 31, hour: 23, minute: 59, second: 59))!

        // Check if renewal needed (we're now in a different period)
        let shouldRenew = creditEntity.shouldRenew()
        #expect(shouldRenew == true, "Credit should renew when period changes, regardless of usage")

        // After renewal
        creditEntity.renew()
        #expect(creditEntity.isUsed == false, "Credit should be available")
        #expect(creditEntity.usedAt == nil, "No usage timestamp")

        // Verify dates are for current semi-annual period (calculated dynamically)
        let now = Date()
        let month = calendar.component(.month, from: now)
        let year = calendar.component(.year, from: now)
        let expectedMonth = month <= 6 ? 1 : 7  // Jan-Jun or Jul-Dec
        let expectedStart = calendar.date(from: DateComponents(year: year, month: expectedMonth, day: 1))!
        let timeDiff = abs(creditEntity.renewalDate!.timeIntervalSince(expectedStart))
        #expect(timeDiff < 1.0, "Renewal date should be within 1 second of current semi-annual period start")
    }

    @Test("Semi-annual credit USED on Dec 31, renews correctly on Jan 1")
    func testSemiAnnualUsedCreditRenewsOnJan1() async throws {
        let calendar = Calendar.current

        // Scenario: User used semi-annual credit on Dec 31, 2024
        // When we check now (any date after Dec 31), it should reset and be available for current period
        let dec31 = calendar.date(from: DateComponents(year: 2024, month: 12, day: 31))!

        let creditEntity = createTestCreditEntity(
            frequency: "Semi-annual",
            renewalDate: calendar.date(from: DateComponents(year: 2024, month: 7, day: 1))!,  // Jul 1, 2024 start
            isUsed: true,  // USED on Dec 31
            usedAt: dec31
        )

        creditEntity.expirationDate = calendar.date(from: DateComponents(year: 2024, month: 12, day: 31, hour: 23, minute: 59, second: 59))!

        // Check if renewal needed
        let shouldRenew = creditEntity.shouldRenew()
        #expect(shouldRenew == true, "Credit should renew when period changes")

        // After renewal
        creditEntity.renew()
        #expect(creditEntity.isUsed == false, "Credit should reset to available")
        #expect(creditEntity.usedAt == nil, "Usage timestamp should be cleared")

        // Verify dates are for current semi-annual period (calculated dynamically)
        let now = Date()
        let month = calendar.component(.month, from: now)
        let year = calendar.component(.year, from: now)
        let expectedMonth = month <= 6 ? 1 : 7  // Jan-Jun or Jul-Dec
        let expectedStart = calendar.date(from: DateComponents(year: year, month: expectedMonth, day: 1))!
        let timeDiff = abs(creditEntity.renewalDate!.timeIntervalSince(expectedStart))
        #expect(timeDiff < 1.0, "Renewal date should be within 1 second of current semi-annual period start")
    }

    @Test("Monthly credit unused in January, renews correctly on Feb 1")
    func testMonthlyUnusedCreditRenewsOnFeb1() async throws {
        let calendar = Calendar.current

        // Scenario: Monthly credit not used in January, when we check now (later month), it should renew
        let creditEntity = createTestCreditEntity(
            frequency: "Monthly",
            renewalDate: calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!,
            isUsed: false,  // NOT used in January
            usedAt: nil
        )

        creditEntity.expirationDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 31, hour: 23, minute: 59, second: 59))!

        // Check if renewal needed (we're now in a different month)
        let shouldRenew = creditEntity.shouldRenew()
        #expect(shouldRenew == true, "Monthly credit should renew when we're in a different month")

        creditEntity.renew()
        #expect(creditEntity.isUsed == false, "Credit should be available for current month")

        // Verify date is for current month (calculated dynamically)
        var components = calendar.dateComponents([.year, .month], from: Date())
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.nanosecond = 0
        let currentMonthStart = calendar.date(from: components)!
        let timeDiff = abs(creditEntity.renewalDate!.timeIntervalSince(currentMonthStart))
        #expect(timeDiff < 1.0, "Should be within 1 second of current month start")
    }

    @Test("Quarterly credit used in Q4, renews correctly in Q1")
    func testQuarterlyUsedCreditRenewsInQ1() async throws {
        let calendar = Calendar.current

        // Scenario: Quarterly credit used in Q4 2024 (Oct-Dec), when we check now (later quarter), it should renew
        let dec15 = calendar.date(from: DateComponents(year: 2024, month: 12, day: 15))!

        let creditEntity = createTestCreditEntity(
            frequency: "Quarterly",
            renewalDate: calendar.date(from: DateComponents(year: 2024, month: 10, day: 1))!,  // Q4 2024 start
            isUsed: true,
            usedAt: dec15
        )

        creditEntity.expirationDate = calendar.date(from: DateComponents(year: 2024, month: 12, day: 31, hour: 23, minute: 59, second: 59))!

        // Check if renewal needed (we're now in a different quarter)
        let shouldRenew = creditEntity.shouldRenew()
        #expect(shouldRenew == true, "Quarterly credit should renew when we're in a different quarter")

        creditEntity.renew()
        #expect(creditEntity.isUsed == false, "Credit should be available for current quarter")

        // Verify date is for current quarter (calculated dynamically)
        let now = Date()
        let month = calendar.component(.month, from: now)
        let year = calendar.component(.year, from: now)
        let quarterStartMonth = 1 + ((month - 1) / 3) * 3  // Jan, Apr, Jul, or Oct
        let currentQuarterStart = calendar.date(from: DateComponents(year: year, month: quarterStartMonth, day: 1))!
        let timeDiff = abs(creditEntity.renewalDate!.timeIntervalSince(currentQuarterStart))
        #expect(timeDiff < 1.0, "Should be within 1 second of current quarter start")
    }

    @Test("Annual credit unused in 2024, renews correctly in 2025")
    func testAnnualUnusedCreditRenewsIn2025() async throws {
        let calendar = Calendar.current

        // Scenario: Annual credit not used in 2024, when we check now (2025), it should renew
        let creditEntity = createTestCreditEntity(
            frequency: "Annual",
            renewalDate: calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!,
            isUsed: false,  // NOT used in 2024
            usedAt: nil
        )

        creditEntity.expirationDate = calendar.date(from: DateComponents(year: 2024, month: 12, day: 31, hour: 23, minute: 59, second: 59))!

        // Check if renewal needed (we're now in a different year)
        let shouldRenew = creditEntity.shouldRenew()
        #expect(shouldRenew == true, "Annual credit should renew when we're in a different year")

        creditEntity.renew()
        #expect(creditEntity.isUsed == false, "Credit should be available for current year")

        // Verify date is for current year (Jan 1 of current year, calculated dynamically)
        let now = Date()
        let year = calendar.component(.year, from: now)
        let currentYearStart = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let timeDiff = abs(creditEntity.renewalDate!.timeIntervalSince(currentYearStart))
        #expect(timeDiff < 1.0, "Should be within 1 second of Jan 1 of current year")
    }

    @Test("Credit marked as used stays used until next period")
    func testCreditStaysUsedUntilNextPeriod() async throws {
        let calendar = Calendar.current

        // Scenario: User marks credit as used, it should stay used until the current period ends
        // Create a credit with renewalDate set to current month start
        var components = calendar.dateComponents([.year, .month], from: Date())
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.nanosecond = 0
        let currentMonthStart = calendar.date(from: components)!

        let creditEntity = createTestCreditEntity(
            frequency: "Monthly",
            renewalDate: currentMonthStart,  // Set to current month start
            isUsed: false,
            usedAt: nil
        )

        // Mark as used
        creditEntity.markAsUsed()
        #expect(creditEntity.isUsed == true, "Should be marked as used")
        #expect(creditEntity.usedAt != nil, "Should have usage timestamp")

        // Still in the same period - should NOT renew
        let shouldRenew = creditEntity.shouldRenew()
        #expect(shouldRenew == false, "Should not renew within same period")

        // Credit should stay used
        #expect(creditEntity.isUsed == true, "Should remain used until next period")
    }

    @Test("Newly created credit does not immediately renew")
    func testNewlyCreatedCreditDoesNotRenew() async throws {
        let calendar = Calendar.current

        // Scenario: New credit created today should not renew
        let today = Date()
        let currentPeriodStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!

        let creditEntity = createTestCreditEntity(
            frequency: "Monthly",
            renewalDate: currentPeriodStart,  // Set to current period start
            isUsed: false,
            usedAt: nil
        )

        // Should NOT renew because we're in the same period
        let shouldRenew = creditEntity.shouldRenew()
        #expect(shouldRenew == false, "Newly created credit should not renew")

        // Credit should remain as created
        #expect(creditEntity.isUsed == false)
        #expect(creditEntity.renewalDate == currentPeriodStart)
    }

    // MARK: - Helper Methods

    private func createTestCreditEntity(
        frequency: String,
        renewalDate: Date,
        isUsed: Bool,
        usedAt: Date?
    ) -> CreditEntity {
        // Use shared persistence controller to keep context alive
        let context = Self.testPersistenceController.viewContext
        let creditEntity = CreditEntity(context: context)

        creditEntity.id = UUID()
        creditEntity.name = "Test Credit"
        creditEntity.amount = 100.0
        creditEntity.currency = "USD"
        creditEntity.category = "Test"
        creditEntity.frequency = frequency
        creditEntity.renewalDate = renewalDate
        creditEntity.expirationDate = Calendar.current.date(byAdding: .month, value: 1, to: renewalDate)!
        creditEntity.isUsed = isUsed
        creditEntity.usedAt = usedAt

        // Save the context to persist the entity
        try? context.save()

        return creditEntity
    }
}
