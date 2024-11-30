//
//  SwiftSamplesApp.swift
//  SwiftSamples
//
//  Created by Roi Jacob on 11/26/24.
//

import SwiftUI
import SwiftData

@main
struct SwiftSamplesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: GameMoney.self)
        }
    }
}
