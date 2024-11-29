//
//  ContentView.swift
//  SwiftSamples
//
//  Created by Roi Jacob on 11/26/24.
//

import SwiftUI
import SwiftData


@Model
class Friends {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}


struct ContentView: View {
    @Query(sort: \Friends.name) var allFriends: [Friends]
    @State private var selectedFriend: Friends?
    
    var body: some View {
        NavigationStack(root: {
            
            // (root:) is the view to show when the (path:) is empty or not defined
            List(allFriends, rowContent: { friend in
                Button(action: {
                    selectedFriend = friend
                }, label: {
                    Text(friend.name)
                })
            })
            .navigationTitle("My Friends")
            
            // Tracks if the variable becomes non-nil
            .sheet(item: $selectedFriend, content: SheetView.init)
        })
    }
}


struct SheetView: View {
    @Bindable var selectedFriend: Friends
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var editedName = ""
    
    // Initialize @State property with initial value
    init(selectedFriend: Friends) {
        
        // Initialize the source data
        self.selectedFriend = selectedFriend
        
        // Extract the specific data
        _editedName = State(initialValue: selectedFriend.name)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, content: {
                Text("Hello: \(selectedFriend.name)")
                TextField("Hello", text: $editedName)
                    .multilineTextAlignment(.center)
                    .frame(width: 200)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue.opacity(0.5))
                    )
            })
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading, content: {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                })
                ToolbarItem(placement: .topBarTrailing, content: {
                    Button(action: {
                        selectedFriend.name = editedName
                        try? modelContext.save()
                        dismiss()
                    }, label: {
                        Text("Save")
                    })
                })
            })
        }
    }
}


struct SampleData: PreviewModifier {
    
    static func makeSharedContext() throws -> ModelContainer {
        let samples = [
            Friends(name: "Isabel"),
            Friends(name: "John"),
            Friends(name: "Sarah"),
            Friends(name: "Mike")
        ]
        
        let container = try ModelContainer(for: Friends.self)
        
        // Check if there's existing data
        let descriptor = FetchDescriptor<Friends>()
        let existingCount = try container.mainContext.fetchCount(descriptor)
        
        // Only insert if there's no existing data
        if existingCount == 0 {
            for sample in samples {
                container.mainContext.insert(sample)
            }
        }
        
        return container
    }

    func body(content: Content, context: ModelContainer) -> some View {
        content
            .modelContainer(context)
    }
}


#Preview(traits: .modifier(SampleData())) {
    ContentView()
}
