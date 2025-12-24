//
//  PremiumView.swift
//  SengokuQuiz
//
//  Created by 藤田優作 on 2025/12/07.
//

import SwiftUI

/// プレミアムプランの購入画面
struct PremiumView: View {
    @ObservedObject var premiumManager = PremiumManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                if premiumManager.isPremium {
                    VStack(spacing: 20) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("プレミアム会員です")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("インターステイシャル広告が表示されません")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "crown")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("プレミアムプラン")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            FeatureRow(icon: "xmark.circle.fill", text: "インターステイシャル広告を削除")
                            FeatureRow(icon: "checkmark.circle.fill", text: "バナー広告は引き続き表示されます")
                        }
                        .padding()
                        
                        // 年額プラン
                        if let yearlyProduct = premiumManager.products.first(where: { $0.id == PremiumManager.shared.premiumYearlyProductID }) {
                            VStack(spacing: 8) {
                                Text("年額プラン（お得！）")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                
                                Button(action: {
                                    Task {
                                        await premiumManager.purchasePremium(productID: PremiumManager.shared.premiumYearlyProductID)
                                    }
                                }) {
                                    VStack(spacing: 4) {
                                        Text("年額プランを購入")
                                            .font(.headline)
                                        Text(yearlyProduct.displayPrice)
                                            .font(.subheadline)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // 月額プラン
                        if let monthlyProduct = premiumManager.products.first(where: { $0.id == PremiumManager.shared.premiumMonthlyProductID }) {
                            VStack(spacing: 8) {
                                Text("月額プラン")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                
                                Button(action: {
                                    Task {
                                        await premiumManager.purchasePremium(productID: PremiumManager.shared.premiumMonthlyProductID)
                                    }
                                }) {
                                    VStack(spacing: 4) {
                                        Text("月額プランを購入")
                                            .font(.headline)
                                        Text(monthlyProduct.displayPrice)
                                            .font(.subheadline)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Button(action: {
                            Task {
                                await premiumManager.restorePurchases()
                            }
                        }) {
                            Text("購入を復元")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        
                        if case .failed(let message) = premiumManager.purchaseState {
                            Text(message)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("プレミアム")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(text)
                .font(.body)
            Spacer()
        }
    }
}

