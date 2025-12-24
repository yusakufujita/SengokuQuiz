//
//  ATTService.swift
//  SengokuQuiz
//
//  Created by 藤田優作 on 2025/12/07.
//

import Foundation
import AppTrackingTransparency
import AdSupport

/// App Tracking Transparency（ATT）の管理クラス
class ATTService {
    static let shared = ATTService()
    
    private init() {}
    
    /// ATT許可ダイアログを表示する必要があるかチェック
    func shouldRequestTrackingAuthorization() -> Bool {
        if #available(iOS 14, *) {
            return ATTrackingManager.trackingAuthorizationStatus == .notDetermined
        }
        return false
    }
    
    /// ATT許可ダイアログを表示
    func requestTrackingAuthorization(completion: @escaping (Bool) -> Void) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        completion(true)
                    case .denied, .restricted, .notDetermined:
                        completion(false)
                    @unknown default:
                        completion(false)
                    }
                }
            }
        } else {
            completion(false)
        }
    }
    
    /// 現在のトラッキング許可状態を取得
    @available(iOS 14, *)
    func getTrackingAuthorizationStatus() -> ATTrackingManager.AuthorizationStatus {
        return ATTrackingManager.trackingAuthorizationStatus
    }
}

