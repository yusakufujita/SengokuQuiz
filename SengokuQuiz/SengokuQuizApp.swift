//
//  SengokuQuizApp.swift
//  SengokuQuiz
//
//  Created by 藤田優作 on 2025/12/07.
//

import FirebaseCore
import SwiftUI

@main
struct SengokuQuizApp: App {
  @StateObject private var updateService = FirebaseUpdateService.shared

  init() {
    // Firebaseの初期化
    FirebaseApp.configure()

    // 広告の初期化
    AdManager.shared.initialize()

    // アップデートチェック
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      FirebaseUpdateService.shared.checkForUpdate()
    }
  }

  var body: some Scene {
    WindowGroup {
      ZStack {
        MainView()

        // 強制アップデートダイアログ
        UpdateRequiredView()
      }
      .task {
        // アプリ起動後、少し遅延してからATT許可ダイアログを表示
        // UIが完全に読み込まれた後に表示することで、より確実に表示されます
        try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5秒待機

        if ATTService.shared.shouldRequestTrackingAuthorization() {
          ATTService.shared.requestTrackingAuthorization { authorized in
            if authorized {
              print("ATT許可が取得されました")
            } else {
              print("ATT許可が拒否されました")
            }
          }
        }
      }
    }
  }
}
