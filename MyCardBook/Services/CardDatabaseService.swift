import Foundation

// MARK: - Card Database Models

struct CardDatabaseCard: Codable {
    let id: String
    let cardType: String
    let issuer: String
    let network: String
    let variant: String
    let category: String
    let annualFee: Int
    let credits: [CardDatabaseCredit]
}

struct CardDatabaseCredit: Codable {
    let id: String
    let name: String
    let amount: Double
    let currency: String
    let category: String
    let frequency: String
    let description: String?
    let terms: String?
}

struct CardDatabase: Codable {
    let version: String
    let lastUpdated: String
    let cards: [CardDatabaseCard]
}

// MARK: - Card Database Service

class CardDatabaseService: ObservableObject {
    static let shared = CardDatabaseService()
    
    private var database: CardDatabase?
    private let databaseFileName = "cards.json"
    
    private init() {
        loadDatabase()
    }
    
    // MARK: - Public Methods
    
    /// Get all available card types for selection
    func getAvailableCardTypes() -> [String] {
        guard let database = database else { return [] }
        return database.cards.map { $0.cardType }
    }
    
    /// Get credits for a specific card type
    func getCreditsForCard(_ cardType: String) -> [Credit] {
        guard let database = database else { return [] }
        
        let card = database.cards.first { $0.cardType == cardType }
        guard let card = card else { return [] }
        
        return card.credits.map { dbCredit in
            Credit(
                name: dbCredit.name,
                amount: dbCredit.amount,
                currency: dbCredit.currency,
                category: dbCredit.category,
                frequency: dbCredit.frequency,
                renewalDate: calculateRenewalDate(frequency: dbCredit.frequency),
                expirationDate: calculateExpirationDate(frequency: dbCredit.frequency),
                isUsed: false,
                usedAt: nil,
                description: dbCredit.description,
                terms: dbCredit.terms
            )
        }
    }
    
    /// Get card information for a specific card type
    func getCardInfo(_ cardType: String) -> (issuer: String, network: String, variant: String)? {
        guard let database = database else { return nil }
        
        let card = database.cards.first { $0.cardType == cardType }
        guard let card = card else { return nil }
        
        return (issuer: card.issuer, network: card.network, variant: card.variant)
    }
    
    /// Get database version and last updated info
    func getDatabaseInfo() -> (version: String, lastUpdated: String)? {
        guard let database = database else { return nil }
        return (version: database.version, lastUpdated: database.lastUpdated)
    }
    
    /// Reload database from file (useful for updates)
    func reloadDatabase() {
        loadDatabase()
    }
    
    // MARK: - Private Methods
    
    private func loadDatabase() {
        // Try with subdirectory first
        var url = Bundle.main.url(forResource: "cards", withExtension: "json", subdirectory: "Resources/CardDatabase")
        
        // If not found, try without subdirectory
        if url == nil {
            url = Bundle.main.url(forResource: "cards", withExtension: "json")
        }
        
        guard let fileURL = url else {
            print("❌ CardDatabaseService: Could not find cards.json in bundle")
            print("📁 Bundle contents: \(Bundle.main.bundleURL)")
            if let resourcePath = Bundle.main.resourcePath {
                print("📁 Resource path: \(resourcePath)")
                do {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                    print("📁 Contents: \(contents)")
                } catch {
                    print("❌ Could not list contents: \(error)")
                }
            }
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            database = try decoder.decode(CardDatabase.self, from: data)
            print("✅ CardDatabaseService: Successfully loaded \(database?.cards.count ?? 0) cards from database")
        } catch {
            print("❌ CardDatabaseService: Failed to load cards database: \(error)")
        }
    }
    
    private func calculateRenewalDate(frequency: String) -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch frequency.lowercased() {
        case "monthly":
            return calendar.date(byAdding: .month, value: 1, to: now) ?? now
        case "quarterly":
            return calendar.date(byAdding: .month, value: 3, to: now) ?? now
        case "annual", "yearly":
            return calendar.date(byAdding: .year, value: 1, to: now) ?? now
        default:
            return calendar.date(byAdding: .month, value: 1, to: now) ?? now
        }
    }
    
    private func calculateExpirationDate(frequency: String) -> Date {
        let calendar = Calendar.current
        let renewalDate = calculateRenewalDate(frequency: frequency)
        
        switch frequency.lowercased() {
        case "monthly":
            // Monthly credits typically expire at the end of the month
            return calendar.date(byAdding: .day, value: -1, to: renewalDate) ?? renewalDate
        case "quarterly":
            // Quarterly credits expire at the end of the quarter
            return calendar.date(byAdding: .day, value: -1, to: renewalDate) ?? renewalDate
        case "annual", "yearly":
            // Annual credits expire at the end of the year
            return calendar.date(byAdding: .day, value: -1, to: renewalDate) ?? renewalDate
        default:
            return renewalDate
        }
    }
}