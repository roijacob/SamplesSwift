//
//  ContentView.swift
//  SwiftSamples
//
//  Created by Roi Jacob on 11/26/24.
//

import SwiftUI
import StoreKit
import SwiftData


let credits = [
    "com.roijacob.currency.gold",
    "com.roijacob.currency.gem",
    "com.roijacob.currency.platinum"
]


@Model
class GameMoney {
    var gold: Int
    var gem: Int
    var platinum: Int
    
    init(gold: Int = 0, gem: Int = 0, platinum: Int = 0) {
        self.gold = gold
        self.gem = gem
        self.platinum = platinum
    }
}


struct ContentView: View {
    // MARK: - Properties
    @Query private var gameMoney: [GameMoney]
    @Environment(\.modelContext) private var modelContext
    
    @State private var products: [Product] = []
    @Environment(\.purchase) private var purchase
    
    var currentMoney: GameMoney {
        if gameMoney.isEmpty {
            let newMoney = GameMoney()
            modelContext.insert(newMoney)
            try? modelContext.save()
            return newMoney
        }
        return gameMoney[0]
    }
    
    // MARK: - Views
    var body: some View {
        VStack(content: {
            HStack {
                Text("Gold: \(currentMoney.gold)")
                Spacer()
                Text("Gem: \(currentMoney.gem)")
                Spacer()
                Text("Platinum: \(currentMoney.platinum)")
            }
            .padding()
            
            Spacer()
            
            ForEach(products) { product in
                Button(action: {
                    Task(operation: {
                        print("Hello World")
                        let purchaseResult = try await purchase(product)
                        handlePurchaseResult(purchaseResult)
                    })
                }, label: {
                    Text(product.displayName)
                })
            }
            
            Spacer()
            
            Button("Reset Currency") {
                resetCurrency()
            }
        })
        .task {
            // Load products when view appears
            do {
                products = try await Product.products(for: credits)
            } catch {
                print("Failed to load products: \(error)")
            }
            
            _ = listenForTransactions()
        }
    }
    
    
    private func handlePurchaseResult(_ purchaseResult: Product.PurchaseResult) {
        switch purchaseResult {
        case .success(let verificationResult):
            handleVerification(verificationResult)
        case .userCancelled:
            print("huh? bat ayaw mo pre?")
        case .pending:
            print("taena ayos naman pre o")
        @unknown default:
            break
        }
    }
    
    // MARK: - Verification Handler
    private func handleVerification(_ verificationResult: VerificationResult<StoreKit.Transaction>) {
        switch verificationResult {
        
        case .verified(let transaction):
            
        // Put here the paid logic
        updateCurrency(for: transaction.productID)
            
        print("liz git it!!: \(transaction)")
        
        case .unverified:
            print("hell nah bruh")
        }
    }
    
    // MARK: - Helper Functions
    private func updateCurrency(for productId: String) {
        switch productId {
        case "com.roijacob.currency.gold":
            currentMoney.gold += 1
        case "com.roijacob.currency.gem":
            currentMoney.gem += 1
        case "com.roijacob.currency.platinum":
            currentMoney.platinum += 1
        default:
            break
        }
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? result.payloadValue {
                    await transaction.finish()
                }
            }
        }
    }
    
    private func resetCurrency() {
        currentMoney.gold = 0
        currentMoney.gem = 0
        currentMoney.platinum = 0
    }
}
