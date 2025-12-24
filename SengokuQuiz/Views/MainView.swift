//
//  MainView.swift
//  SengokuQuiz
//
//  Created by 藤田優作 on 2025/12/07.
//

import SwiftUI

/// メイン画面（クイズ画面とバナー広告を含む）
struct MainView: View {
    @StateObject private var userProgress = UserProgress()
    @StateObject private var premiumManager = PremiumManager.shared
    @State private var showPremiumView = false
    @State private var selectedLevel: UserLevel = .smallDaimyo

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // レベル選択タブ
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(UserLevel.allCases, id: \.self) { level in
                            LevelTabButton(
                                level: level,
                                isSelected: selectedLevel == level,
                                isUnlocked: isLevelUnlocked(level: level, userProgress: userProgress),
                                userProgress: userProgress
                            ) {
                                selectedLevel = level
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .padding(.trailing, 80)  // プレミアムボタンと被らないように右側にパディングを追加
                }
                .background(Color(UIColor.secondarySystemBackground))

                // クイズ画面
                QuizContainerView(selectedLevel: selectedLevel, userProgress: userProgress)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // バナー広告（プレミアムユーザーでも表示し続ける）
                BannerAdView(adUnitID: AdManager.shared.getBannerAdUnitID())
                    .frame(height: 50)
            }

            // プレミアムボタン
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showPremiumView = true
                    }) {
                        Image(systemName: premiumManager.isPremium ? "crown.fill" : "crown")
                            .font(.title2)
                            .foregroundColor(.yellow)
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showPremiumView) {
            PremiumView()
        }
        .onAppear {
            // 現在のレベルに合わせてタブを設定
            selectedLevel = userProgress.currentLevel

            // デバッグ用：小大名の90問目まで正解した状態に設定
            // 本番環境では以下の行をコメントアウトしてください
            userProgress.setDebugProgress(level: .tenkabito,
                                          correctCount: 90)
        }
        .onChange(of: userProgress.currentLevel) { newLevel in
            selectedLevel = newLevel
        }
        .onChange(of: userProgress.levelProgress) { _ in
            // levelProgressが変更されたらUIを更新（アンロック状態の再計算）
            // この変更により、isLevelUnlockedが再評価される
        }
        .onChange(of: userProgress.totalCorrectAnswers) { _ in
            // totalCorrectAnswersが変更されたらUIを更新
            // levelProgressも同時に変更されているため、isLevelUnlockedが再評価される
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

/// レベル選択タブボタン
struct LevelTabButton: View {
    let level: UserLevel
    let isSelected: Bool
    let isUnlocked: Bool
    let userProgress: UserProgress
    let action: () -> Void

    var body: some View {
        Button(action: {
            if isUnlocked {
                action()
            }
        }) {
            VStack(spacing: 4) {
                Text(level.displayName)
                    .font(.headline)
                    .foregroundColor(isUnlocked ? (isSelected ? .white : .primary) : .gray)

                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundColor(.gray)
                } else if isSelected {
                    Text("挑戦中")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isUnlocked
                ? (isSelected ? Color.blue : Color(UIColor.secondarySystemBackground))
                : Color(UIColor.tertiarySystemBackground)
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .disabled(!isUnlocked)
    }
}
