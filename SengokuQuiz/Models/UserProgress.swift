//
//  UserProgress.swift
//  SengokuQuiz
//
//  Created by 藤田優作 on 2025/12/07.
//

import Foundation

/// ユーザーの進捗状況を管理
class UserProgress: ObservableObject {
  @Published var currentLevel: UserLevel
  @Published var totalCorrectAnswers: Int = 0
  @Published var questionsAnsweredInCurrentSet: Int  // 現在の10問セットで回答した問題数
  @Published var lastAnsweredQuestionId: Int?  // 最後に回答した問題のID
  @Published var levelProgress: [UserLevel: Int] = [:]  // レベルごとの正解数

  private let userDefaults = UserDefaults.standard
  private let levelKey = "userLevel"
  private let correctAnswersKey = "totalCorrectAnswers"
  private let questionsAnsweredKey = "questionsAnsweredInCurrentSet"
  private let lastQuestionIdKey = "lastAnsweredQuestionId"
  private let levelProgressKey = "levelProgress"

  init() {
    // UserDefaultsから読み込み
    if let levelString = userDefaults.string(forKey: levelKey),
      let level = UserLevel(rawValue: levelString)
    {
      self.currentLevel = level
    } else {
      self.currentLevel = .smallDaimyo
    }

    //        self.totalCorrectAnswers = userDefaults.integer(forKey: correctAnswersKey)
    self.questionsAnsweredInCurrentSet = userDefaults.integer(forKey: questionsAnsweredKey)

    if userDefaults.object(forKey: lastQuestionIdKey) != nil {
      self.lastAnsweredQuestionId = userDefaults.integer(forKey: lastQuestionIdKey)
    } else {
      self.lastAnsweredQuestionId = nil
    }

    // レベルごとの進捗を読み込み
    if let data = userDefaults.data(forKey: levelProgressKey),
      let progress = try? JSONDecoder().decode([String: Int].self, from: data)
    {
      var levelProgressDict: [UserLevel: Int] = [:]
      for (key, value) in progress {
        if let level = UserLevel(rawValue: key) {
          levelProgressDict[level] = value
        }
      }
      self.levelProgress = levelProgressDict
    } else {
      // 初期化
      self.levelProgress = [:]
    }
  }

  /// 正解を記録し、レベルアップをチェック
  func recordCorrectAnswer(questionId: Int, level: UserLevel) {
    totalCorrectAnswers += 1
    questionsAnsweredInCurrentSet += 1
    lastAnsweredQuestionId = questionId

    // レベルごとの進捗を更新（新しいDictionaryインスタンスを作成して変更を通知）
    var updatedProgress = levelProgress
    updatedProgress[level, default: 0] += 1
    levelProgress = updatedProgress  // 新しいインスタンスを代入することで変更を検知

    save()

    // レベルアップチェック（小大名の100問完了で大大名に昇格）
    checkLevelUp()
  }

  /// 不正解を記録
  func recordIncorrectAnswer(questionId: Int) {
    questionsAnsweredInCurrentSet += 1
    lastAnsweredQuestionId = questionId

    save()
  }

  /// 10問セットをリセット（広告表示後など）
  func resetCurrentSet() {
    questionsAnsweredInCurrentSet = 0
    save()
  }

  /// レベルアップをチェック
  private func checkLevelUp() {
    // 小大名の100問完了で大大名に昇格
    if currentLevel == .smallDaimyo,
      levelProgress[.smallDaimyo, default: 0] >= 100
    {
      if let nextLevel = currentLevel.nextLevel {
        currentLevel = nextLevel
        save()
      }
    }
    // 他のレベルも同様にチェック
    else if let nextLevel = currentLevel.nextLevel,
      levelProgress[currentLevel, default: 0] >= 100
    {
      currentLevel = nextLevel
      save()
    }
  }

  /// 指定されたレベルの現在のセクション（0-9）を取得
  func getCurrentSection(for level: UserLevel) -> Int {
    let correctCount = levelProgress[level, default: 0]
    return min(correctCount / 10, 9)  // 0-9のセクション
  }

  /// 指定されたレベルの完了したセクション数を取得
  func getCompletedSections(for level: UserLevel) -> Int {
    let correctCount = levelProgress[level, default: 0]
    return min(correctCount / 10, 10)  // 最大10セクション
  }

  /// 現在の10問セットで広告を表示する必要があるか
  func shouldShowInterstitialAd() -> Bool {
    return questionsAnsweredInCurrentSet >= 10
  }

  /// データを保存
  private func save() {
    userDefaults.set(currentLevel.rawValue, forKey: levelKey)
    userDefaults.set(totalCorrectAnswers, forKey: correctAnswersKey)
    userDefaults.set(questionsAnsweredInCurrentSet, forKey: questionsAnsweredKey)
    if let questionId = lastAnsweredQuestionId {
      userDefaults.set(questionId, forKey: lastQuestionIdKey)
    }

    // レベルごとの進捗を保存
    var progressDict: [String: Int] = [:]
    for (level, count) in levelProgress {
      progressDict[level.rawValue] = count
    }
    if let data = try? JSONEncoder().encode(progressDict) {
      userDefaults.set(data, forKey: levelProgressKey)
    }
  }

  /// 進捗をリセット（デバッグ用）
  func reset() {
    currentLevel = .smallDaimyo
    totalCorrectAnswers = 0
    questionsAnsweredInCurrentSet = 0
    lastAnsweredQuestionId = nil
    levelProgress = [:]
    save()
  }

  /// デバッグ用：指定されたレベルの進捗を設定
  func setDebugProgress(level: UserLevel, correctCount: Int) {
    // 新しいDictionaryインスタンスを作成して@Publishedの変更を確実に検知
    var updatedProgress = levelProgress
    updatedProgress[level] = correctCount
    levelProgress = updatedProgress

    // totalCorrectAnswersも更新（全レベルの合計を計算）
    var total = 0
    for (_, count) in levelProgress {
      total += count
    }
    totalCorrectAnswers = total

    // 現在のセクションに応じてquestionsAnsweredInCurrentSetを設定
    questionsAnsweredInCurrentSet = correctCount % 10

    save()
  }
}
