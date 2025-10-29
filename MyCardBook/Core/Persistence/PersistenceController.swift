import CoreData
import Foundation

/**
 * PersistenceController manages the Core Data stack for MyCardBook.
 * 
 * This controller implements a privacy-first approach where all data is stored
 * locally on the user's device by default. The controller provides:
 * - Local SQLite database for primary storage
 * - Optional CloudKit integration for user-initiated sync
 * - Automatic data migration and validation
 * - Error handling and data integrity checks
 *
 * Architecture:
 * - Uses NSPersistentContainer with CloudKit integration
 * - Implements repository pattern for data access
 * - Provides thread-safe operations with proper context management
 * - Supports both in-memory (testing) and persistent storage
 */
class PersistenceController: ObservableObject {
    
    // MARK: - Shared Instance
    
    /// Shared singleton instance for app-wide use
    static let shared = PersistenceController()
    
    /// Preview instance for SwiftUI previews and testing
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        // Create sample data for previews
        let sampleCard = CardEntity(context: context)
        sampleCard.id = UUID()
        sampleCard.cardType = "American Express Personal Gold Card"
        sampleCard.nickname = "My Gold Card"
        sampleCard.issuer = "American Express"
        sampleCard.network = "Amex"
        sampleCard.variant = "Personal"
        sampleCard.addedAt = Date()
        
        let sampleCredit = CreditEntity(context: context)
        sampleCredit.id = UUID()
        sampleCredit.name = "Dining Credit"
        sampleCredit.amount = 10.0
        sampleCredit.currency = "USD"
        sampleCredit.category = "Dining"
        sampleCredit.frequency = "Monthly"
        sampleCredit.renewalDate = Date()
        sampleCredit.expirationDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        sampleCredit.isUsed = false
        sampleCredit.card = sampleCard
        
        do {
            try context.save()
        } catch {
            print("Preview data creation failed: \(error)")
        }
        
        return controller
    }()
    
    // MARK: - Core Data Stack
    
    /// The persistent container that manages the Core Data stack
    let container: NSPersistentContainer
    
    /// Main context for UI operations (always use on main queue)
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    /// Background context for heavy operations (use for imports, exports, etc.)
    var backgroundContext: NSManagedObjectContext {
        container.newBackgroundContext()
    }
    
    // MARK: - Initialization
    
    /**
     * Initializes the Core Data stack
     * 
     * - Parameter inMemory: Whether to use in-memory storage (for testing)
     */
    init(inMemory: Bool = false) {
        // Initialize the persistent container
        container = NSPersistentContainer(name: "MyCardBook")
        
        if inMemory {
            // Use in-memory store for testing and previews
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Configure persistent store for production
            configurePersistentStore()
        }
        
        // Load the persistent stores
        container.loadPersistentStores { [weak self] description, error in
            if let error = error {
                self?.handlePersistentStoreError(error)
            } else {
                self?.configureCoreDataStack()
            }
        }
    }
    
    // MARK: - Configuration
    
    /**
     * Configures the persistent store with privacy and performance settings
     */
    private func configurePersistentStore() {
        guard let storeDescription = container.persistentStoreDescriptions.first else {
            fatalError("No persistent store description found")
        }
        
        // Enable CloudKit integration if available
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // Configure for privacy and performance
        storeDescription.shouldInferMappingModelAutomatically = true
        storeDescription.shouldMigrateStoreAutomatically = true
        
        // Set file protection for privacy
        storeDescription.setOption(FileProtectionType.complete as NSString, forKey: NSPersistentStoreFileProtectionKey)
    }
    
    /**
     * Configures the Core Data stack after stores are loaded
     */
    private func configureCoreDataStack() {
        // Configure view context for main thread operations
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Set up change notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePersistentStoreRemoteChange),
            name: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator
        )
    }
    
    // MARK: - Error Handling
    
    /**
     * Handles persistent store loading errors
     * 
     * - Parameter error: The error that occurred during store loading
     */
    private func handlePersistentStoreError(_ error: Error) {
        print("Core Data error: \(error)")
        
        // In a production app, you might want to:
        // 1. Show user-friendly error message
        // 2. Attempt store recovery
        // 3. Report error to analytics (while respecting privacy)
        
        fatalError("Core Data store failed to load: \(error)")
    }
    
    /**
     * Handles remote change notifications from CloudKit
     */
    @objc private func handlePersistentStoreRemoteChange(notification: Notification) {
        // Handle CloudKit remote changes
        // This will be implemented when CloudKit sync is added
        #if DEBUG
        // Uncomment for debugging Core Data sync issues
        // print("Remote change notification received")
        #endif
    }
    
    // MARK: - Save Operations
    
    /**
     * Saves changes in the view context
     * 
     * - Throws: Core Data save error
     */
    func save() throws {
        guard viewContext.hasChanges else { return }
        
        // Ensure we're on the main thread for view context operations
        if Thread.isMainThread {
            do {
                try viewContext.save()
            } catch {
                print("Failed to save context: \(error)")
                throw error
            }
        } else {
            DispatchQueue.main.sync {
                do {
                    try viewContext.save()
                } catch {
                    print("Failed to save context: \(error)")
                }
            }
        }
    }
    
    /**
     * Saves changes in the view context with error handling
     * 
     * - Returns: Success status
     */
    @discardableResult
    func saveContext() -> Bool {
        do {
            try save()
            return true
        } catch {
            print("Context save failed: \(error)")
            return false
        }
    }
    
    /**
     * Performs a save operation on a background context
     * 
     * - Parameter block: The block to execute on background context
     */
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask(block)
    }
    
    // MARK: - Batch Operations
    
    /**
     * Deletes all data from the persistent store
     * 
     * This method is used for:
     * - User-initiated data clearing
     * - Testing cleanup
     * - Account reset functionality
     */
    func deleteAllData() throws {
        let entities = ["CardEntity", "CreditEntity", "UserEntity"]
        
        for entityName in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                let result = try viewContext.execute(deleteRequest) as? NSBatchDeleteResult
                let objectIDs = result?.result as? [NSManagedObjectID] ?? []
                let changes = [NSDeletedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
            } catch {
                print("Failed to delete \(entityName): \(error)")
                throw error
            }
        }
        
        try save()
    }
    
    // MARK: - Validation
    
    /**
     * Validates the Core Data model integrity
     * 
     * - Returns: Validation result with any issues found
     */
    func validateModelIntegrity() -> ValidationResult {
        var issues: [String] = []
        
        // Check if all required entities exist
        let requiredEntities = ["CardEntity", "CreditEntity", "UserEntity"]
        for entityName in requiredEntities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            do {
                _ = try viewContext.fetch(fetchRequest)
            } catch {
                issues.append("Entity \(entityName) validation failed: \(error)")
            }
        }
        
        return ValidationResult(isValid: issues.isEmpty, issues: issues)
    }
}

// MARK: - Supporting Types

/**
 * Result of data validation operations
 */
struct ValidationResult {
    let isValid: Bool
    let issues: [String]
}

// MARK: - Extensions

extension PersistenceController {
    /**
     * Development helper to print Core Data SQL queries
     * Only enabled in DEBUG builds for development assistance
     */
    func enableSQLLogging() {
        #if DEBUG
        // Enable SQL logging for development
        // This helps developers understand Core Data operations
        // Remove or disable in production builds
        #endif
    }
}