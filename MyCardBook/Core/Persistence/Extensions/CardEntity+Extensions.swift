import Foundation
import CoreData

/**
 * CardEntity extensions for business logic and model conversion.
 * 
 * This extension adds computed properties and business logic to the auto-generated
 * CardEntity Core Data class. It provides:
 * - Type-safe access to relationships
 * - Business logic computations
 * - Model conversion methods
 * - Validation helpers
 *
 * Privacy Notes:
 * - No sensitive card information (numbers, CVV, etc.) is stored
 * - Only card type, nickname, and benefit information is persisted
 * - All data remains local unless user explicitly enables cloud sync
 */
extension CardEntity {
    
    // MARK: - Computed Properties
    
    /**
     * Computed property to get associated credits as a Swift array
     * Provides type-safe access to the credits relationship
     */
    var creditsArray: [CreditEntity] {
        let set = credits as? Set<CreditEntity> ?? []
        return set.sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
    
    /**
     * Computed property to get active (non-expired) credits
     */
    var activeCredits: [CreditEntity] {
        return creditsArray.filter { !$0.isExpired }
    }
    
    /**
     * Computed property to get available (unused) credits
     */
    var availableCredits: [CreditEntity] {
        return creditsArray.filter { !$0.isUsed }
    }
    
    /**
     * Computed property to get used credits
     */
    var usedCredits: [CreditEntity] {
        return creditsArray.filter { $0.isUsed }
    }
    
    /**
     * Computed property to calculate total value of all credits
     */
    var totalValue: Double {
        return creditsArray.reduce(0) { $0 + $1.amount }
    }
    
    /**
     * Computed property to calculate total available value
     */
    var totalAvailableValue: Double {
        return availableCredits.reduce(0) { $0 + $1.amount }
    }
    
    /**
     * Computed property to calculate total used value
     */
    var totalUsedValue: Double {
        return usedCredits.reduce(0) { $0 + $1.amount }
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
        
        if addedAt == nil {
            addedAt = Date()
        }
    }
    
    // MARK: - Conversion Methods
    
    /**
     * Converts the Core Data entity to a Swift model
     * 
     * - Returns: Card model representation
     */
    func toCard() -> Card {
        let creditModels = creditsArray.map { $0.toCredit() }
        
        return Card(
            id: id ?? UUID(),
            cardType: cardType ?? "",
            nickname: nickname ?? "",
            issuer: issuer ?? "",
            network: network ?? "",
            variant: variant ?? "",
            addedAt: addedAt ?? Date(),
            credits: creditModels
        )
    }
    
    /**
     * Updates the entity from a Swift model
     * 
     * - Parameter card: The card model to update from
     */
    func update(from card: Card) {
        self.id = card.id
        self.cardType = card.cardType
        self.nickname = card.nickname
        self.issuer = card.issuer
        self.network = card.network
        self.variant = card.variant
        self.addedAt = card.addedAt
        
        // Note: Credits are managed separately to maintain relationships
    }
    
    // MARK: - Validation
    
    /**
     * Validates the card entity data
     * 
     * - Returns: True if valid, throws error if invalid
     */
    func validateData() throws {
        guard let cardType = cardType, !cardType.isEmpty else {
            throw CardValidationError.missingCardType
        }
        
        guard let nickname = nickname, !nickname.isEmpty else {
            throw CardValidationError.missingNickname
        }
        
        guard let issuer = issuer, !issuer.isEmpty else {
            throw CardValidationError.missingIssuer
        }
        
        if nickname.count > 100 {
            throw CardValidationError.nicknameTooLong
        }
        
        if id == nil {
            id = UUID()
        }
        
        if addedAt == nil {
            addedAt = Date()
        }
    }
}

// MARK: - Validation Errors

/**
 * Validation errors specific to CardEntity
 */
enum CardValidationError: LocalizedError {
    case missingCardType
    case missingNickname
    case missingIssuer
    case nicknameTooLong
    
    var errorDescription: String? {
        switch self {
        case .missingCardType:
            return "Card type is required"
        case .missingNickname:
            return "Card nickname is required"
        case .missingIssuer:
            return "Card issuer is required"
        case .nicknameTooLong:
            return "Nickname must be 100 characters or less"
        }
    }
}