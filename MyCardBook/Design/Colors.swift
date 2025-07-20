import SwiftUI

/// Design system colors following UI/UX specifications.
/// These colors ensure consistency across the app and proper dark mode support.
extension Color {
    // MARK: - Credit Category Colors
    /// Credit category colors as defined in UI/UX specifications
    static let diningColor = Color(red: 0.8, green: 0.2, blue: 0.2)        // #CC3333
    static let travelColor = Color(red: 0.2, green: 0.4, blue: 0.8)        // #3366CC
    static let shoppingColor = Color(red: 0.6, green: 0.2, blue: 0.8)      // #9933CC
    static let entertainmentColor = Color(red: 0.8, green: 0.4, blue: 0.2) // #CC6633
    static let wellnessColor = Color(red: 0.2, green: 0.8, blue: 0.6)      // #33CC99
    
    // MARK: - Primary Brand Colors
    static let primaryBlue = Color(red: 0.0, green: 0.478, blue: 1.0)      // #007AFF
    static let primaryGreen = Color(red: 0.2, green: 0.8, blue: 0.4)       // #33CC66
    static let primaryOrange = Color(red: 1.0, green: 0.584, blue: 0.0)    // #FF9500
    
    // MARK: - Semantic Colors
    static let successGreen = Color(red: 0.2, green: 0.8, blue: 0.4)       // #33CC66
    static let warningOrange = Color(red: 1.0, green: 0.584, blue: 0.0)    // #FF9500
    static let errorRed = Color(red: 1.0, green: 0.231, blue: 0.188)       // #FF3B30
    static let infoBlue = Color(red: 0.0, green: 0.478, blue: 1.0)         // #007AFF
    
    /// Returns the appropriate category color for a given category string
    static func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "dining":
            return .diningColor
        case "travel":
            return .travelColor
        case "shopping":
            return .shoppingColor
        case "entertainment":
            return .entertainmentColor
        case "wellness":
            return .wellnessColor
        case "transportation":
            return .infoBlue
        default:
            return Color(.systemGray)
        }
    }
    
    /// Returns the appropriate issuer color for visual distinction
    static func issuerColor(for issuer: String) -> Color {
        switch issuer.lowercased() {
        case "chase":
            return Color(red: 0.0, green: 0.4, blue: 0.8)           // Chase Blue #0066CC
        case "american express", "amex":
            return Color(red: 0.0, green: 0.5, blue: 0.3)           // Amex Green #008050
        case "capital one":
            return Color(red: 0.8, green: 0.2, blue: 0.2)           // Capital One Red #CC3333
        case "citi", "citibank":
            return Color(red: 0.8, green: 0.4, blue: 0.0)           // Citi Orange #CC6600
        case "bank of america", "boa":
            return Color(red: 0.6, green: 0.0, blue: 0.2)           // BofA Burgundy #990033
        case "wells fargo":
            return Color(red: 0.8, green: 0.6, blue: 0.0)           // Wells Fargo Gold #CC9900
        case "discover":
            return Color(red: 0.9, green: 0.4, blue: 0.0)           // Discover Orange #E66600
        case "usaa":
            return Color(red: 0.0, green: 0.3, blue: 0.6)           // USAA Navy #004D99
        default:
            return Color(.systemGray)
        }
    }
}