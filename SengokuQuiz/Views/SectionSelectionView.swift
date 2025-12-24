//
//  SectionSelectionView.swift
//  SengokuQuiz
//
//  Created by 藤田優作 on 2025/12/07.
//

import SwiftUI

/// セクション選択画面
struct SectionSelectionView: View {
  let selectedLevel: UserLevel
  @ObservedObject var userProgress: UserProgress
  @Binding var selectedSection: Int?

  var body: some View {      
      ScrollView {
        VStack(spacing: 20) {
          // レベル表示
          Text(selectedLevel.displayName)
            .font(.title)
            .fontWeight(.bold)
            .padding(.top)

        // 進捗表示
        let completedCount = userProgress.getCompletedSections(for: selectedLevel)
        let totalProgress = userProgress.levelProgress[selectedLevel, default: 0]

        VStack(spacing: 8) {
          Text("進捗: \(totalProgress)/100問")
            .font(.headline)

          ProgressView(value: Double(totalProgress), total: 100.0)
            .progressViewStyle(LinearProgressViewStyle())
            .frame(height: 8)

          Text("完了セクション: \(completedCount)/10")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)

        // セクション一覧
        LazyVGrid(
          columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
          ], spacing: 16
        ) {
          ForEach(1...10, id: \.self) { sectionNumber in
            SectionCard(
              sectionNumber: sectionNumber,
              isCompleted: sectionNumber <= completedCount,
              isLocked: sectionNumber > completedCount + 1,
              userProgress: userProgress,
              selectedLevel: selectedLevel
            ) {
              selectedSection = sectionNumber - 1  // 0-indexed
            }
          }
        }
        .padding(.horizontal)
        .padding(.bottom)
        }
      }
//    }
  }
}

/// セクションカード
struct SectionCard: View {
  let sectionNumber: Int
  let isCompleted: Bool
  let isLocked: Bool
  let userProgress: UserProgress
  let selectedLevel: UserLevel
  let action: () -> Void

  var body: some View {
    Button(action: {
      if !isLocked {
        action()
      }
    }) {
      VStack(spacing: 12) {
        if isLocked {
          Image(systemName: "lock.fill")
            .font(.system(size: 30))
            .foregroundColor(.gray)
        } else if isCompleted {
          Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 30))
            .foregroundColor(.green)
        } else {
          Image(systemName: "play.circle.fill")
            .font(.system(size: 30))
            .foregroundColor(.blue)
        }

        Text("セクション\(sectionNumber)")
          .font(.headline)
          .foregroundColor(isLocked ? .gray : .primary)

        if isCompleted {
          Text("完了")
            .font(.caption)
            .foregroundColor(.green)
        } else if isLocked {
          Text("ロック")
            .font(.caption)
            .foregroundColor(.gray)
        } else {
          Text("挑戦可能")
            .font(.caption)
            .foregroundColor(.blue)
        }
      }
      .frame(maxWidth: .infinity)
      .frame(height: 120)
      .background(
        isLocked
          ? Color(UIColor.tertiarySystemBackground)
          : (isCompleted ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
      )
      .cornerRadius(12)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(
            isCompleted
              ? Color.green : (isLocked ? Color.gray.opacity(0.3) : Color.blue.opacity(0.3)),
            lineWidth: 2
          )
      )
    }
    .disabled(isLocked)
  }
}
