//
//  QuizDataService.swift
//  SengokuQuiz
//
//  Created by 藤田優作 on 2025/12/07.
//

import Foundation

/// クイズデータを管理するサービス
/// JSONファイルから問題を読み込みます
class QuizDataService {
  static let shared = QuizDataService()

  private var questionsByLevel: [UserLevel: [QuizQuestion]] = [:]

  private init() {
    loadQuestions()
  }

  /// 問題を読み込む
  /// JSONファイルから問題を読み込みます
  private func loadQuestions() {
    // 小大名レベルの問題をJSONから読み込む
    if let smallDaimyoQuestions = loadQuestionsFromJSON(
      filename: "questions_small_daimyo", level: .smallDaimyo)
    {
      questionsByLevel[.smallDaimyo] = smallDaimyoQuestions
    }

    // 大大名レベルの問題をJSONから読み込む
    if let largeDaimyoQuestions = loadQuestionsFromJSON(
      filename: "questions_large_daimyo", level: .largeDaimyo)
    {
      questionsByLevel[.largeDaimyo] = largeDaimyoQuestions
    }

    // 群雄レベルの問題をJSONから読み込む
    if let gunyuuQuestions = loadQuestionsFromJSON(
      filename: "questions_gunyuu", level: .gunyuu)
    {
      questionsByLevel[.gunyuu] = gunyuuQuestions
    }

    // 覇者レベルの問題をJSONから読み込む
    if let hashaQuestions = loadQuestionsFromJSON(
      filename: "questions_hasha", level: .hasha)
    {
      questionsByLevel[.hasha] = hashaQuestions
    }

    // 天下人レベルの問題をJSONから読み込む
    if let tenkabitoQuestions = loadQuestionsFromJSON(
      filename: "questions_tenkabito", level: .tenkabito)
    {
      questionsByLevel[.tenkabito] = tenkabitoQuestions
    }
  }

  /// JSONファイルから問題を読み込む
  private func loadQuestionsFromJSON(filename: String, level: UserLevel) -> [QuizQuestion]? {
    guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
      print("JSONファイルが見つかりません: \(filename).json")
      return nil
    }

    do {
      let data = try Data(contentsOf: url)
      let decoder = JSONDecoder()
      let questionSet = try decoder.decode(QuizQuestionSetJSON.self, from: data)

      // JSONから読み込んだ問題をQuizQuestionに変換（レベルは引数で指定）
      return questionSet.questions.map { questionJSON in
        QuizQuestion(
          id: questionJSON.id,
          question: questionJSON.question,
          options: questionJSON.options,
          correctAnswer: questionJSON.correctAnswer,
          explanation: questionJSON.explanation,
          level: level
        )
      }
    } catch {
      print("JSONファイルの読み込みに失敗: \(error.localizedDescription)")
      return nil
    }
  }

  /// 指定されたレベルの問題を取得
  func getQuestions(for level: UserLevel) -> [QuizQuestion] {
    return questionsByLevel[level] ?? []
  }

  /// 指定されたレベルの問題を10問ずつのセットに分割して取得
  func getQuestionSets(for level: UserLevel) -> [[QuizQuestion]] {
    let questions = getQuestions(for: level)
    return stride(from: 0, to: questions.count, by: 10).map {
      Array(questions[$0..<min($0 + 10, questions.count)])
    }
  }

  /// すべての問題を取得（後方互換性のため）
  func getAllQuestions() -> [QuizQuestion] {
    return questionsByLevel.values.flatMap { $0 }
  }

  /// 問題を10問ずつのセットに分割して取得（後方互換性のため）
  func getQuestionSets() -> [[QuizQuestion]] {
    return getAllQuestions().dividedIntoSets(of: 10)
  }

  /// 指定されたIDの問題を取得
  func getQuestion(by id: Int) -> QuizQuestion? {
    return getAllQuestions().first { $0.id == id }
  }

  /// 問題を追加（後で問題を追加する際に使用）
  func addQuestions(_ questions: [QuizQuestion], for level: UserLevel) {
    var currentQuestions = questionsByLevel[level] ?? []
    currentQuestions.append(contentsOf: questions)
    questionsByLevel[level] = currentQuestions
  }
}

// MARK: - Array Extension
extension Array where Element == QuizQuestion {
  func dividedIntoSets(of size: Int = 10) -> [[QuizQuestion]] {
    return stride(from: 0, to: self.count, by: size).map {
      Array(self[$0..<Swift.min($0 + size, self.count)])
    }
  }
}
