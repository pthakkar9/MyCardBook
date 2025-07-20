import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var creditsFilter: CreditFilter? = nil
    @State private var cardFilter: CardSpecificFilter? = nil
    @StateObject private var cardsViewModel = CardsViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(selectedTab: $selectedTab, creditsFilter: $creditsFilter)
                .environmentObject(cardsViewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            CardsView(selectedTab: $selectedTab, cardFilter: $cardFilter)
                .environmentObject(cardsViewModel)
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("Cards")
                }
                .tag(1)
            
            CreditsView(externalFilter: creditsFilter, cardFilter: $cardFilter)
                .environmentObject(cardsViewModel)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Credits")
                }
                .tag(2)
            
            SettingsView()
                .environmentObject(cardsViewModel)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .onChange(of: selectedTab) { oldValue, newValue in
            // Clear filters when navigating away from Credits tab
            if oldValue == 2 && newValue != 2 {
                creditsFilter = nil
                cardFilter = nil
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}