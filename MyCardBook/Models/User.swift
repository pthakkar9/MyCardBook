import Foundation

/// Represents a user of the MyCardBook app.
struct User: Identifiable, Codable {
    /// Unique identifier for the user
    let id: UUID
    /// Username for login
    var username: String
    /// Hashed password (never store plain text passwords!)
    var passwordHash: String
    /// Date the user account was created
    var createdAt: Date
    /// Date of the user's last login
    var lastLoginAt: Date
    /// Whether cloud sync is enabled for this user
    var isCloudSyncEnabled: Bool
    
    /// Initializes a new User instance.
    /// - Parameters: See property docs above.
    init(id: UUID = UUID(), username: String = "", passwordHash: String = "", createdAt: Date = Date(), lastLoginAt: Date = Date(), isCloudSyncEnabled: Bool = false) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
        self.isCloudSyncEnabled = isCloudSyncEnabled
    }
}

/// Aggregates summary statistics for the dashboard view.
struct DashboardSummary {
    /// Total number of cards owned by the user
    let totalCards: Int
    /// Total number of credits across all cards
    let totalCredits: Int
    /// Total value of all available credits
    let totalAvailableValue: Double
    /// Total value of all used credits
    let totalUsedValue: Double
    /// Number of credits expiring soon
    let expiringCreditsCount: Int
    /// Percentage of credits utilized
    let utilizationPercentage: Double
    
    /// Returns the formatted total available value as a currency string.
    var formattedTotalValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: totalAvailableValue + totalUsedValue)) ?? "$\(totalAvailableValue + totalUsedValue)"
    }
    
    /// Returns the formatted available value as a currency string.
    var formattedAvailableValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: totalAvailableValue)) ?? "$\(totalAvailableValue)"
    }
    
    /// Returns the formatted total used value as a currency string.
    var formattedUsedValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: totalUsedValue)) ?? "$\(totalUsedValue)"
    }
}