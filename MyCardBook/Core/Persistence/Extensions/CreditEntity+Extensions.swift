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
     * Checks if the credit should be renewed based on frequency
     */
    func shouldRenew() -> Bool {
        guard let renewalDate = renewalDate else { return false }
        let now = Date()
        
        switch frequency?.lowercased() {
        case "monthly":
            return Calendar.current.dateComponents([.month], from: renewalDate, to: now).month ?? 0 >= 1
        case "quarterly":
            return Calendar.current.dateComponents([.month], from: renewalDate, to: now).month ?? 0 >= 3
        case "annual":
            return Calendar.current.dateComponents([.year], from: renewalDate, to: now).year ?? 0 >= 1
        default:
            return false
        }
    }
    
    /**
     * Renews the credit by resetting usage and updating dates
     */
    func renew() {
        guard shouldRenew() else { return }
        
        // Reset usage
        isUsed = false
        usedAt = nil
        
        // Update dates based on frequency
        let calendar = Calendar.current
        
        switch frequency?.lowercased() {
        case "monthly":
            renewalDate = calendar.date(byAdding: .month, value: 1, to: renewalDate ?? Date())
            expirationDate = calendar.date(byAdding: .month, value: 1, to: expirationDate ?? Date())
        case "quarterly":
            renewalDate = calendar.date(byAdding: .month, value: 3, to: renewalDate ?? Date())
            expirationDate = calendar.date(byAdding: .month, value: 3, to: expirationDate ?? Date())
        case "annual":
            renewalDate = calendar.date(byAdding: .year, value: 1, to: renewalDate ?? Date())
            expirationDate = calendar.date(byAdding: .year, value: 1, to: expirationDate ?? Date())
        default:
            break
        }
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