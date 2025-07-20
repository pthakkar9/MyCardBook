import Foundation
import SwiftUI
import Combine

/**
 * CardsViewModel manages the presentation logic for credit cards.
 * 
 * This ViewModel implements the MVVM pattern to:
 * - Provide a clean interface between Views and Core Data
 * - Handle UI state management and user interactions
 * - Support reactive programming with Combine
 * - Maintain separation of concerns
 *
 * Architecture:
 * - Uses CardRepository for data operations
 * - Publishes UI state changes via @Published properties
 * - Handles search and filtering logic
 * - Manages loading states and error handling
 */
@MainActor
class CardsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var cards: [Card] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedFilter: CardFilter = .all
    
    // MARK: - Private Properties
    
    private let cardRepository: CardRepository
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /**
     * Initializes the ViewModel with a card repository
     * 
     * - Parameter cardRepository: The repository for card data operations
     */
    init(cardRepository: CardRepository = CardRepository()) {
        self.cardRepository = cardRepository
        
        setupBindings()
        setupSearchAndFilter()
    }
    
    // MARK: - Setup Methods
    
    /**
     * Sets up reactive bindings between repository and ViewModel
     */
    private func setupBindings() {
        // Bind repository cards to ViewModel
        cardRepository.$cards
            .receive(on: RunLoop.main)
            .assign(to: \.cards, on: self)
            .store(in: &cancellables)
        
        // Bind repository loading state
        cardRepository.$isLoading
            .receive(on: RunLoop.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        // Bind repository errors
        cardRepository.$error
            .receive(on: RunLoop.main)
            .map { $0?.localizedDescription }
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
    }
    
    /**
     * Sets up search and filter reactive streams
     */
    private func setupSearchAndFilter() {
        Publishers.CombineLatest($searchText, $selectedFilter)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _, _ in
                self?.filterCards()
            }
            .store(in: &cancellables)
    }
    
    /**
     * Applies current search and filter criteria
     */
    private func filterCards() {
        // Filter logic is handled by computed properties in the Views
        // This method can be extended for more complex filtering
    }
    
    // MARK: - Public Interface
    
    /**
     * Adds a new card to the repository
     * 
     * - Parameter card: The card to add
     */
    func addCard(_ card: Card) {
        Task {
            await cardRepository.addCard(card)
        }
    }
    
    /**
     * Deletes a card from the repository
     * 
     * - Parameter card: The card to delete
     */
    func deleteCard(_ card: Card) {
        Task {
            await cardRepository.deleteCard(card)
        }
    }
    
    /**
     * Updates an existing card in the repository
     * 
     * - Parameter card: The card to update
     */
    func updateCard(_ card: Card) {
        Task {
            await cardRepository.updateCard(card)
        }
    }
    
    /**
     * Imports multiple cards from external data
     * 
     * - Parameter importedCards: Array of cards to import
     */
    func importCards(_ importedCards: [Card]) {
        Task {
            for card in importedCards {
                await cardRepository.addCard(card)
            }
        }
    }
    
    
    /**
     * Refreshes the cards from the repository
     */
    func refresh() async {
        cardRepository.loadCards()
    }
    
    /**
     * Searches cards based on the current search text
     * 
     * - Returns: Array of cards matching the search criteria
     */
    func searchResults() -> [Card] {
        if searchText.isEmpty {
            return filteredCards()
        }
        return cardRepository.searchCards(searchText)
    }
    
    /**
     * Gets cards filtered by the selected filter
     * 
     * - Returns: Array of filtered cards
     */
    func filteredCards() -> [Card] {
        return cards
    }
    
    /**
     * Gets cards by issuer
     * 
     * - Parameter issuer: The issuer to filter by
     * - Returns: Array of cards from the specified issuer
     */
    func getCards(by issuer: String) -> [Card] {
        return cardRepository.getCards(by: issuer)
    }
    
    /**
     * Clears any error messages
     */
    func clearError() {
        errorMessage = nil
    }
}

enum CardFilter: String, CaseIterable {
    case all = "All"
    
    var displayName: String {
        return self.rawValue
    }
}