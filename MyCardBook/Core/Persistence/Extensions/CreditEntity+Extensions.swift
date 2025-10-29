import Foundation
import CoreData

/**
 * CreditEntity extensions for business logic and model conversion.
 * 
 * This extension adds computed properties and business logic to the auto-generated
 * CreditEntity Core Data class. It provides:
 * - Usage tracking and expiration logic
 * - Business computations and formatting
 * - Model conversion methods
 * - Category-based styling helpers
 *
 * Privacy Notes:
 * - Only benefit information is stored, no personal spending data
 * - Usage tracking is for benefit optimization, not personal surveillance
 * - All data remains local unless user explicitly enables cloud sync
 */
extension CreditEntity {
    
    // MARK: - Computed Properties
    
    /**
     * Computed property to check if credit is expiring soon (within 7 days)
     */
    var isExpiringSoon: Bool {
        guard let expirationDate = expirationDate else { return false }
        let daysUntilExpiration = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
        return daysUntilExpiration <= 7 && daysUntilExpiration >= 0
    }
    
    /**
     * Computed property to check if credit is expired
     */
    var isExpired: Bool {
        guard let expirationDate = expirationDate else { return false }
        return expirationDate < Date()
    }
    
    /**
     * Computed property to format amount as currency string
     */
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency ?? "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
    
    /**
     * Computed property to get category color name
     */
    var categoryColor: String {
        switch category?.lowercased() {
        case "dining":
            return "red"
        case "travel":
            return "blue"
        case "shopping":
            return "purple"
        case "entertainment":
            return "orange"
        case "wellness":
            return "green"
        case "transportation":
            return "teal"
        default:
            return "gray"
        }
    }
    
    /**
     * Computed property to get category icon name
     */
    var categoryIcon: String {
        switch category?.lowercased() {
        case "dining":
            return "fork.knife"
        case "travel":
            return "airplane"
        case "shopping":
            return "bag"
        case "entertainment":
            return "tv"
        case "wellness":
            return "heart"
        case "transportation":
            return "car"
        default:
            return "creditcard"
        }
    }
    
    /**
     * Computed property to get days until expiration
     */
    var daysUntilExpiration: Int {
        guard let expirationDate = expirationDate else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
        return max(0, days)
    }
    
    // MARK: - Lifecycle
    
    /**
     * Called when the object is first created
     */
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        // Set default values
        if id == nil {
            id = UUID()
        }
        
        if currency == nil {
            currency = "USD"
        }
        
        if renewalDate == nil {
            renewalDate = Date()
        }
        
        if expirationDate == nil {
            expirationDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        }
        
