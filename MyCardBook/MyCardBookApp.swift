//
//  MyCardBookApp.swift
//  MyCardBook
//
//  Created by Parva Thakkar (developer) on 7/14/25.
//

import SwiftUI

@main
struct MyCardBookApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
