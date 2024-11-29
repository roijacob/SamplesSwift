//
//  TodoRowView.swift
//  SwiftSamples
//
//  Created by Roi Jacob on 11/26/24.
//

import SwiftUI
import WidgetKit

struct TodoRowView: View {
    @Bindable var todo: Todo
    
    /// View Properties
    @FocusState private var isActive: Bool
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var phase
    
    var body: some View {
        HStack(spacing: 8) {
            
            /// Checkmarking Button
            if !isActive && !todo.task.isEmpty { /// If not being edited and has some text
                Button(action: {
                    todo.isCompleted.toggle()
                     try? context.save()  // Ensure changes are saved to disk
                    WidgetCenter.shared.reloadAllTimelines()
                }, label: {
                    Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .padding(3)
                        .contentShape(.rect) /// Hit testing shape
                        .foregroundStyle(todo.isCompleted ? .gray : .accentColor)
                        .contentTransition(.symbolEffect(.replace))
                })
            }
            
            /// Task Contents
            TextField("Record Video", text: $todo.task)
                .strikethrough(todo.isCompleted)
                .foregroundStyle(todo.isCompleted ? .gray : .primary)
                .focused($isActive)

            /// Priority Menu Button (For Updating)
            if !isActive && !todo.task.isEmpty {
                Menu {
                    Section("Priority") {
                        ForEach(Priority.allCases, id: \.rawValue) { priority in
                            Button(action: {
                                todo.priority = priority
                                 try? context.save()  // Ensure changes are saved to disk
                                WidgetCenter.shared.reloadAllTimelines()
                            }, label: {
                                HStack {
                                    Text(priority.rawValue)
                                    
                                    if todo.priority == priority { Image(systemName: "checkmark") }
                                }
                            })
                        }
                    }
                } label: {
                    Image(systemName: "circle.fill")
                        .font(.title2)
                        .padding(3)
                        .contentShape(.rect)
                        .foregroundStyle(todo.priority.color.gradient)
                }
            }
        }
        .listRowInsets(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
        .animation(.snappy, value: isActive)
        .onAppear {
            isActive = todo.task.isEmpty
        }
        /// Swipe to Delete
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("", systemImage: "trash") {
                context.delete(todo)
                 try? context.save()  // Ensure changes are saved to disk
                WidgetCenter.shared.reloadAllTimelines()
            }
            .tint(.red)
        }
        /// Deleting Empty Todo
        .onSubmit(of: .text) {
            if todo.task.isEmpty {
                context.delete(todo)
            }
            
             try? context.save()  // Ensure changes are saved to disk
            WidgetCenter.shared.reloadAllTimelines()
        }
        .onChange(of: phase) { oldValue, newValue in
            if newValue != .active && todo.task.isEmpty {
                context.delete(todo)
                 try? context.save()  // Ensure changes are saved to disk
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        .task {
            todo.isCompleted = todo.isCompleted
        }
    }
}
