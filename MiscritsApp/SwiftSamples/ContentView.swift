//
//  ContentView.swift
//  SwiftSamples
//
//  Created by Roi Jacob on 11/26/24.
//

import SwiftUI
import StoreKit
import Observation


// What?
@Observable
class StoreProducts {
    
    let credits = [
        "com.roijacob.currency.gold",
        "com.roijacob.currency.gem",
        "com.roijacob.currency.platinum"
    ]
    
    // Initialize with empty array
    var producto: [Product] = []
    
    var updateListenerTask: Task<Void, Error>? = nil
    
    init() {
        Task(operation: {
            do {
                producto = try await Product.products(for: credits)
            } catch {
                print("Error loading products: \(error)")
                producto = []
            }
            
            updateListenerTask = listenForTransactions()
        })
    }
    
    public enum StoreError: Error {
        case failedVerification
    }
    
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                print("Success - Transaction: \(transaction)")
                print("Success - Verification Result: \(verification)")
                
                await transaction.finish()
                return transaction
            case .unverified:
                throw StoreError.failedVerification
            }
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try {
                        switch result {
                        case .verified(let transaction): return transaction
                        case .unverified: throw StoreError.failedVerification
                        }
                    }()

                    // Deliver products to the user.
                    
                    // Always finish a transaction.
                    await transaction.finish()
                } catch {
                    // StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    print("Transaction failed verification.")
                }
            }
        }
    }
}

struct ContentView: View {
    @State private var store = StoreProducts()
    
    var body: some View {
        VStack(content: {
            ForEach(store.producto) { product in
                Button(action: {
                    Task {
                        try? await store.purchase(product)
                    }
                }, label: {
                    Text(product.displayName)
                })
            }
        })
    }
}

#Preview {
    ContentView()
}
