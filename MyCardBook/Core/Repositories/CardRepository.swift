import Foundation
import CoreData
import Combine

/**
 * CardRepository provides a clean interface for Card data operations.
 * 
 * This repository implements the Repository pattern to:
 * - Abstract Core Data operations from business logic
 * - Provide type-safe operations for Card entities
 * - Handle data validation and error management
 * - Support reactive programming with Combine
 * - Maintain privacy-first data handling
 *
 * Architecture:
 * - Uses PersistenceController for Core Data access
 * - Converts between Core Data entities and Swift models
 * - Provides both synchronous and asynchronous operations
 * - Implements proper error handling and validation
 */
class CardRepository: ObservableObject {
    
    // MARK: - Properties
    
    private let persistenceController: PersistenceController
    private let context: NSManagedObjectContext
    
    /// Published property for reactive UI updates
    @Published var cards: [Card] = []
    
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
        loadCardsSync()
    }
    
    /**
     * Synchronously loads cards during initialization
     */
    private func loadCardsSync() {
        do {
            let fetchRequest: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CardEntity.addedAt, ascending: false)]
            
            let cardEntities = try context.fetch(fetchRequest)
            cards = cardEntities.map { $0.toCard() }
        } catch {
            print("Failed to load cards: \(error)")
            cards = []
        }
    }
    
    
    // MARK: - Public Interface
    
    /**
     * Loads all cards from Core Data
     */
    func loadCards() {
        Task { @MainActor in
            isLoading = true
            error = nil
            
            do {
                let fetchRequest: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
                fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CardEntity.addedAt, ascending: false)]
                
                let cardEntities = try context.fetch(fetchRequest)
                cards = cardEntities.map { $0.toCard() }
                
                isLoading = false
            } catch {
                handleError(error)
            }
        }
    }
    
    /**
     * Adds a new card to the repository
     * 
     * - Parameter card: The card to add
     * - Returns: The added card with updated ID
     */
    @discardableResult
    func addCard(_ card: Card) async -> Card? {
        await MainActor.run {
            isLoading = true
            error = nil
        }

        do {
            let cardEntity = CardEntity(context: context)
            cardEntity.update(from: card)

            // Add credits to the card
            for credit in card.credits {
                let creditEntity = CreditEntity(context: context)
                creditEntity.update(from: credit)
                cardEntity.addToCredits(creditEntity)
            }

            try persistenceController.save()

            // Reload to get the updated card
            await refreshCards()

            await MainActor.run {
                isLoading = false
            }
            return cardEntity.toCard()

        } catch {
            handleError(error)
            return nil
        }
    }
    
    /**
     * Updates an existing card in the repository
     * 
     * - Parameter card: The card to update
     * - Returns: The updated card
     */
    @discardableResult
    func updateCard(_ card: Card) async -> Card? {
        isLoading = true
        error = nil
        
        do {
            let fetchRequest: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", card.id as CVarArg)
            
            guard let cardEntity = try context.fetch(fetchRequest).first else {
                throw RepositoryError.cardNotFound
            }
            
            cardEntity.update(from: card)
            
            // Update credits (this is a simplified approach - in production you'd want more sophisticated sync)
            cardEntity.removeFromCredits(cardEntity.credits ?? NSSet())
            
            for credit in card.credits {
                let creditEntity = CreditEntity(context: context)
                creditEntity.update(from: credit)
                cardEntity.addToCredits(creditEntity)
            }
            
            try persistenceController.save()
            
            await refreshCards()
            
            isLoading = false
            return cardEntity.toCard()
            
        } catch {
            handleError(error)
            return nil
        }
    }
    
    /**
     * Deletes a card from the repository
     * 
     * - Parameter card: The card to delete
     */
    func deleteCard(_ card: Card) async {
        isLoading = true
        error = nil
        
        do {
            let fetchRequest: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", card.id as CVarArg)
            
            guard let cardEntity = try context.fetch(fetchRequest).first else {
                throw RepositoryError.cardNotFound
            }
            
            context.delete(cardEntity)
            try persistenceController.save()
            
            await refreshCards()
            
            isLoading = false
            
        } catch {
            handleError(error)
        }
    }
    
    /**
     * Finds a card by ID
     * 
     * - Parameter id: The card ID to search for
     * - Returns: The card if found, nil otherwise
     */
    func findCard(by id: UUID) -> Card? {
        return cards.first { $0.id == id }
    }
    
    /**
     * Searches cards by various criteria
     * 
     * - Parameter query: The search query
     * - Returns: Array of matching cards
     */
    func searchCards(_ query: String) -> [Card] {
        guard !query.isEmpty else { return cards }
        
        return cards.filter { card in
            card.nickname.localizedCaseInsensitiveContains(query) ||
            card.cardType.localizedCaseInsensitiveContains(query) ||
            card.issuer.localizedCaseInsensitiveContains(query)
        }
    }
    
    /**
     * Gets cards by issuer
     * 
     * - Parameter issuer: The issuer to filter by
     * - Returns: Array of cards from the specified issuer
     */
    func getCards(by issuer: String) -> [Card] {
        return cards.filter { $0.issuer.localizedCaseInsensitiveContains(issuer) }
    }
    
    // MARK: - Private Methods
    
    /**
     * Refreshes the cards array from Core Data
     */
    private func refreshCards() async {
        loadCards()
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
            print("CardRepository error: \(error)")
        }
    }
}

// MARK: - Repository Errors

/**
 * Errors specific to repository operations
 */
enum RepositoryError: LocalizedError {
    case cardNotFound
    case invalidCard
    case saveFailed
    case loadFailed
    
    var errorDescription: String? {
        switch self {
        case .cardNotFound:
            return "Card not found"
        case .invalidCard:
            return "Invalid card data"
        case .saveFailed:
            return "Failed to save card"
        case .loadFailed:
            return "Failed to load cards"
        }
    }
}

// MARK: - Reactive Extensions

extension CardRepository {
    
    /**
     * Publisher for cards changes
     */
    var cardsPublisher: Published<[Card]>.Publisher {
        $cards
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