//
//  SwiftData.swift
//  SwiftSamples
//
//  Created by Roi Jacob on 11/26/24.
//

import SwiftData


@Model
class Contacts {
    var name: String
    var number: String
    
    init(name: String, number: String) {
        self.name = name
        self.number = number
    }
}


@MainActor
final class SharedDatabase {
    let container: ModelContainer
    let context: ModelContext
    
    init(useInMemoryStore: Bool = false) throws {
        /// Add configuration
        let configuration = ModelConfiguration(isStoredInMemoryOnly: useInMemoryStore)
        
        /// Create the configured container
        container = try ModelContainer(
            for: Contacts.self,
            configurations: configuration
        )
        
        /// Contextualize model container
        context = ModelContext(container)
    }
}
