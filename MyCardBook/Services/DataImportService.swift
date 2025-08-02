import Foundation

// MARK: - Import Result Models

enum ImportResult {
    case success(ImportSummary)
    case failure(ImportError)
}

struct ImportSummary {
    let cardsImported: Int
    let creditsImported: Int
    let duplicatesSkipped: Int
    let conflictsResolved: Int
    let warnings: [String]
    let importedCards: [Card]
}

enum ImportError: LocalizedError {
    case invalidFormat
    case unsupportedVersion
    case corruptedData
    case missingRequiredFields
    case validationFailed(String)
    case fileReadError
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "Invalid file format. Please ensure you're importing a valid MyCardBook export file."
        case .unsupportedVersion:
            return "Unsupported export version. Please update the app or use a compatible export file."
        case .corruptedData:
            return "The import file appears to be corrupted or incomplete."
        case .missingRequiredFields:
            return "The import file is missing required data fields."
        case .validationFailed(let detail):
            return "Data validation failed: \(detail)"
        case .fileReadError:
            return "Unable to read the import file. Please check the file and try again."
        }
    }
}

enum ConflictResolution {
    case skip          // Skip duplicate cards
    case replace       // Replace existing cards with imported data
    case merge         // Merge credits from both cards
}

// MARK: - Data Import Service

class DataImportService: ObservableObject {
    static let shared = DataImportService()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    private init() {}
    
    // MARK: - JSON Import
    
    /// Import user data from JSON
    func importFromJSON(data: Data, conflictResolution: ConflictResolution = .skip) -> ImportResult {
        do {
            let decoder = JSONDecoder()
            let importData = try decoder.decode(UserDataExport.self, from: data)
            
            // Validate version compatibility
            guard isVersionCompatible(importData.version) else {
                return .failure(.unsupportedVersion)
            }
            
            // Validate data integrity
            let validationResult = validateImportData(importData)
            if case .failure(let error) = validationResult {
                return .failure(error)
            }
            
            // Convert import data to app models
            return processImportedCards(importData.userCards, conflictResolution: conflictResolution)
            
        } catch DecodingError.dataCorrupted(_) {
            return .failure(.corruptedData)
        } catch DecodingError.keyNotFound(_, _) {
            return .failure(.missingRequiredFields)
        } catch {
            print("❌ DataImportService: JSON import failed: \(error)")
            return .failure(.invalidFormat)
        }
    }
    
    // MARK: - CSV Import
    
    /// Import cards from CSV (simplified format)
    func importCardsFromCSV(data: Data) -> ImportResult {
        guard let csvString = String(data: data, encoding: .utf8) else {
            return .failure(.fileReadError)
        }
        
        let lines = csvString.components(separatedBy: .newlines).filter { !$0.isEmpty }
        
        guard lines.count > 1 else {
            return .failure(.invalidFormat)
        }
        
        // Skip header line
        let dataLines = Array(lines.dropFirst())
        var importedCards: [Card] = []
        var warnings: [String] = []
        
        for (index, line) in dataLines.enumerated() {
            let fields = parseCSVLine(line)
            
            guard fields.count >= 7 else {
                warnings.append("Line \(index + 2): Insufficient data fields")
                continue
            }
            
            // Parse basic card information
            let cardType = fields[1]
            let nickname = fields[2]
            let issuer = fields[3]
            let network = fields[4]
            let variant = fields[5]
            
            guard let addedDate = parseDate(fields[6]) else {
                warnings.append("Line \(index + 2): Invalid date format")
                continue
            }
            
            // Get credits from database for this card type
            let credits = CardDatabaseService.shared.getCreditsForCard(cardType)
            
            let card = Card(
                cardType: cardType,
                nickname: nickname,
                issuer: issuer,
                network: network,
                variant: variant,
                addedAt: addedDate,
                credits: credits
            )
            
            importedCards.append(card)
        }
        
        let summary = ImportSummary(
            cardsImported: importedCards.count,
            creditsImported: importedCards.reduce(0) { $0 + $1.credits.count },
            duplicatesSkipped: 0,
            conflictsResolved: 0,
            warnings: warnings,
            importedCards: importedCards
        )
        
        return .success(summary)
    }
    
    // MARK: - Validation
    
