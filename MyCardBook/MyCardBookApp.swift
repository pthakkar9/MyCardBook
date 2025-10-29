//
//  MyCardBookApp.swift
//  MyCardBook
//
//  Created by Parva Thakkar (developer) on 7/14/25.
//

import SwiftUI
import Combine

@main
struct MyCardBookApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var cardsViewModel = CardsViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .environmentObject(cardsViewModel)
                .onAppear {
                    // Process automatic credit renewals ONLY when app first launches
                    // Credits should not be touched when adding cards, dismissing sheets, etc.
                    Task {
                        await cardsViewModel.refresh()
                    }
                }
        }
    }
}
