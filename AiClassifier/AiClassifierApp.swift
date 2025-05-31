//
//  AiClassifierApp.swift
//  AiClassifier
//
//  Created by Sharath Badam on 5/30/25.
//

import SwiftUI

@main
struct AiClassifierApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
