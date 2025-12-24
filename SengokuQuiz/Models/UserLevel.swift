//
//  UserLevel.swift
//  SengokuQuiz
//
//  Created by 藤田優作 on 2025/12/07.
//

import Foundation

/// ユーザーのレベル
enum UserLevel: String, Codable, CaseIterable {
  case smallDaimyo = "小大名"
  case largeDaimyo = "大大名"
  case gunyuu = "群雄"
  case hasha = "覇者"
  case tenkabito = "天下人"

  /// レベルに到達するために必要な正解数
  var requiredCorrectAnswers: Int {
    switch self {
    case .smallDaimyo:
      return 0
    case .largeDaimyo:
      return 100
    case .gunyuu:
      return 200
    case .hasha:
      return 300
    case .tenkabito:
      return 400
    }
  }

  /// 次のレベル
  var nextLevel: UserLevel? {
    switch self {
    case .smallDaimyo:
      return .largeDaimyo
    case .largeDaimyo:
      return .gunyuu
    case .gunyuu:
      return .hasha
    case .hasha:
      return .tenkabito
    case .tenkabito:
      return nil
    }
  }

  /// 表示名
  var displayName: String {
    return self.rawValue
  }
}
