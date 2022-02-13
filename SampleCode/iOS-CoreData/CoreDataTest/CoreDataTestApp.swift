//
//  CoreDataTestApp.swift
//  CoreDataTest
//
//  Created by Michael Santos on 2/1/22.
//

import SwiftUI

@main
struct CoreDataTestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainMenuView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
