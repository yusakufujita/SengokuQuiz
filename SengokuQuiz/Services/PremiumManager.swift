//
//  PremiumManager.swift
//  SengokuQuiz
//
//  Created by 藤田優作 on 2025/12/07.
//

import Foundation
import StoreKit

/// プレミアムプランの管理クラス
class PremiumManager: ObservableObject {
  static let shared = PremiumManager()

  // TODO: App Store Connectで設定したプロダクトIDに置き換えてください
  let premiumMonthlyProductID = "com.yusaku.sengokuquiz.premium.monthly"
  let premiumYearlyProductID = "com.yusaku.sengokuquiz.premium.yearly"

  /// すべてのプレミアムプロダクトID
  var premiumProductIDs: [String] {
    return [premiumMonthlyProductID, premiumYearlyProductID]
  }

  @Published var isPremium: Bool = false
  @Published var products: [Product] = []
  @Published var purchaseState: PurchaseState = .idle

  enum PurchaseState {
    case idle
    case purchasing
    case success
    case failed(String)
  }

  private init() {
    checkPremiumStatus()
    Task {
      await loadProducts()
    }
  }

  /// プレミアム状態を確認
  private func checkPremiumStatus() {
    // UserDefaultsで保存された購入状態を確認
    // 実際の実装では、StoreKitのトランザクション検証を行う必要があります
    isPremium = UserDefaults.standard.bool(forKey: "isPremium")

    // StoreKitのトランザクションを確認
    Task {
      await updatePremiumStatus()
    }
  }

  /// StoreKitのトランザクションからプレミアム状態を更新
  @MainActor
  private func updatePremiumStatus() async {
    for await result in Transaction.currentEntitlements {
      if case .verified(let transaction) = result {
        if premiumProductIDs.contains(transaction.productID) {
          isPremium = true
          UserDefaults.standard.set(true, forKey: "isPremium")
          return
        }
      }
    }
    isPremium = false
    UserDefaults.standard.set(false, forKey: "isPremium")
  }

  /// プロダクトを読み込む
  @MainActor
  func loadProducts() async {
    do {
      let products = try await Product.products(for: premiumProductIDs)
      self.products = products
    } catch {
      print("プロダクトの読み込みに失敗: \(error.localizedDescription)")
    }
  }

  /// プレミアムプランを購入
  @MainActor
  func purchasePremium(productID: String) async {
    guard let product = products.first(where: { $0.id == productID }) else {
      purchaseState = .failed("プロダクトが見つかりません")
      return
    }

    purchaseState = .purchasing

    do {
      let result = try await product.purchase()

      switch result {
      case .success(let verification):
        switch verification {
        case .verified(let transaction):
          // 購入成功
          await transaction.finish()
          isPremium = true
          UserDefaults.standard.set(true, forKey: "isPremium")
          purchaseState = .success
          // 広告を無効化
          AdManager.shared.loadInterstitialAd()
        case .unverified(_, let error):
          purchaseState = .failed("購入の検証に失敗: \(error.localizedDescription)")
        }
      case .userCancelled:
        purchaseState = .idle
      case .pending:
        purchaseState = .failed("購入が保留中です")
      @unknown default:
        purchaseState = .failed("不明なエラー")
      }
    } catch {
      purchaseState = .failed("購入に失敗: \(error.localizedDescription)")
    }
  }

  /// 購入を復元
  @MainActor
  func restorePurchases() async {
    do {
      try await AppStore.sync()
      await updatePremiumStatus()
      purchaseState = .success
    } catch {
      purchaseState = .failed("復元に失敗: \(error.localizedDescription)")
    }
  }
}
