import Foundation
import CoreData
import SwiftUI

/// Represents a credit card with associated credits and metadata.
///
/// - Note: This struct is designed for use with SwiftUI and Codable for persistence.
struct Card: Identifiable, Codable {
    /// Unique identifier for the card
    let id: UUID
    /// The type of card (e.g., 'American Express Personal Gold Card')
    var cardType: String
    /// User-defined nickname for the card
    var nickname: String
    /// The issuing bank or company
    var issuer: String
    /// The card network (e.g., Visa, Amex)
    var network: String
    /// The variant (e.g., Personal, Business)
    var variant: String
    /// Date the card was added to the app
    var addedAt: Date
    /// List of credits associated with this card
    var credits: [Credit]
    
    /// Initializes a new Card instance.
    /// - Parameters:
    ///   - id: Unique identifier (default: new UUID)
    ///   - cardType: The type of card
    ///   - nickname: User-defined nickname
    ///   - issuer: The issuing bank or company
    ///   - network: The card network
    ///   - variant: The variant
    ///   - addedAt: Date added (default: now)
    ///   - credits: Associated credits (default: empty)
    init(id: UUID = UUID(), cardType: String, nickname: String, issuer: String, network: String, variant: String, addedAt: Date = Date(), credits: [Credit] = []) {
        self.id = id
        self.cardType = cardType
        self.nickname = nickname
        self.issuer = issuer
        self.network = network
        self.variant = variant
        self.addedAt = addedAt
        self.credits = credits
    }
    
    /// The total value of all credits associated with this card.
    var totalValue: Double {
        credits.reduce(0) { $0 + $1.amount }
    }
    
    /// Returns all credits that have not been used.
    var availableCredits: [Credit] {
        credits.filter { !$0.isUsed }
    }
    
    /// Returns all credits that have been used.
    var usedCredits: [Credit] {
        credits.filter { $0.isUsed }
    }
}

extension Card {
    /// Returns the predominant credit category for visual styling.
    /// Used to determine accent colors and visual distinction.
    var predominantCategory: String {
        guard !credits.isEmpty else { return "Other" }
        
        // Count occurrences of each category
        let categoryCount = Dictionary(grouping: credits, by: { $0.category })
            .mapValues { $0.count }
        
        // Return the category with the most credits, or first if tied
        return categoryCount.max(by: { $0.value < $1.value })?.key ?? "Other"
    }
    
    /// Returns the accent color for the card based on issuer.
    /// Uses brand colors for better visual distinction.
    var accentColor: Color {
        return Color.issuerColor(for: issuer)
    }
    
    /// Returns the issuer icon for better visual distinction.
    var issuerIcon: String {
        switch issuer.lowercased() {
        case "chase":
            return "building.columns"
        case "american express", "amex":
            return "creditcard.circle.fill"
        case "capital one":
            return "banknote"
        case "citi", "citibank":
            return "building.2"
        case "bank of america", "boa":
            return "flag"
        case "wells fargo":
            return "laurel.leading"
        case "discover":
            return "creditcard.and.123"
        case "usaa":
            return "shield"
        default:
            return "creditcard"
        }
    }
    
    /// Returns true if this is a high-value card (top tier based on total value).
    var isHighValue: Bool {
        totalValue >= 100.0
    }
    
    /// Sample cards for SwiftUI previews and development testing only.
    /// This data is NOT used in production builds.
    #if DEBUG
    static let sampleCards = [
        Card(
            cardType: "American Express Personal Gold Card",
            nickname: "My Gold Card",
            issuer: "American Express",
            network: "Amex",
            variant: "Personal",
            credits: [
                Credit(
                    name: "Dining Credit", 
                    amount: 10.0, 
                    category: "Dining", 
                    frequency: "Monthly",
                    renewalDate: Date(),
                    expirationDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date()
                ),
                Credit(
                    name: "Uber Credit", 
                    amount: 15.0, 
                    category: "Transportation", 
                    frequency: "Monthly",
                    renewalDate: Date(),
                    expirationDate: Calendar.current.date(byAdding: .day, value: 25, to: Date()) ?? Date()
                )
            ]
        ),
        Card(
            cardType: "Chase Sapphire Preferred",
            nickname: "Travel Card",
            issuer: "Chase",
            network: "Visa",
            variant: "Personal",
            credits: [
                Credit(
                    name: "Annual Travel Credit", 
                    amount: 50.0, 
                    category: "Travel", 
                    frequency: "Annual",
                    renewalDate: Date(),
                    expirationDate: Calendar.current.date(byAdding: .day, value: 25, to: Date()) ?? Date()
                )
            ]
        )
    ]
    #endif
}