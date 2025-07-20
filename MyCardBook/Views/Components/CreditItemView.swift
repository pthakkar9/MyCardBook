import SwiftUI

struct CreditItemView: View {
    let credit: Credit
    let cardNickname: String?
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            Image(systemName: credit.categoryIcon)
                .foregroundColor(colorForCategory(credit.category))
                .frame(width: 24, height: 24)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(credit.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack {
                    Text(credit.formattedAmount)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(credit.frequency)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Show card association if provided and not already filtering by card
                    if let cardNickname = cardNickname {
                        Text("•")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(cardNickname)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .lineLimit(1)
                    }
                }
                
                if credit.isExpiringSoon && !credit.isUsed {
                    Text("Expires in \(daysUntilExpiration(credit.expirationDate)) days")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            // Status and Toggle
            VStack(spacing: 4) {
                Button(action: onToggle) {
                    Image(systemName: credit.isUsed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(credit.isUsed ? .green : .secondary)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Mark \(credit.name) as \(credit.isUsed ? "unused" : "used")")
                
                if credit.isUsed, let _ = credit.usedAt {
                    Text("Used")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    private func colorForCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "dining":
            return .red
        case "travel":
            return .blue
        case "shopping":
            return .purple
        case "entertainment":
            return .orange
        case "wellness":
            return .green
        case "transportation":
            return .teal
        default:
            return .gray
        }
    }
    
    private func daysUntilExpiration(_ date: Date) -> Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: date).day ?? 0
        return max(0, days)
    }
}

struct CreditItemView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            CreditItemView(
                credit: Credit(
                    name: "Dining Credit",
                    amount: 10.0,
                    category: "Dining",
                    frequency: "Monthly"
                ),
                cardNickname: "My Gold Card",
                onToggle: {}
            )
            
            CreditItemView(
                credit: Credit(
                    name: "Travel Credit",
                    amount: 50.0,
                    category: "Travel",
                    frequency: "Annual",
                    isUsed: true,
                    usedAt: Date()
                ),
                cardNickname: nil,
                onToggle: {}
            )
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .previewLayout(.sizeThatFits)
    }
}