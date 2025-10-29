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
                frequency: normalizeFrequency(dbCredit.frequency),
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
            #if DEBUG
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
            #endif
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            database = try decoder.decode(CardDatabase.self, from: data)
            #if DEBUG
            print("✅ CardDatabaseService: Successfully loaded \(database?.cards.count ?? 0) cards from database")
            #endif
        } catch {
            #if DEBUG
            print("❌ CardDatabaseService: Failed to load cards database: \(error)")
            #endif
        }
    }
    
    private func calculateRenewalDate(frequency: String) -> Date {
        let calendar = Calendar.current
        let now = Date()
        let key = normalizeFrequency(frequency)

        // Align to calendar period starts
        // IMPORTANT: Must normalize dates with explicit day=1 and time=00:00:00.000
        // to match the normalization done in CreditEntity.periodStart()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.nanosecond = 0

        switch key {
        case "Monthly":
            components.day = 1
            return calendar.date(from: components) ?? now
        case "Quarterly":
            let month = components.month ?? 1
            let startMonth = 1 + ((month - 1) / 3) * 3
            components.month = startMonth
            components.day = 1
            return calendar.date(from: components) ?? now
        case "Semi-annual":
            let month = components.month ?? 1
            components.month = month <= 6 ? 1 : 7
            components.day = 1
            return calendar.date(from: components) ?? now
        case "Annual":
            components.month = 1
            components.day = 1
            return calendar.date(from: components) ?? now
        default:
            return now
        }
    }
    
    private func calculateExpirationDate(frequency: String) -> Date {
        let calendar = Calendar.current
        let start = calculateRenewalDate(frequency: frequency)
        let key = normalizeFrequency(frequency)
        let nextStart: Date
        switch key {
        case "Monthly":
            nextStart = calendar.date(byAdding: .month, value: 1, to: start) ?? start
        case "Quarterly":
            nextStart = calendar.date(byAdding: .month, value: 3, to: start) ?? start
        case "Semi-annual":
            nextStart = calendar.date(byAdding: .month, value: 6, to: start) ?? start
        case "Annual":
            nextStart = calendar.date(byAdding: .year, value: 1, to: start) ?? start
        default:
            return start
        }
        return calendar.date(byAdding: .second, value: -1, to: nextStart) ?? start
    }

    /// Normalize incoming frequency strings to canonical presentation used by app
    private func normalizeFrequency(_ frequency: String) -> String {
        let raw = frequency.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.contains("monthly") { return "Monthly" }
        if raw.contains("quarter") { return "Quarterly" }
        if raw.contains("semi-annual") || raw.contains("semiannual") || raw.contains("semi annual") { return "Semi-annual" }
        if raw.contains("annual") || raw == "yearly" { return "Annual" }
        if raw.contains("every 4 years") { return "Every 4 Years" }
        if raw.contains("per stay") { return "Per Stay" }
        return frequency
    }
}