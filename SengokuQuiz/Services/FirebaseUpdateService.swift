//
//  FirebaseUpdateService.swift
//  SengokuQuiz
//
//  Created by 藤田優作 on 2025/12/07.
//

import FirebaseRemoteConfig
import Foundation

/// Firebase Remote Configを使用した強制アップデート機能
class FirebaseUpdateService: ObservableObject {
  static let shared = FirebaseUpdateService()

  @Published var requiresUpdate: Bool = false
  @Published var minimumVersion: String = ""
  @Published var updateMessage: String = ""
  @Published var updateURL: String = ""

  private let remoteConfig = RemoteConfig.remoteConfig()

  private init() {
    setupRemoteConfig()
  }

  private func setupRemoteConfig() {
    // デフォルト値を設定
    let defaults: [String: NSObject] = [
      "minimum_version": "1.0.0" as NSString,
      "force_update_required": NSNumber(value: true),  // デフォルトはtrue（強制アップデートあり）
      "force_update_message": "アプリの更新が必要です。最新バージョンにアップデートしてください。" as NSString,
      "update_url": "https://apps.apple.com/app/idYOUR_APP_ID" as NSString,
    ]
    remoteConfig.setDefaults(defaults)

    // フェッチ間隔を設定（秒単位）
    let settings = RemoteConfigSettings()
    settings.minimumFetchInterval = 3600  // 1時間
    remoteConfig.configSettings = settings
  }

  /// アップデートが必要かチェック
  func checkForUpdate() {
    remoteConfig.fetch { [weak self] status, error in
      guard let self = self else { return }

      if status == .success {
        self.remoteConfig.activate { [weak self] _, _ in
          self?.evaluateUpdateRequirement()
        }
      } else {
        print("Remote Configのフェッチに失敗: \(error?.localizedDescription ?? "不明なエラー")")
      }
    }
  }

  /// アップデート要件を評価
  private func evaluateUpdateRequirement() {
    let minimumVersionString =
      remoteConfig.configValue(forKey: "minimum_version").stringValue ?? "1.0.0"
    let currentVersion =
      Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"

    // 強制アップデートフラグを取得
    let forceUpdateRequired = remoteConfig.configValue(forKey: "force_update_required").boolValue

      DispatchQueue.main.async {
          self.minimumVersion = minimumVersionString
          self.updateMessage = self.remoteConfig.configValue(forKey: "force_update_message").stringValue
          self.updateURL = self.remoteConfig.configValue(forKey: "update_url").stringValue
      }
    // 強制アップデートフラグがtrueの場合、バージョン比較を行う
    if forceUpdateRequired {
      // バージョン比較
      if compareVersions(currentVersion, minimumVersionString) < 0 {
        requiresUpdate = true
      } else {
          DispatchQueue.main.async {
              self.requiresUpdate = false
          }
      }
    } else {
      // フラグがfalseの場合は強制アップデート不要
      requiresUpdate = false
    }
  }

  /// バージョン文字列を比較
  /// - Returns: current < minimum の場合は負の値、等しい場合は0、current > minimum の場合は正の値
  private func compareVersions(_ current: String, _ minimum: String) -> Int {
    let currentComponents = current.split(separator: ".").compactMap { Int($0) }
    let minimumComponents = minimum.split(separator: ".").compactMap { Int($0) }

    let maxLength = max(currentComponents.count, minimumComponents.count)

    for i in 0..<maxLength {
      let currentValue = i < currentComponents.count ? currentComponents[i] : 0
      let minimumValue = i < minimumComponents.count ? minimumComponents[i] : 0

      if currentValue < minimumValue {
        return -1
      } else if currentValue > minimumValue {
        return 1
      }
    }

    return 0
  }
}
