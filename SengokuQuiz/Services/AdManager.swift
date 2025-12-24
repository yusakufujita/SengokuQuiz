//
//  AdManager.swift
//  SengokuQuiz
//
//  Created by 藤田優作 on 2025/12/07.
//

import Foundation
import GoogleMobileAds
import SwiftUI

/// 広告管理クラス
class AdManager: NSObject, ObservableObject {
    static let shared = AdManager()
    
    // TODO: 実際の広告ユニットIDに置き換えてください
    // 開発中はテスト用のIDを使用することを推奨します
    // 本番環境では、以下のコメントを外して本番用のIDを使用してください
    
    // テスト用のID（開発中に使用）
//    private let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716" // テスト用バナー広告ID
//    private let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910" // テスト用インターステイシャル広告ID
//    
    // 本番用のID（リリース時に使用）
    private let interstitialAdUnitID = "ca-app-pub-5863451431578196/7439624788" // 本番用のインターステイシャル広告ID
    private let bannerAdUnitID = "ca-app-pub-5863451431578196/6245962614" // 本番用のバナー広告ID

    private var interstitialAd: InterstitialAd?
    @Published var isInterstitialReady = false
    @Published var hasInterstitialError = false  // エラー状態を追跡
    var onInterstitialDismissed: (() -> Void)?
    
    private override init() {
        super.init()
    }
    
    /// 広告を初期化
    func initialize() {
        MobileAds.shared.start(completionHandler: nil)
        loadInterstitialAd()
    }
    
    /// バナー広告のユニットIDを取得
    func getBannerAdUnitID() -> String {
        return bannerAdUnitID
    }
    
    /// インターステイシャル広告を読み込む
    func loadInterstitialAd() {
        // プレミアムユーザーの場合は広告を読み込まない
        if PremiumManager.shared.isPremium {
            return
        }
        
        // 既に読み込み中の場合はスキップ
        if isInterstitialReady && interstitialAd != nil {
            return
        }
        
        let request = Request()
        InterstitialAd.load(with: interstitialAdUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            
            if let error = error {
                print("インターステイシャル広告の読み込みに失敗: \(error.localizedDescription)")
                print("エラー詳細: \(error)")
                self.isInterstitialReady = false
                self.interstitialAd = nil
                self.hasInterstitialError = true
                // エラーの種類に応じて処理
                // "No ad to show" エラーの場合は、広告が利用できないことをログに記録するだけ
                // アプリの動作は継続する
                return
            }
            
            guard let ad = ad else {
                print("インターステイシャル広告がnilです")
                self.isInterstitialReady = false
                self.interstitialAd = nil
                self.hasInterstitialError = true
                return
            }

            self.hasInterstitialError = false
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
            self.isInterstitialReady = true
            print("インターステイシャル広告の読み込み成功")
        }
    }
    
    /// インターステイシャル広告を表示
    func showInterstitialAd(from viewController: UIViewController) -> Bool {
        // プレミアムユーザーの場合は広告を表示しない
        if PremiumManager.shared.isPremium {
            return false
        }
        
        guard let interstitialAd = interstitialAd, isInterstitialReady else {
            // 広告が準備できていない場合は次回のために読み込む
            print("インターステイシャル広告が準備できていません。読み込みを開始します。")
            loadInterstitialAd()
            return false
        }
        
        // 広告を表示
        interstitialAd.present(from: viewController)
        print("インターステイシャル広告を表示しました")
        return true
    }
}

// MARK: - GADFullScreenContentDelegate
extension AdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        // 広告が閉じられたら次の広告を読み込む
        interstitialAd = nil
        isInterstitialReady = false
        loadInterstitialAd()
        // コールバックを呼び出す
        onInterstitialDismissed?()
        onInterstitialDismissed = nil
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("インターステイシャル広告の表示に失敗: \(error.localizedDescription)")
        interstitialAd = nil
        isInterstitialReady = false
        loadInterstitialAd()
        // コールバックを呼び出す
        onInterstitialDismissed?()
        onInterstitialDismissed = nil
    }
}