        isUsed = false
    }
    
    // MARK: - Business Logic
    
    /**
     * Marks the credit as used
     */
    func markAsUsed() {
        isUsed = true
        usedAt = Date()
    }

    /**
     * Marks the credit as unused
     */
    func markAsUnused() {
        isUsed = false
        usedAt = nil
    }

    /**
     * Toggles the usage state of the credit
     */
    func toggleUsage() {
        if isUsed {
            markAsUnused()
        } else {
            markAsUsed()
        }
    }
    
    /**
     * Checks if the credit should be renewed based on calendar boundaries.
     * Monthly, Quarterly, Semi-annual, Annual renew at the start of the next calendar period,
     * independent of whether the credit was used in the previous period.
     *
     * Credits are renewed when we cross into a new calendar period to ensure:
     * - Credit dates always reflect the current period
     * - Unused credits don't appear expired when a new period begins
     * - All credits reset to available at the start of each period
     */
    func shouldRenew() -> Bool {
        guard let renewalDate = renewalDate else { return false }
        guard let frequencyKey = normalizedFrequency() else { return false }

        let now = Date()
        let storedPeriodStart = periodStart(for: renewalDate, frequencyKey: frequencyKey)
        let currentPeriodStart = periodStart(for: now, frequencyKey: frequencyKey)

        // Renew if we're in a different period
        // Note: Newly created credits have renewalDate = current period start,
        // so storedPeriodStart == currentPeriodStart and won't trigger renewal
        return storedPeriodStart != currentPeriodStart
    }
    
    /**
     * Renews the credit by resetting usage and aligning dates to the current calendar period.
     */
    func renew() {
        guard shouldRenew() else { return }
        guard let frequencyKey = normalizedFrequency() else { return }

        // Reset usage
        isUsed = false
        usedAt = nil

        let now = Date()
        // Align to calendar period boundaries
        let start = periodStart(for: now, frequencyKey: frequencyKey)
        let end = periodEnd(forPeriodStartingAt: start, frequencyKey: frequencyKey)
        renewalDate = start
        expirationDate = end
    }

    // MARK: - Calendar Period Helpers
    
    /// Returns a normalized frequency key understood by our logic
    /// ("monthly", "quarterly", "semiannual", "annual"). Returns nil for unsupported.
    private func normalizedFrequency() -> String? {
        guard let raw = frequency?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
        if raw.contains("monthly") { return "monthly" }
        if raw.contains("quarter") { return "quarterly" }
        if raw.contains("semi-annual") || raw.contains("semiannual") || raw.contains("semi annual") { return "semiannual" }
        if raw.contains("annual") || raw == "yearly" { return "annual" }
        return nil
    }
    
    /// Start of the calendar period for a given date and frequency
    private func periodStart(for date: Date, frequencyKey: String) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 0; components.minute = 0; components.second = 0; components.nanosecond = 0
        
        switch frequencyKey {
        case "monthly":
            components.day = 1
            return calendar.date(from: components) ?? date
        case "quarterly":
            let month = components.month ?? 1
            // Quarters start Jan (1), Apr (4), Jul (7), Oct (10)
            let startMonth = 1 + ((month - 1) / 3) * 3
            components.month = startMonth
            components.day = 1
            return calendar.date(from: components) ?? date
        case "semiannual":
            let month = components.month ?? 1
            // Semi-annual periods: Jan-Jun (start 1), Jul-Dec (start 7)
            components.month = month <= 6 ? 1 : 7
            components.day = 1
            return calendar.date(from: components) ?? date
        case "annual":
            components.month = 1
            components.day = 1
            return calendar.date(from: components) ?? date
        default:
            return date
        }
    }
    
    /// End of the calendar period (end of day) for a period starting at start
    private func periodEnd(forPeriodStartingAt start: Date, frequencyKey: String) -> Date {
        let calendar = Calendar.current
        let nextStart: Date
        switch frequencyKey {
        case "monthly":
            nextStart = calendar.date(byAdding: .month, value: 1, to: start) ?? start
        case "quarterly":
            nextStart = calendar.date(byAdding: .month, value: 3, to: start) ?? start
        case "semiannual":
            nextStart = calendar.date(byAdding: .month, value: 6, to: start) ?? start
        case "annual":
            nextStart = calendar.date(byAdding: .year, value: 1, to: start) ?? start
        default:
            nextStart = start
        }
        // End is one second before nextStart
        return calendar.date(byAdding: .second, value: -1, to: nextStart) ?? start
    }
    
    // MARK: - Conversion Methods
    
    /**
     * Converts the Core Data entity to a Swift model
     * 
     * - Returns: Credit model representation
     */
    func toCredit() -> Credit {
        return Credit(
            id: id ?? UUID(),
            name: name ?? "",
            amount: amount,
            currency: currency ?? "USD",
            category: category ?? "",
            frequency: frequency ?? "",
            renewalDate: renewalDate ?? Date(),
            expirationDate: expirationDate ?? Date(),
            isUsed: isUsed,
            usedAt: usedAt,
            description: creditDescription,
            terms: terms
        )
    }
    
    /**
     * Updates the entity from a Swift model
     * 
     * - Parameter credit: The credit model to update from
     */
    func update(from credit: Credit) {
        self.id = credit.id
        self.name = credit.name
        self.amount = credit.amount
        self.currency = credit.currency
        self.category = credit.category
        self.frequency = credit.frequency
        self.renewalDate = credit.renewalDate
        self.expirationDate = credit.expirationDate
        self.isUsed = credit.isUsed
        self.usedAt = credit.usedAt
        self.creditDescription = credit.description
        self.terms = credit.terms
    }
    
    // MARK: - Validation
    
    /**
     * Validates the credit entity data
     * 
     * - Returns: True if valid, throws error if invalid
     */
    func validateData() throws {
        guard let name = name, !name.isEmpty else {
            throw CreditValidationError.missingName
        }
        
        guard let category = category, !category.isEmpty else {
            throw CreditValidationError.missingCategory
        }
        
        guard let frequency = frequency, !frequency.isEmpty else {
            throw CreditValidationError.missingFrequency
        }
        
        if amount < 0 {
            throw CreditValidationError.negativeAmount
        }
        
        if name.count > 100 {
            throw CreditValidationError.nameTooLong
        }
        
        if let currency = currency, currency.count != 3 {
            throw CreditValidationError.invalidCurrency
        }
        
        if id == nil {
            id = UUID()
        }
        
        if renewalDate == nil {
            renewalDate = Date()
        }
        
        if expirationDate == nil {
            expirationDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        }
        
        if let renewal = renewalDate, let expiration = expirationDate, expiration <= renewal {
            throw CreditValidationError.invalidDateRange
        }
    }
}

// MARK: - Validation Errors

/**
 * Validation errors specific to CreditEntity
 */
enum CreditValidationError: LocalizedError {
    case missingName
    case missingCategory
    case missingFrequency
    case negativeAmount
    case nameTooLong
    case invalidCurrency
    case invalidDateRange
    
    var errorDescription: String? {
        switch self {
        case .missingName:
            return "Credit name is required"
        case .missingCategory:
            return "Credit category is required"
        case .missingFrequency:
            return "Credit frequency is required"
        case .negativeAmount:
            return "Credit amount cannot be negative"
        case .nameTooLong:
            return "Credit name must be 100 characters or less"
        case .invalidCurrency:
            return "Currency code must be 3 characters"
        case .invalidDateRange:
            return "Expiration date must be after renewal date"
        }
    }
}