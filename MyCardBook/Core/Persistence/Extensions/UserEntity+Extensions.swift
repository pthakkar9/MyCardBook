import Foundation
import CoreData

/**
 * UserEntity extensions for business logic and model conversion.
 * 
 * This extension adds computed properties and business logic to the auto-generated
 * UserEntity Core Data class. It provides:
 * - Privacy-focused user management
 * - Anonymous credential generation
 * - Model conversion methods
 * - Data aggregation helpers
 *
 * Privacy Notes:
 * - User creation is optional - app works without user accounts
 * - Generated usernames and passwords only (no email, phone, etc.)
 * - All data remains local unless user explicitly enables cloud sync
 * - No tracking or analytics data is stored
 */
extension UserEntity {
    
    // MARK: - Computed Properties
    
    /**
     * Computed property to get associated cards as a Swift array
     */
    var cardsArray: [CardEntity] {
        let set = cards as? Set<CardEntity> ?? []
        return set.sorted { ($0.addedAt ?? Date.distantPast) < ($1.addedAt ?? Date.distantPast) }
    }
    
    /**
     * Computed property to get all cards (renamed from activeCards)
     */
    var activeCards: [CardEntity] {
        return cardsArray
    }
    
    /**
     * Computed property to get all credits across all cards
     */
    var allCredits: [CreditEntity] {
        return cardsArray.flatMap { $0.creditsArray }
    }
    
    /**
     * Computed property to get total value across all cards
     */
    var totalValue: Double {
        return cardsArray.reduce(0) { $0 + $1.totalValue }
    }
    
    /**
     * Computed property to check if user has any data
     */
    var hasData: Bool {
        return !cardsArray.isEmpty
    }
    
    /**
     * Computed property to check if user account is properly configured
     */
    var isValid: Bool {
        guard let username = username, !username.isEmpty else { return false }
        guard let passwordHash = passwordHash, !passwordHash.isEmpty else { return false }
        return true
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
        
        if createdAt == nil {
            createdAt = Date()
        }
        
        if lastLoginAt == nil {
            lastLoginAt = Date()
        }
        
        isCloudSyncEnabled = false
    }
    
    // MARK: - Business Logic
    
    /**
     * Updates the last login timestamp
     */
    func updateLastLogin() {
        lastLoginAt = Date()
    }
    
    /**
     * Enables cloud sync for the user
     */
    func enableCloudSync() {
        isCloudSyncEnabled = true
    }
    
    /**
     * Disables cloud sync for the user
     */
    func disableCloudSync() {
        isCloudSyncEnabled = false
    }
    
    /**
     * Generates a new username
     * 
     * - Returns: A new random username
     */
    static func generateUsername() -> String {
        let adjectives = ["swift", "clever", "bright", "quick", "smart", "wise", "keen", "bold", "calm", "cool"]
        let nouns = ["card", "user", "saver", "wise", "pro", "expert", "guru", "master", "ninja", "hero"]
        
        let adjective = adjectives.randomElement() ?? "swift"
        let noun = nouns.randomElement() ?? "user"
        let number = Int.random(in: 100...999)
        
        return "\(adjective)-\(noun)-\(number)"
    }
    
    /**
     * Generates a BIP-39 mnemonic password
     * 
     * - Returns: A 12-word mnemonic phrase
     */
    static func generateMnemonic() -> String {
        // This would integrate with a proper BIP-39 library
        // For now, returning a placeholder
        let words = ["abandon", "ability", "able", "about", "above", "absent", "absorb", "abstract", "absurd", "abuse", "access", "accident"]
        return words.shuffled().prefix(12).joined(separator: " ")
    }
    
    /**
     * Generates a password hash from a mnemonic
     * 
     * - Parameter mnemonic: The mnemonic phrase to hash
     * - Returns: A hash of the mnemonic
     */
    static func hashMnemonic(_ mnemonic: String) -> String {
        // This would use proper cryptographic hashing
        // For now, returning a simple hash
        return String(mnemonic.hashValue)
    }
    
    // MARK: - Conversion Methods
    
    /**
     * Converts the Core Data entity to a Swift model
     * 
     * - Returns: User model representation
     */
    func toUser() -> User {
        return User(
            id: id ?? UUID(),
            username: username ?? "",
            passwordHash: passwordHash ?? "",
            createdAt: createdAt ?? Date(),
            lastLoginAt: lastLoginAt ?? Date(),
            isCloudSyncEnabled: isCloudSyncEnabled
        )
    }
    
    /**
     * Updates the entity from a Swift model
     * 
     * - Parameter user: The user model to update from
     */
    func update(from user: User) {
        self.id = user.id
        self.username = user.username
        self.passwordHash = user.passwordHash
        self.createdAt = user.createdAt
        self.lastLoginAt = user.lastLoginAt
        self.isCloudSyncEnabled = user.isCloudSyncEnabled
    }
    
    // MARK: - Validation
    
    /**
     * Validates the user entity data
     * 
     * - Returns: True if valid, throws error if invalid
     */
    func validateData() throws {
        if id == nil {
            id = UUID()
        }
        
        if createdAt == nil {
            createdAt = Date()
        }
        
        if lastLoginAt == nil {
            lastLoginAt = Date()
        }
        
        if let username = username {
            if username.isEmpty {
                throw UserValidationError.emptyUsername
            }
            
            if username.count > 50 {
                throw UserValidationError.usernameTooLong
            }
            
            let usernameRegex = "^[a-zA-Z0-9\\-]+$"
            let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
            if !usernamePredicate.evaluate(with: username) {
                throw UserValidationError.invalidUsernameFormat
            }
        }
        
        if let passwordHash = passwordHash {
            if passwordHash.isEmpty {
                throw UserValidationError.emptyPasswordHash
            }
            
            if passwordHash.count < 10 {
                throw UserValidationError.passwordHashTooShort
            }
        }
    }
}

// MARK: - Validation Errors

/**
 * Validation errors specific to UserEntity
 */
enum UserValidationError: LocalizedError {
    case emptyUsername
    case usernameTooLong
    case invalidUsernameFormat
    case emptyPasswordHash
    case passwordHashTooShort
    
    var errorDescription: String? {
        switch self {
        case .emptyUsername:
            return "Username cannot be empty"
        case .usernameTooLong:
            return "Username must be 50 characters or less"
        case .invalidUsernameFormat:
            return "Username can only contain letters, numbers, and dashes"
        case .emptyPasswordHash:
            return "Password hash cannot be empty"
        case .passwordHashTooShort:
            return "Password hash is too short"
        }
    }
}