import SwiftUI

struct EditCardView: View {
    let card: Card
    let onSave: (Card) -> Void
    let onDelete: () -> Void
    
    @State private var nickname: String
    @State private var showingDeleteAlert = false
    @Environment(\.dismiss) private var dismiss
    
    init(card: Card, onSave: @escaping (Card) -> Void, onDelete: @escaping () -> Void) {
        self.card = card
        self.onSave = onSave
        self.onDelete = onDelete
        self._nickname = State(initialValue: card.nickname)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Card Details")) {
                    TextField("Nickname", text: $nickname)
                    
                    Text(card.cardType)
                        .foregroundColor(.secondary)
                    
                    Text(card.issuer)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Credits")) {
                    ForEach(card.credits) { credit in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(credit.name)
                                    .font(.subheadline)
                                Text(credit.formattedAmount)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if credit.isUsed {
                                Text("Used")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Available")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Delete Card", role: .destructive) {
                        showingDeleteAlert = true
                    }
                }
            }
            .navigationTitle("Edit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        var updatedCard = card
                        updatedCard.nickname = nickname.isEmpty ? card.cardType : nickname
                        onSave(updatedCard)
                    }
                    .disabled(nickname.isEmpty)
                }
            }
            .alert("Delete Card", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    onDelete()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete '\(card.nickname)'? This action cannot be undone.")
            }
        }
    }
}

#if DEBUG
struct EditCardView_Previews: PreviewProvider {
    static var previews: some View {
        EditCardView(
            card: Card.sampleCards[0],
            onSave: { _ in },
            onDelete: { }
        )
    }
}
#endif