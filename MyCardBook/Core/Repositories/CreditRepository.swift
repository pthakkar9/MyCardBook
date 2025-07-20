import Foundation
import CoreData
import Combine

/**
 * CreditRepository provides a clean interface for Credit data operations.
 * 
 * This repository implements the Repository pattern to:
 * - Abstract Core Data operations for credit management
 * - Provide type-safe operations for Credit entities
 * - Handle credit usage tracking and expiration logic
 * - Support reactive programming with Combine
 * - Maintain privacy-first data handling
 *
 * Architecture:
 * - Uses PersistenceController for Core Data access
 * - Converts between Core Data entities and Swift models
 * - Provides filtering and search capabilities
 * - Implements automatic renewal logic
 */
class CreditRepository: ObservableObject {
    
    // MARK: - Properties
    
    private let persistenceController: PersistenceController
    private let context: NSManagedObjectContext
    
    /// Published property for reactive UI updates
    @Published var credits: [Credit] = []
    
    /// Published property for loading state
    @Published var isLoading = false
    
    /// Published property for error state
    @Published var error: Error?
    
    // MARK: - Initialization
    
    /**
     * Initializes the repository with a persistence controller
     * 
     * - Parameter persistenceController: The Core Data persistence controller
     */
    init(persistenceController: PersistenceController = PersistenceController.shared) {
        self.persistenceController = persistenceController
        self.context = persistenceController.viewContext
        
        // Load initial data synchronously
        loadCreditsSync()
    }
    
    /**
     * Synchronously loads credits during initialization
     */
    private func loadCreditsSync() {
        do {
            let fetchRequest: NSFetchRequest<CreditEntity> = CreditEntity.fetchRequest()
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \CreditEntity.expirationDate, ascending: true),
                NSSortDescriptor(keyPath: \CreditEntity.name, ascending: true)
            ]
            
