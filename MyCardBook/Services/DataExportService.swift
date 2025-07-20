import Foundation
import UIKit

// MARK: - Export Models

struct UserDataExport: Codable {
    let version: String
    let exportDate: String
    let userCards: [UserCardExport]
    let metadata: ExportMetadata
}

struct UserCardExport: Codable {
    let id: String
    let cardType: String
    let nickname: String
    let issuer: String
    let network: String
    let variant: String
    let addedAt: String
    let credits: [UserCreditExport]
}

struct UserCreditExport: Codable {
    let id: String
    let name: String
    let amount: Double
    let currency: String
    let category: String
    let frequency: String
    let renewalDate: String
    let expirationDate: String
    let isUsed: Bool
    let usedAt: String?
    let description: String?
    let terms: String?
}

struct ExportMetadata: Codable {
    let appVersion: String
    let databaseVersion: String?
    let totalCards: Int
    let totalCredits: Int
    let exportFormat: String
}

// MARK: - CSV Export Models

struct CSVCardRow {
    let cardId: String
    let cardType: String
    let nickname: String
    let issuer: String
    let network: String
    let variant: String
    let addedAt: String
    let totalCredits: Int
    let usedCredits: Int
    let availableCredits: Int
}

struct CSVCreditRow {
    let creditId: String
    let cardId: String
    let cardNickname: String
    let creditName: String
    let amount: Double
    let currency: String
    let category: String
    let frequency: String
    let renewalDate: String
    let expirationDate: String
    let isUsed: Bool
    let usedAt: String
}

// MARK: - Data Export Service

class DataExportService: ObservableObject {
    static let shared = DataExportService()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    private let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private init() {}
    
    // MARK: - JSON Export
    
    /// Export user data as JSON
    func exportAsJSON(cards: [Card]) -> Data? {
        let userCards = cards.map { card in
            UserCardExport(
                id: card.id.uuidString,
                cardType: card.cardType,
                nickname: card.nickname,
                issuer: card.issuer,
                network: card.network,
                variant: card.variant,
                addedAt: dateFormatter.string(from: card.addedAt),
                credits: card.credits.map { credit in
                    UserCreditExport(
                        id: credit.id.uuidString,
                        name: credit.name,
                        amount: credit.amount,
                        currency: credit.currency,
                        category: credit.category,
                        frequency: credit.frequency,
                        renewalDate: dateFormatter.string(from: credit.renewalDate),
                        expirationDate: dateFormatter.string(from: credit.expirationDate),
                        isUsed: credit.isUsed,
                        usedAt: credit.usedAt != nil ? dateFormatter.string(from: credit.usedAt!) : nil,
                        description: credit.description,
                        terms: credit.terms
                    )
                }
            )
        }
        
        let metadata = ExportMetadata(
            appVersion: getAppVersion(),
            databaseVersion: getCardDatabaseVersion(),
            totalCards: cards.count,
            totalCredits: cards.reduce(0) { $0 + $1.credits.count },
            exportFormat: "JSON"
        )
        
        let export = UserDataExport(
            version: "1.0.0",
            exportDate: dateFormatter.string(from: Date()),
            userCards: userCards,
            metadata: metadata
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            return try encoder.encode(export)
        } catch {
            print("❌ DataExportService: Failed to encode JSON: \(error)")
            return nil
        }
    }
    
    // MARK: - CSV Export
    
    /// Export user cards as CSV
    func exportCardsAsCSV(cards: [Card]) -> Data? {
        var csvContent = "Card ID,Card Type,Nickname,Issuer,Network,Variant,Added Date,Total Credits,Used Credits,Available Credits\n"
        
        for card in cards {
            let row = CSVCardRow(
                cardId: card.id.uuidString,
                cardType: escapeCSVField(card.cardType),
                nickname: escapeCSVField(card.nickname),
                issuer: escapeCSVField(card.issuer),
                network: escapeCSVField(card.network),
                variant: escapeCSVField(card.variant),
                addedAt: displayDateFormatter.string(from: card.addedAt),
                totalCredits: card.credits.count,
                usedCredits: card.credits.filter { $0.isUsed }.count,
                availableCredits: card.credits.filter { !$0.isUsed }.count
            )
            
            csvContent += "\(row.cardId),\(row.cardType),\(row.nickname),\(row.issuer),\(row.network),\(row.variant),\(row.addedAt),\(row.totalCredits),\(row.usedCredits),\(row.availableCredits)\n"
        }
        
        return csvContent.data(using: .utf8)
    }
    
    /// Export user credits as CSV
    func exportCreditsAsCSV(cards: [Card]) -> Data? {
        var csvContent = "Credit ID,Card ID,Card Nickname,Credit Name,Amount,Currency,Category,Frequency,Renewal Date,Expiration Date,Is Used,Used Date\n"
        
        for card in cards {
            for credit in card.credits {
                let row = CSVCreditRow(
                    creditId: credit.id.uuidString,
                    cardId: card.id.uuidString,
                    cardNickname: escapeCSVField(card.nickname),
                    creditName: escapeCSVField(credit.name),
                    amount: credit.amount,
                    currency: credit.currency,
                    category: escapeCSVField(credit.category),
                    frequency: escapeCSVField(credit.frequency),
                    renewalDate: displayDateFormatter.string(from: credit.renewalDate),
                    expirationDate: displayDateFormatter.string(from: credit.expirationDate),
                    isUsed: credit.isUsed,
                    usedAt: credit.usedAt != nil ? displayDateFormatter.string(from: credit.usedAt!) : ""
                )
                
                csvContent += "\(row.creditId),\(row.cardId),\(row.cardNickname),\(row.creditName),\(row.amount),\(row.currency),\(row.category),\(row.frequency),\(row.renewalDate),\(row.expirationDate),\(row.isUsed),\(row.usedAt)\n"
            }
        }
        
        return csvContent.data(using: .utf8)
    }
    
    // MARK: - Helper Methods
    
    private func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return field
    }
    
    private func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private func getCardDatabaseVersion() -> String? {
        return CardDatabaseService.shared.getDatabaseInfo()?.version
    }
    
    // MARK: - File Sharing
    
    /// Generate filename for export
    func generateExportFilename(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        
        switch format.lowercased() {
        case "json":
            return "MyCardBook_Export_\(timestamp).json"
        case "csv-cards":
            return "MyCardBook_Cards_\(timestamp).csv"
        case "csv-credits":
            return "MyCardBook_Credits_\(timestamp).csv"
        default:
            return "MyCardBook_Export_\(timestamp).txt"
        }
    }
    
    /// Create activity view controller for sharing exported data
    func createShareController(data: Data, filename: String) -> UIActivityViewController? {
        // Create temporary file
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            let activityController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            return activityController
        } catch {
            print("❌ DataExportService: Failed to create temporary file: \(error)")
            return nil
        }
    }
}