import SwiftUI

struct CardsView: View {
    @EnvironmentObject var viewModel: CardsViewModel
    @State private var showingAddCard = false
    @State private var searchText = ""
    @State private var editingCard: Card? = nil
    
    // Navigation bindings from MainTabView
    @Binding var selectedTab: Int
    @Binding var cardFilter: CardSpecificFilter?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText, placeholder: "Search cards...")
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                if viewModel.cards.isEmpty {
                    EmptyCardsView {
                        showingAddCard = true
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredCards) { card in
                                SmartCardView(
                                    card: card,
                                    onCardTap: {
                                        editingCard = card
                                    },
                                    onCreditsTap: {
                                        // Navigate to Credits filtered by this card
                                        cardFilter = CardSpecificFilter(cardId: card.id, cardNickname: card.nickname)
                                        selectedTab = 2 // Credits tab
                                    }
                                )
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("My Cards")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddCard = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCard) {
                AddCardView { card in
                    viewModel.addCard(card)
                    showingAddCard = false
                }
            }
            .sheet(item: $editingCard) { card in
                EditCardView(card: card) { updatedCard in
                    viewModel.updateCard(updatedCard)
                    editingCard = nil
                } onDelete: {
                    viewModel.deleteCard(card)
                    editingCard = nil
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
    
    private var filteredCards: [Card] {
        if searchText.isEmpty {
            return viewModel.cards
        } else {
            return viewModel.cards.filter { card in
                card.nickname.localizedCaseInsensitiveContains(searchText) ||
                card.cardType.localizedCaseInsensitiveContains(searchText) ||
                card.issuer.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search..."
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button("Clear") {
                    text = ""
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct EmptyCardsView: View {
    let onAddCard: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "creditcard")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Text("No Cards Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add your first credit card to start tracking your benefits")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onAddCard) {
                Text("Add Your First Card")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct AddCardView: View {
    let onSave: (Card) -> Void
    @State private var nickname = ""
    @State private var selectedCardType = ""
    @State private var placeholderIndex = 0
    @Environment(\.dismiss) private var dismiss
    private let cardDatabaseService = CardDatabaseService.shared
    
    private let placeholderSuggestions = [
        "My Gold Card",
        "Sarah's Business Card", 
        "Spouse's Travel Card",
        "Business Expenses Card",
        "My Second Gold Card",
        "Partner's Card",
        "Family Card"
    ]
    
    private var cardTypes: [String] {
        cardDatabaseService.getAvailableCardTypes()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Card Details")) {
                    TextField("Nickname (e.g., \(placeholderSuggestions[placeholderIndex]))", text: $nickname)
                    
                    Picker("Card Type", selection: $selectedCardType) {
                        ForEach(cardTypes, id: \.self) { cardType in
                            Text(cardType)
                                .tag(cardType)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(footer: Text("You can add multiple cards of the same type with different nicknames. Add your cards, your spouse's cards, business cards, or family members' cards.")) {
                    Button("Save Card") {
                        let cardInfo = cardDatabaseService.getCardInfo(selectedCardType)
                        let credits = cardDatabaseService.getCreditsForCard(selectedCardType)
                        
                        let card = Card(
                            cardType: selectedCardType,
                            nickname: nickname.isEmpty ? selectedCardType : nickname,
                            issuer: cardInfo?.issuer ?? "Unknown",
                            network: cardInfo?.network ?? "Unknown",
                            variant: cardInfo?.variant ?? "Personal",
                            credits: credits
                        )
                        onSave(card)
                    }
                    .disabled(nickname.isEmpty)
                }
            }
            .navigationTitle("Add Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Rotate placeholder suggestion every time the view appears
                placeholderIndex = Int.random(in: 0..<placeholderSuggestions.count)
                
                // Set initial card type if empty
                if selectedCardType.isEmpty && !cardTypes.isEmpty {
                    selectedCardType = cardTypes.first ?? ""
                }
            }
        }
    }
    
}

struct CardsView_Previews: PreviewProvider {
    static var previews: some View {
        CardsView(selectedTab: .constant(1), cardFilter: .constant(nil))
            .environmentObject(CardsViewModel())
    }
}