import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var cardsViewModel: CardsViewModel
    @Binding var selectedTab: Int
    @Binding var creditsFilter: CreditFilter?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Summary Cards with Navigation
                    SummaryCardsView(cardsViewModel: cardsViewModel, selectedTab: $selectedTab, creditsFilter: $creditsFilter)
                }
                .padding(16)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await cardsViewModel.refresh()
            }
        }
    }
}

struct SummaryCardsView: View {
    @ObservedObject var cardsViewModel: CardsViewModel
    @Binding var selectedTab: Int
    @Binding var creditsFilter: CreditFilter?
    
    private var summary: DashboardSummary {
        let cards = cardsViewModel.cards
        let allCredits = cards.flatMap { $0.credits }
        let availableCredits = allCredits.filter { !$0.isUsed }
        let usedCredits = allCredits.filter { $0.isUsed }
        
        let totalAvailableValue = availableCredits.reduce(0) { $0 + $1.amount }
        let totalUsedValue = usedCredits.reduce(0) { $0 + $1.amount }
        let totalValue = totalAvailableValue + totalUsedValue
        
        let expiringCount = availableCredits.filter { $0.isExpiringSoon }.count
        let utilizationPercentage = totalValue > 0 ? (totalUsedValue / totalValue) * 100 : 0
        
        return DashboardSummary(
            totalCards: cards.count,
            totalCredits: allCredits.count,
            totalAvailableValue: totalAvailableValue,
            totalUsedValue: totalUsedValue,
            expiringCreditsCount: expiringCount,
            utilizationPercentage: utilizationPercentage
        )
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Overview")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                SummaryCardView(
                    title: "Total Cards",
                    value: "\(summary.totalCards)",
                    color: .blue
                )
                .onTapGesture {
                    selectedTab = 1 // Navigate to Cards tab
                }
                
                SummaryCardView(
                    title: "Total Credits",
                    value: "\(summary.totalCredits)",
                    color: .green
                )
                .onTapGesture {
                    selectedTab = 2 // Navigate to Credits tab
                }
                
                SummaryCardView(
                    title: "Available Value",
                    value: summary.formattedAvailableValue,
                    color: .purple
                )
                .onTapGesture {
                    creditsFilter = .available // Set filter to Available
                    selectedTab = 2 // Navigate to Credits tab
                }
                
                SummaryCardView(
                    title: "Expiring Soon",
                    value: "\(summary.expiringCreditsCount) credits",
                    color: .orange
                )
                .onTapGesture {
                    creditsFilter = .expiring // Set filter to Expiring
                    selectedTab = 2 // Navigate to Credits tab
                }
            }
        }
    }
}

struct SummaryCardView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}



struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(selectedTab: .constant(0), creditsFilter: .constant(nil))
            .environmentObject(CardsViewModel())
    }
}