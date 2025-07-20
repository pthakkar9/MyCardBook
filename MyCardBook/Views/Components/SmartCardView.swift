import SwiftUI

struct SmartCardView: View {
    let card: Card
    let onCardTap: () -> Void
    let onCreditsTap: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Leading accent stripe for category distinction
            Rectangle()
                .fill(card.accentColor)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 8) {
                // Main card area - tappable for editing
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(card.nickname)
                            .font(.title3)
                            .fontWeight(card.isHighValue ? .bold : .semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            // Issuer icon for better distinction
                            Image(systemName: card.issuerIcon)
                                .font(.caption)
                                .foregroundColor(card.accentColor)
                            
                            Text(card.issuer)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(card.cardType)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                .contentShape(Rectangle()) // Make entire area tappable
                .onTapGesture {
                    onCardTap()
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // Credits area - tappable for filtering credits
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(card.credits.count) credits")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if card.availableCredits.count > 0 {
                            Text("\(card.availableCredits.count) available")
                                .font(.caption)
                                .foregroundColor(card.accentColor)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text(card.totalValue, format: .currency(code: "USD"))
                            .font(card.isHighValue ? .title3 : .headline)
                            .fontWeight(.semibold)
                            .foregroundColor(card.isHighValue ? card.accentColor : .primary)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .contentShape(Rectangle()) // Make entire area tappable
                .onTapGesture {
                    onCreditsTap()
                }
            }
            .padding(16)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(card.isHighValue ? card.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .shadow(
            color: card.isHighValue ? card.accentColor.opacity(0.15) : Color.black.opacity(0.1),
            radius: card.isHighValue ? 4 : 2,
            x: 0,
            y: card.isHighValue ? 2 : 1
        )
    }
}

#if DEBUG
struct SmartCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            SmartCardView(
                card: Card.sampleCards[0],
                onCardTap: { print("Card tapped") },
                onCreditsTap: { print("Credits tapped") }
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .previewLayout(.sizeThatFits)
    }
}
#endif