    private func validateImportData(_ importData: UserDataExport) -> Result<Void, ImportError> {
        // Validate metadata
        guard importData.metadata.totalCards == importData.userCards.count else {
            return .failure(.validationFailed("Card count mismatch"))
        }
        
        let actualCreditCount = importData.userCards.reduce(0) { $0 + $1.credits.count }
        guard importData.metadata.totalCredits == actualCreditCount else {
            return .failure(.validationFailed("Credit count mismatch"))
        }
        
        // Validate each card
        for card in importData.userCards {
            if card.cardType.isEmpty || card.nickname.isEmpty {
                return .failure(.validationFailed("Card missing required fields"))
            }
            
            // Validate credits
            for credit in card.credits {
                if credit.name.isEmpty || credit.amount < 0 {
                    return .failure(.validationFailed("Credit '\(credit.name)' has invalid data"))
                }
            }
        }
        
        return .success(())
    }
    
    private func isVersionCompatible(_ version: String) -> Bool {
        // For now, we support version 1.x.x
        return version.hasPrefix("1.")
    }
    
    // MARK: - Data Processing
    
    private func processImportedCards(_ importCards: [UserCardExport], conflictResolution: ConflictResolution) -> ImportResult {
        var processedCards: [Card] = []
        let duplicatesSkipped = 0
        let conflictsResolved = 0
        var warnings: [String] = []
        
        for importCard in importCards {
            // Convert dates
            guard let addedDate = dateFormatter.date(from: importCard.addedAt) else {
                warnings.append("Invalid date format for card '\(importCard.nickname)'")
                continue
            }
            
            // Convert credits
            var credits: [Credit] = []
            for importCredit in importCard.credits {
                guard let renewalDate = dateFormatter.date(from: importCredit.renewalDate),
                      let expirationDate = dateFormatter.date(from: importCredit.expirationDate) else {
                    warnings.append("Invalid date format for credit '\(importCredit.name)'")
                    continue
                }
                
                let usedAt = importCredit.usedAt != nil ? dateFormatter.date(from: importCredit.usedAt!) : nil
                
                let credit = Credit(
                    id: UUID(uuidString: importCredit.id) ?? UUID(),
                    name: importCredit.name,
                    amount: importCredit.amount,
                    currency: importCredit.currency,
                    category: importCredit.category,
                    frequency: importCredit.frequency,
                    renewalDate: renewalDate,
                    expirationDate: expirationDate,
                    isUsed: importCredit.isUsed,
                    usedAt: usedAt,
                    description: importCredit.description,
                    terms: importCredit.terms
                )
                
                credits.append(credit)
            }
            
            let card = Card(
                id: UUID(uuidString: importCard.id) ?? UUID(),
                cardType: importCard.cardType,
                nickname: importCard.nickname,
                issuer: importCard.issuer,
                network: importCard.network,
                variant: importCard.variant,
                addedAt: addedDate,
                credits: credits
            )
            
            processedCards.append(card)
        }
        
        let summary = ImportSummary(
            cardsImported: processedCards.count,
            creditsImported: processedCards.reduce(0) { $0 + $1.credits.count },
            duplicatesSkipped: duplicatesSkipped,
            conflictsResolved: conflictsResolved,
            warnings: warnings,
            importedCards: processedCards
        )
        
        return .success(summary)
    }
    
    // MARK: - Helper Methods
    
    private func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var inQuotes = false
        var i = line.startIndex
        
        while i < line.endIndex {
            let char = line[i]
            
            if char == "\"" {
                if inQuotes && i < line.index(before: line.endIndex) && line[line.index(after: i)] == "\"" {
                    // Escaped quote
                    currentField += "\""
                    i = line.index(i, offsetBy: 2)
                    continue
                } else {
                    inQuotes.toggle()
                }
            } else if char == "," && !inQuotes {
                fields.append(currentField)
                currentField = ""
            } else {
                currentField += String(char)
            }
            
            i = line.index(after: i)
        }
        
        fields.append(currentField)
        return fields
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
    
    // MARK: - File Type Detection
    
    /// Detect import file type from data
    func detectFileType(data: Data) -> String? {
        // Try JSON first
        if let _ = try? JSONSerialization.jsonObject(with: data) {
            return "json"
        }
        
        // Try CSV
        if let string = String(data: data, encoding: .utf8),
           string.contains(",") && string.contains("\n") {
            return "csv"
        }
        
        return nil
    }
}