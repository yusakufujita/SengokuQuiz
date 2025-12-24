//
//  InterstitialAdViewController.swift
//  SengokuQuiz
//
//  Created by 藤田優作 on 2025/12/07.
//

import SwiftUI
import UIKit

/// インターステイシャル広告を表示するためのUIViewControllerRepresentable
struct InterstitialAdViewController: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            // コールバックを設定
            AdManager.shared.onInterstitialDismissed = {
                DispatchQueue.main.async {
                    isPresented = false
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    let shown = AdManager.shared.showInterstitialAd(from: rootViewController)
                    if !shown {
                        // 広告が表示されなかった場合はfalseにする
                        isPresented = false
                        AdManager.shared.onInterstitialDismissed = nil
                    }
                } else {
                    isPresented = false
                    AdManager.shared.onInterstitialDismissed = nil
                }
            }
        }
    }
}
