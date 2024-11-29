//
//  ContentView.swift
//  SwiftSamples
//
//  Created by Roi Jacob on 11/26/24.
//

import SwiftUI
import SwiftData
import AppIntents


struct ContentView: View {
    @Query var allFriends: [Contacts]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        if !allFriends.isEmpty {
            List {
                ForEach(allFriends) { friend in
                    Text("\(friend.name)")
                }
                .onDelete(perform: deleteFriends)
            }
        } else {
            Text("Add Friends")
        }
    }
    
    private func deleteFriends(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(allFriends[index])
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Error deleting friend: \(error.localizedDescription)")
            }
        }
    }
}


#Preview {
    ContentView()
}
