//
//  QuestionView.swift
//  SengokuQuiz
//
//  Created by 藤田優作 on 2025/12/07.
//

import SwiftUI

/// 問題画面（1セクション10問）
struct QuestionView: View {
    let selectedLevel: UserLevel
    let sectionIndex: Int
    @ObservedObject var userProgress: UserProgress
    @ObservedObject var premiumManager: PremiumManager
    @ObservedObject var adManager: AdManager
    @Binding var showInterstitialAd: Bool
    @Binding var shouldReturnToSectionSelection: Bool

    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var showExplanation = false
    @State private var currentSet: [QuizQuestion] = []

    var body: some View {
        ZStack {
            if currentSet.isEmpty {
                ProgressView("問題を読み込んでいます...")
            } else if currentQuestionIndex >= currentSet.count {
                // 10問終了
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)

                    Text("セクション\(sectionIndex + 1)完了！")
                        .font(.title)
                        .fontWeight(.bold)

                    Text(
                        "\(selectedLevel.displayName)の進捗: \(userProgress.levelProgress[selectedLevel, default: 0])/100問"
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    let completedSections = userProgress.getCompletedSections(for: selectedLevel)
                    if completedSections >= 10 {
                        Text("\(selectedLevel.displayName)完了！次のレベルへ")
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding()
                    }

                    Button(action: {
                        // 広告表示が必要な場合
                        if userProgress.shouldShowInterstitialAd() && !premiumManager.isPremium && !adManager.hasInterstitialError {
                            showInterstitialAd = true
                            // 広告が閉じられたらセクション選択に戻る
                            AdManager.shared.onInterstitialDismissed = {
                                shouldReturnToSectionSelection = true
                            }
                        } else {
                            shouldReturnToSectionSelection = true
                        }

                    }) {
                        Text("セクション選択に戻る")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding()
            } else {
                // クイズ問題表示
                let question = currentSet[currentQuestionIndex]

                VStack(spacing: 20) {
                    // 戻るボタン
                    HStack {
                        Button(action: {
                            shouldReturnToSectionSelection = true
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .font(.headline)
                                Text("戻る")
                                    .font(.headline)
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)

                    // 進捗表示
                    VStack(spacing: 8) {
                        HStack {
                            Text("問題 \(currentQuestionIndex + 1) / \(currentSet.count)")
                                .font(.headline)
                            Spacer()
                            Text(selectedLevel.displayName)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }

                        HStack {
                            Text("セクション\(sectionIndex + 1)/10")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(
                                "\(selectedLevel.displayName): \(userProgress.levelProgress[selectedLevel, default: 0])/100問"
                            )
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)

                    // 問題文
                    Text(question.question)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    // 選択肢
                    VStack(spacing: 12) {
                        ForEach(0..<question.options.count, id: \.self) { index in
                            Button(action: {
                                if selectedAnswer == nil {
                                    selectedAnswer = index
                                    checkAnswer(question: question, selectedIndex: index)
                                }
                            }) {
                                HStack {
                                    Text(question.options[index])
                                        .font(.body)
                                        .foregroundColor(selectedAnswer == index ? .white : .primary)
                                    Spacer()
                                    if showResult && selectedAnswer == index {
                                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding()
                                .background(
                                    selectedAnswer == index
                                    ? (isCorrect ? Color.green : Color.red)
                                    : Color(UIColor.secondarySystemBackground)
                                )
                                .cornerRadius(10)
                            }
                            .disabled(selectedAnswer != nil)
                        }
                    }
                    .padding(.horizontal)

                    // 説明表示
                    if showExplanation, let explanation = question.explanation {
//                        ScrollView {
                            Text(explanation)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxHeight: 150) // 最大高さを制限
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                                .padding(.horizontal)
//                        }

                    }

                    // 次の問題ボタン
                    if showResult {
                        Button(action: {
                            nextQuestion()
                        }) {
                            Text("次の問題")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding(.vertical)
            }
        }
        .onAppear {
            loadSection()
        }
    }

    /// セクションの問題を読み込む
    private func loadSection() {
        let sets = QuizDataService.shared.getQuestionSets(for: selectedLevel)
        if sectionIndex < sets.count {
            currentSet = sets[sectionIndex]
            currentQuestionIndex = 0
            selectedAnswer = nil
            showResult = false
            showExplanation = false
//            userProgress.resetCurrentSet()
        }
    }

    /// 答えをチェック
    private func checkAnswer(question: QuizQuestion, selectedIndex: Int) {
        isCorrect = selectedIndex == question.correctAnswer
        showResult = true
        showExplanation = true

        if isCorrect {
            userProgress.recordCorrectAnswer(questionId: question.id, level: selectedLevel)
        } else {
            userProgress.recordIncorrectAnswer(questionId: question.id)
        }
    }

    /// 次の問題へ
    private func nextQuestion() {
        currentQuestionIndex += 1
        selectedAnswer = nil
        showResult = false
        showExplanation = false

        // 10問終了した場合、広告表示をチェック
        if currentQuestionIndex >= currentSet.count {
            if userProgress.shouldShowInterstitialAd() && !premiumManager.isPremium {
                showInterstitialAd = true
            }
        }
    }
}