            let creditEntities = try context.fetch(fetchRequest)
            credits = creditEntities.map { $0.toCredit() }
        } catch {
            print("Failed to load credits: \(error)")
            credits = []
        }
    }
    
    // MARK: - Public Interface
    
    /**
     * Loads all credits from Core Data
     */
    func loadCredits() {
        Task { @MainActor in
            isLoading = true
            error = nil
            
            do {
                let fetchRequest: NSFetchRequest<CreditEntity> = CreditEntity.fetchRequest()
                fetchRequest.sortDescriptors = [
                    NSSortDescriptor(keyPath: \CreditEntity.expirationDate, ascending: true),
                    NSSortDescriptor(keyPath: \CreditEntity.name, ascending: true)
                ]
                
                let creditEntities = try context.fetch(fetchRequest)
                credits = creditEntities.map { $0.toCredit() }
                
                isLoading = false
            } catch {
                handleError(error)
            }
        }
    }
    
    /**
     * Toggles the usage status of a credit
     * 
     * - Parameter credit: The credit to toggle
     */
    func toggleCreditUsage(_ credit: Credit) async {
        isLoading = true
        error = nil
        
        do {
            let fetchRequest: NSFetchRequest<CreditEntity> = CreditEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", credit.id as CVarArg)
            
            guard let creditEntity = try context.fetch(fetchRequest).first else {
                throw CreditRepositoryError.creditNotFound
            }
            
            creditEntity.toggleUsage()
            
            try persistenceController.save()
            
            await refreshCredits()
            
            isLoading = false
            
        } catch {
            handleError(error)
        }
    }
    
    /**
     * Marks a credit as used
     * 
     * - Parameter credit: The credit to mark as used
     */
    func markCreditAsUsed(_ credit: Credit) async {
        await updateCreditUsage(credit, isUsed: true)
    }
    
    /**
     * Marks a credit as unused
     * 
     * - Parameter credit: The credit to mark as unused
     */
    func markCreditAsUnused(_ credit: Credit) async {
        await updateCreditUsage(credit, isUsed: false)
    }
    
    /**
     * Updates the usage status of a credit
     * 
     * - Parameters:
     *   - credit: The credit to update
     *   - isUsed: Whether the credit is used
     */
    private func updateCreditUsage(_ credit: Credit, isUsed: Bool) async {
        isLoading = true
        error = nil
        
        do {
            let fetchRequest: NSFetchRequest<CreditEntity> = CreditEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", credit.id as CVarArg)
            
            guard let creditEntity = try context.fetch(fetchRequest).first else {
                throw CreditRepositoryError.creditNotFound
            }
            
            if isUsed {
                creditEntity.markAsUsed()
            } else {
                creditEntity.markAsUnused()
            }
            
            try persistenceController.save()
            
            await refreshCredits()
            
            isLoading = false
            
        } catch {
            handleError(error)
        }
    }
    
    /**
     * Gets credits filtered by usage status
     * 
     * - Parameter isUsed: Whether to get used or unused credits
     * - Returns: Array of filtered credits
     */
    func getCredits(isUsed: Bool) -> [Credit] {
        return credits.filter { $0.isUsed == isUsed }
    }
    
    /**
     * Gets credits that are expiring soon
     * 
     * - Returns: Array of expiring credits
     */
    func getExpiringCredits() -> [Credit] {
        return credits.filter { $0.isExpiringSoon && !$0.isUsed }
    }
    
    /**
     * Gets credits by category
     * 
     * - Parameter category: The category to filter by
     * - Returns: Array of credits in the specified category
     */
    func getCredits(by category: String) -> [Credit] {
        return credits.filter { $0.category.localizedCaseInsensitiveContains(category) }
    }
    
    /**
     * Searches credits by name or category
     * 
     * - Parameter query: The search query
     * - Returns: Array of matching credits
     */
    func searchCredits(_ query: String) -> [Credit] {
        guard !query.isEmpty else { return credits }
        
        return credits.filter { credit in
            credit.name.localizedCaseInsensitiveContains(query) ||
            credit.category.localizedCaseInsensitiveContains(query)
        }
    }
    
    /**
     * Gets credits for a specific card
     * 
     * - Parameter cardId: The ID of the card
     * - Returns: Array of credits for the card
     */
    func getCredits(for cardId: UUID) -> [Credit] {
        do {
            let fetchRequest: NSFetchRequest<CreditEntity> = CreditEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "card.id == %@", cardId as CVarArg)
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CreditEntity.name, ascending: true)]
            
            let creditEntities = try context.fetch(fetchRequest)
            return creditEntities.map { $0.toCredit() }
            
        } catch {
            handleError(error)
            return []
        }
    }
    
    /**
     * Processes automatic credit renewals
     * 
     * This method checks all credits and renews those that are due for renewal
     * based on their frequency settings.
     */
    func processAutomaticRenewals() async {
        isLoading = true
        error = nil
        
        do {
            let fetchRequest: NSFetchRequest<CreditEntity> = CreditEntity.fetchRequest()
            let creditEntities = try context.fetch(fetchRequest)
            
            var hasChanges = false
            
            for creditEntity in creditEntities {
                if creditEntity.shouldRenew() {
                    creditEntity.renew()
                    hasChanges = true
                }
            }
            
            if hasChanges {
                try persistenceController.save()
                await refreshCredits()
            }
            
            isLoading = false
            
        } catch {
            handleError(error)
        }
    }
    
    /**
     * Gets summary statistics for all credits
     * 
     * - Returns: Credit summary statistics
     */
    func getCreditSummary() -> CreditSummary {
        let totalCredits = credits.count
        let availableCredits = credits.filter { !$0.isUsed }
        let usedCredits = credits.filter { $0.isUsed }
        let expiringCredits = credits.filter { $0.isExpiringSoon && !$0.isUsed }
        
        let totalValue = credits.reduce(0) { $0 + $1.amount }
        let availableValue = availableCredits.reduce(0) { $0 + $1.amount }
        let usedValue = usedCredits.reduce(0) { $0 + $1.amount }
        
        let utilizationRate = totalValue > 0 ? (usedValue / totalValue) * 100 : 0
        
        return CreditSummary(
            totalCredits: totalCredits,
            availableCredits: availableCredits.count,
            usedCredits: usedCredits.count,
            expiringCredits: expiringCredits.count,
            totalValue: totalValue,
            availableValue: availableValue,
            usedValue: usedValue,
            utilizationRate: utilizationRate
        )
    }
    
    // MARK: - Private Methods
    
    /**
     * Refreshes the credits array from Core Data
     */
    private func refreshCredits() async {
        loadCredits()
    }
    
    /**
     * Handles errors that occur during repository operations
     * 
     * - Parameter error: The error to handle
     */
    private func handleError(_ error: Error) {
        Task { @MainActor in
            self.error = error
            isLoading = false
            
            // Log error for debugging (in production, this might go to a logging service)
            print("CreditRepository error: \(error)")
        }
    }
}

// MARK: - Repository Errors

/**
 * Errors specific to credit repository operations
 */
enum CreditRepositoryError: LocalizedError {
    case creditNotFound
    case invalidCredit
    case saveFailed
    case loadFailed
    
    var errorDescription: String? {
        switch self {
        case .creditNotFound:
            return "Credit not found"
        case .invalidCredit:
            return "Invalid credit data"
        case .saveFailed:
            return "Failed to save credit"
        case .loadFailed:
            return "Failed to load credits"
        }
    }
}

// MARK: - Supporting Types

/**
 * Credit summary statistics
 */
struct CreditSummary {
    let totalCredits: Int
    let availableCredits: Int
    let usedCredits: Int
    let expiringCredits: Int
    let totalValue: Double
    let availableValue: Double
    let usedValue: Double
    let utilizationRate: Double
    
    var formattedTotalValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: totalValue)) ?? "$\(totalValue)"
    }
    
    var formattedAvailableValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: availableValue)) ?? "$\(availableValue)"
    }
    
    var formattedUsedValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: usedValue)) ?? "$\(usedValue)"
    }
}

// MARK: - Reactive Extensions

extension CreditRepository {
    
    /**
     * Publisher for credits changes
     */
    var creditsPublisher: Published<[Credit]>.Publisher {
        $credits
    }
    
    /**
     * Publisher for loading state changes
     */
    var loadingPublisher: Published<Bool>.Publisher {
        $isLoading
    }
    
    /**
     * Publisher for error state changes
     */
    var errorPublisher: Published<Error?>.Publisher {
        $error
    }
}