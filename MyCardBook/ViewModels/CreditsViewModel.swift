import Foundation
import SwiftUI
import Combine

@MainActor
class CreditsViewModel: ObservableObject {
    @Published var credits: [Credit] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedFilter: CreditFilter = .all
    
    var cardsViewModel: CardsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(cardsViewModel: CardsViewModel? = nil) {
        self.cardsViewModel = cardsViewModel ?? CardsViewModel()
        setupBindings()
        setupSearchAndFilter()
        
        // Update credits after initialization
        DispatchQueue.main.async { [weak self] in
            self?.updateCredits()
        }
    }
    
    private func setupBindings() {
        cardsViewModel.$cards
            .receive(on: RunLoop.main)
            .sink { [weak self] cards in
                self?.updateCredits()
            }
            .store(in: &cancellables)
    }
    
    private func setupSearchAndFilter() {
        Publishers.CombineLatest($searchText, $selectedFilter)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _, _ in
                self?.filterCredits()
            }
            .store(in: &cancellables)
    }
    
    private func updateCredits() {
        credits = cardsViewModel.cards.flatMap { $0.credits }
    }
    
    private func filterCredits() {
        // Implementation for filtering credits based on search and filter
        // Will be expanded with more filtering options
    }
    
    func filteredCredits(_ filter: CreditFilter) -> [Credit] {
        let allCredits = cardsViewModel.cards.flatMap { $0.credits }
        
        switch filter {
        case .all:
            return allCredits
        case .available:
            return allCredits.filter { !$0.isUsed }
        case .used:
            return allCredits.filter { $0.isUsed }
        case .expiring:
            return allCredits.filter { $0.isExpiringSoon && !$0.isUsed }
        }
    }
    
    func toggleCredit(_ credit: Credit) {
        // Find the card containing this credit and update it
        for (cardIndex, card) in cardsViewModel.cards.enumerated() {
            if let creditIndex = card.credits.firstIndex(where: { $0.id == credit.id }) {
                cardsViewModel.cards[cardIndex].credits[creditIndex].isUsed.toggle()
                cardsViewModel.cards[cardIndex].credits[creditIndex].usedAt = cardsViewModel.cards[cardIndex].credits[creditIndex].isUsed ? Date() : nil
                break
            }
        }
    }
    
    func refresh() async {
        isLoading = true
        await cardsViewModel.refresh()
        updateCredits()
        isLoading = false
    }
}

enum CreditFilter: String, CaseIterable {
    case all = "All"
    case available = "Available"
    case used = "Used"
    case expiring = "Expiring"
    
    var displayName: String {
        return self.rawValue
    }
}

/// Special filter type for filtering by specific card
struct CardSpecificFilter {
    let cardId: UUID
    let cardNickname: String
}