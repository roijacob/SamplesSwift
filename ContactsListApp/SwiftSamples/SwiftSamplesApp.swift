//
//  SwiftSamplesApp.swift
//  SwiftSamples
//
//  Created by Roi Jacob on 11/26/24.
//

import SwiftUI
import AppIntents


@main
struct SwiftSamplesApp: App {
    let database: SharedDatabase
    
    init() {
        // Initialize the database
        do {
            database = try SharedDatabase()
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
        }
        
        let sharedDB = database
        
        // Use the separate variable to avoid capturing 'self'
        AppDependencyManager.shared.add(dependency: sharedDB)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Contacts.self)
        }
    }
}
