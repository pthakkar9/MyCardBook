import Foundation
import SwiftUI
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var summary: DashboardSummary = DashboardSummary(
        totalCards: 0,
        totalCredits: 0,
        totalAvailableValue: 0.0,
        totalUsedValue: 0.0,
        expiringCreditsCount: 0,
        utilizationPercentage: 0.0
    )
    
    @Published var expiringCredits: [Credit] = []
    @Published var recentActivities: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var cardsViewModel: CardsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(cardsViewModel: CardsViewModel) {
        self.cardsViewModel = cardsViewModel
        setupBindings()
        
        // Calculate summary immediately since we have the shared cardsViewModel
        calculateSummary()
    }
    
    private func setupBindings() {
        cardsViewModel.$cards
            .receive(on: RunLoop.main)
            .sink { [weak self] cards in
                self?.calculateSummary()
                self?.updateExpiringCredits()
            }
            .store(in: &cancellables)
    }
    
    private func calculateSummary() {
        let cards = cardsViewModel.cards
        let allCredits = cards.flatMap { $0.credits }
        let availableCredits = allCredits.filter { !$0.isUsed }
        let usedCredits = allCredits.filter { $0.isUsed }
        
        let totalAvailableValue = availableCredits.reduce(0) { $0 + $1.amount }
        let totalUsedValue = usedCredits.reduce(0) { $0 + $1.amount }
        let totalValue = totalAvailableValue + totalUsedValue
        
        let expiringCount = availableCredits.filter { $0.isExpiringSoon }.count
        let utilizationPercentage = totalValue > 0 ? (totalUsedValue / totalValue) * 100 : 0
        
        summary = DashboardSummary(
            totalCards: cards.count,
            totalCredits: allCredits.count,
            totalAvailableValue: totalAvailableValue,
            totalUsedValue: totalUsedValue,
            expiringCreditsCount: expiringCount,
            utilizationPercentage: utilizationPercentage
        )
    }
    
    private func updateExpiringCredits() {
        let allCredits = cardsViewModel.cards.flatMap { $0.credits }
        expiringCredits = allCredits.filter { $0.isExpiringSoon && !$0.isUsed }
            .sorted { $0.expirationDate < $1.expirationDate }
    }
    
    func refresh() async {
        isLoading = true
        await cardsViewModel.refresh()
        calculateSummary()
        updateExpiringCredits()
        updateRecentActivities()
        isLoading = false
    }
    
    private func updateRecentActivities() {
        recentActivities = [
            "Added Chase Sapphire Preferred",
            "Used Dining Credit - $10.00",
            "Uber Credit expires in 5 days",
            "Travel Credit renewed"
        ]
    }
}