//
//  QuizView.swift
//  SengokuQuiz
//
//  Created by 藤田優作 on 2025/12/07.
//

import SwiftUI

/// クイズ画面（セクション選択と問題表示を管理）
struct QuizContainerView: View {
  let selectedLevel: UserLevel
  @ObservedObject var userProgress: UserProgress
  @StateObject private var premiumManager = PremiumManager.shared
  @StateObject private var adManager = AdManager.shared

  @State private var selectedSection: Int? = nil  // nilの場合はセクション選択画面、0-9の場合は問題画面
  @State private var showInterstitialAd = false

  var body: some View {
    ZStack {
      // 背景画像（小大名の場合のみ）
      if selectedLevel == .smallDaimyo,
        let image = UIImage(named: "okehazama")
      {
        Image(uiImage: image)
          .resizable()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .clipped()
          .opacity(0.3)
          .ignoresSafeArea()
      } else if selectedLevel == .largeDaimyo, let image = UIImage(named: "anegawa") {
        Image(uiImage: image)
          .resizable()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .clipped()
          .opacity(0.3)
          .ignoresSafeArea()
      } else if selectedLevel == .gunyuu, let image = UIImage(named: "nagashino") {
        Image(uiImage: image)
          .resizable()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .clipped()
          .opacity(0.3)
          .ignoresSafeArea()
      } else if selectedLevel == .hasha, let image = UIImage(named: "sekigahara") {
        Image(uiImage: image)
          .resizable()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .clipped()
          .opacity(0.3)
          .ignoresSafeArea()
      } else if selectedLevel == .tenkabito, let image = UIImage(named: "oosaka") {
        Image(uiImage: image)
          .resizable()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .clipped()
          .opacity(0.3)
          .ignoresSafeArea()
      }

      if let sectionIndex = selectedSection {
        // 問題画面
        QuestionView(
          selectedLevel: selectedLevel,
          sectionIndex: sectionIndex,
          userProgress: userProgress,
          premiumManager: premiumManager,
          adManager: adManager,
          showInterstitialAd: $showInterstitialAd,
          shouldReturnToSectionSelection: Binding(
            get: { selectedSection == nil },
            set: { if $0 { selectedSection = nil } }
          )
        )
      } else {
        // セクション選択画面
        SectionSelectionView(
          selectedLevel: selectedLevel,
          userProgress: userProgress,
          selectedSection: $selectedSection
        )
      }
    }
    .onAppear {
      // 初期表示時にレベル完了状態をチェック
      checkLevelCompletion()
    }
    .onChange(of: userProgress.levelProgress) { _ in
      // levelProgressが変更されたらレベル完了をチェック
      // これにより、100問正解時に次のレベルがアンロックされる
      checkLevelCompletion()
    }
    .onChange(of: selectedLevel) { _ in
      // レベルが変更されたらセクション選択に戻る
      selectedSection = nil
    }
    .background(
      InterstitialAdViewController(isPresented: $showInterstitialAd)
    )
  }

  /// レベル完了をチェックする関数
  private func checkLevelCompletion() {
    // 現在のレベルが100問完了しているかチェック
    let completedSections = userProgress.getCompletedSections(for: selectedLevel)
    if completedSections >= 10 {
      // レベル完了 - MainViewのisLevelUnlockedが再評価されるようにする
      // levelProgressの変更により、自動的に再評価される
      print("\(selectedLevel.displayName)完了！次のレベルがアンロックされました")

      // 次のレベルがアンロックされているかチェック
      if let nextLevel = selectedLevel.nextLevel {
        let isNextLevelUnlocked = isLevelUnlocked(level: nextLevel, userProgress: userProgress)
        if isNextLevelUnlocked {
          print("\(nextLevel.displayName)がアンロックされました")
        }
      }
    }
  }

  /// レベルがアンロックされているかチェック
  private func isLevelUnlocked(level: UserLevel, userProgress: UserProgress) -> Bool {
    switch level {
    case .smallDaimyo:
      return true  // 小大名は常にアンロック
    case .largeDaimyo:
      // 小大名の100問完了でアンロック
      return userProgress.getCompletedSections(for: .smallDaimyo) >= 10
    case .gunyuu:
      // 大大名の100問完了でアンロック
      return userProgress.getCompletedSections(for: .largeDaimyo) >= 10
    case .hasha:
      // 群雄の100問完了でアンロック
      return userProgress.getCompletedSections(for: .gunyuu) >= 10
    case .tenkabito:
      // 覇者の100問完了でアンロック
      return userProgress.getCompletedSections(for: .hasha) >= 10
    }
  }
}
