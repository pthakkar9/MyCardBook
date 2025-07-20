import SwiftUI

struct CreditCardView: View {
    let card: Card
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            // Leading accent stripe for category distinction
            Rectangle()
                .fill(card.accentColor)
                .frame(width: 4)
            
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
                
                HStack {
                    Text("\(card.credits.count) credits")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(card.totalValue, format: .currency(code: "USD"))
                        .font(card.isHighValue ? .title3 : .headline)
                        .fontWeight(.semibold)
                        .foregroundColor(card.isHighValue ? card.accentColor : .primary)
                }
                
                // Available credits indicator
                HStack {
                    if card.availableCredits.count > 0 {
                        Text("\(card.availableCredits.count) available")
                            .font(.caption)
                            .foregroundColor(card.accentColor)
                    }
                    
                    Spacer()
                }
            }
            .padding(16)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isSelected ? Color.accentColor : 
                    (card.isHighValue ? card.accentColor.opacity(0.3) : Color.clear), 
                    lineWidth: isSelected ? 2 : 1
                )
        )
        .shadow(
            color: card.isHighValue ? card.accentColor.opacity(0.15) : Color.black.opacity(0.1),
            radius: card.isHighValue ? 4 : 2,
            x: 0,
            y: card.isHighValue ? 2 : 1
        )
    }
}

struct CreditCardView_Previews: PreviewProvider {
    static var previews: some View {
        #if DEBUG
        VStack(spacing: 16) {
            CreditCardView(card: Card.sampleCards[0], isSelected: false)
            CreditCardView(card: Card.sampleCards[1], isSelected: true)
        }
        .padding()
        .background(Color(.systemBackground))
        .previewLayout(.sizeThatFits)
        #else
        Text("Preview not available in production")
        #endif
    }
}