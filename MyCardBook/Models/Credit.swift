import Foundation

/// Represents a benefit or credit associated with a card (e.g., dining credit, travel credit).
struct Credit: Identifiable, Codable {
    /// Unique identifier for the credit
    let id: UUID
    /// Name of the credit (e.g., 'Dining Credit')
    var name: String
    /// Monetary value of the credit
    var amount: Double
    /// Currency code (e.g., 'USD')
    var currency: String
    /// Category of the credit (e.g., Dining, Travel)
    var category: String
    /// Frequency of renewal (e.g., Monthly, Annual)
    var frequency: String
    /// Date when the credit renews
    var renewalDate: Date
    /// Date when the credit expires
    var expirationDate: Date
    /// Whether the credit has been used
    var isUsed: Bool
    /// Date when the credit was used (if applicable)
    var usedAt: Date?
    /// Optional description of the credit
    var description: String?
    /// Optional terms and conditions
    var terms: String?
    
    /// Initializes a new Credit instance.
    /// - Parameters: See property docs above.
    init(id: UUID = UUID(), name: String, amount: Double, currency: String = "USD", category: String, frequency: String, renewalDate: Date = Date(), expirationDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(), isUsed: Bool = false, usedAt: Date? = nil, description: String? = nil, terms: String? = nil) {
        self.id = id
        self.name = name
        self.amount = amount
        self.currency = currency
        self.category = category
        self.frequency = frequency
        self.renewalDate = renewalDate
        self.expirationDate = expirationDate
        self.isUsed = isUsed
        self.usedAt = usedAt
        self.description = description
        self.terms = terms
    }
    
    /// Returns true if the credit is expiring soon based on its frequency.
    /// - Monthly credits: within 7 days
    /// - Quarterly credits: within 14 days 
    /// - Annual credits: within 30 days
    /// - One Time credits: within 7 days
    var isExpiringSoon: Bool {
        let daysUntilExpiration = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
        
        let threshold: Int
        switch frequency.lowercased() {
        case "monthly":
            threshold = 7
        case "quarterly":
            threshold = 14
        case "annual":
            threshold = 30
        case "one time":
            threshold = 7
        default:
            threshold = 7 // Default fallback
        }
        
        return daysUntilExpiration <= threshold && daysUntilExpiration >= 0
    }
    
    /// Returns true if the credit has expired.
    var isExpired: Bool {
        expirationDate < Date()
    }
    
    /// Returns the formatted amount as a currency string.
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
    
    /// Returns a color name for the credit's category (for UI purposes).
    var categoryColor: String {
        switch category.lowercased() {
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
    
    /// Returns a system icon name for the credit's category (for UI purposes).
    var categoryIcon: String {
        switch category.lowercased() {
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
}

/// Enumerates supported credit categories for type safety and UI mapping.
enum CreditCategory: String, CaseIterable {
    case dining = "Dining"
    case travel = "Travel"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case wellness = "Wellness"
    case transportation = "Transportation"
    case other = "Other"
}

/// Enumerates supported credit frequencies for type safety and UI mapping.
enum CreditFrequency: String, CaseIterable {
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case annual = "Annual"
    case oneTime = "One Time"
}