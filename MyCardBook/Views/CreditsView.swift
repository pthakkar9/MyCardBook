import SwiftUI

struct CreditsView: View {
    @EnvironmentObject var cardsViewModel: CardsViewModel
    @StateObject private var viewModel = CreditsViewModel()
    @State private var selectedFilter: CreditFilter = .all
    @State private var searchText = ""
    
    // Optional external filter for navigation from Dashboard
    var externalFilter: CreditFilter?
    // Optional card-specific filter for navigation from Cards tab
    @Binding var cardFilter: CardSpecificFilter?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText, placeholder: "Search credits...")
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                // Card Filter Indicator (if filtering by specific card)
                if let currentCardFilter = cardFilter {
                    HStack {
                        Text("Showing credits for: \(currentCardFilter.cardNickname)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Show All Credits") {
                            cardFilter = nil
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                
                // Filter Pills
                FilterPillsView(selectedFilter: $selectedFilter)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                if filteredCredits.isEmpty {
                    EmptyCreditsView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredCredits) { credit in
                                CreditItemView(
                                    credit: credit,
                                    cardNickname: cardFilter == nil ? getCardNickname(for: credit) : nil
                                ) {
                                    viewModel.toggleCredit(credit)
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle(cardFilter != nil ? "\(cardFilter!.cardNickname) Credits" : "Credits")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refresh()
            }
        }
        .onAppear {
            if viewModel.cardsViewModel !== cardsViewModel {
                viewModel.cardsViewModel = cardsViewModel
            }
            
            // Apply external filter if provided, otherwise reset to .all
            if let externalFilter = externalFilter {
                selectedFilter = externalFilter
            } else {
                selectedFilter = .all
            }
        }
    }
    
    private var filteredCredits: [Credit] {
        var baseCredits = viewModel.filteredCredits(selectedFilter)
        
        // Apply card-specific filter if provided and card still exists
        if let cardFilter = cardFilter {
            if let card = cardsViewModel.cards.first(where: { $0.id == cardFilter.cardId }) {
                baseCredits = card.credits
            } else {
                // Card was deleted, return empty array
                return []
            }
        }
        
        if searchText.isEmpty {
            return baseCredits
        } else {
            return baseCredits.filter { credit in
                credit.name.localizedCaseInsensitiveContains(searchText) ||
                credit.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    /// Helper function to get card nickname for a credit when not filtering by specific card
    private func getCardNickname(for credit: Credit) -> String? {
        // Find the card that contains this credit
        let card = cardsViewModel.cards.first { card in
            card.credits.contains { $0.id == credit.id }
        }
        return card?.nickname
    }
}

struct FilterPillsView: View {
    @Binding var selectedFilter: CreditFilter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(CreditFilter.allCases, id: \.self) { filter in
                    FilterPill(
                        title: filter.displayName,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyCreditsView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "list.bullet")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Text("No Credits Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add some credit cards to start tracking your benefits")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView(cardFilter: .constant(nil))
            .environmentObject(CardsViewModel())
    }
}