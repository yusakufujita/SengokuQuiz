//
//  QuizQuestion.swift
//  SengokuQuiz
//
//  Created by 藤田優作 on 2025/12/07.
//

import Foundation

/// クイズ問題のデータモデル
struct QuizQuestion: Codable, Identifiable {
    let id: Int
    let question: String
    let options: [String]
    let correctAnswer: Int // 0-3のインデックス
    let explanation: String?
    let level: UserLevel // 問題のレベル
    
    /// 正解のテキストを取得
    var correctAnswerText: String {
        guard correctAnswer >= 0 && correctAnswer < options.count else {
            return ""
        }
        return options[correctAnswer]
    }
}

/// 問題セット（JSONファイル用）
struct QuizQuestionSetJSON: Codable {
    let questions: [QuizQuestionJSON]
}

/// JSONファイル用のQuizQuestion（levelはString）
struct QuizQuestionJSON: Codable {
    let id: Int
    let question: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String?
    let level: String
    
    /// QuizQuestionに変換
    func toQuizQuestion() -> QuizQuestion {
        let userLevel = UserLevel(rawValue: level) ?? .smallDaimyo
        return QuizQuestion(
            id: id,
            question: question,
            options: options,
            correctAnswer: correctAnswer,
            explanation: explanation,
            level: userLevel
        )
    }
}

