//
//  UpdateRequiredView.swift
//  SengokuQuiz
//
//  Created by 藤田優作 on 2025/12/07.
//

import SwiftUI

/// 強制アップデートが必要な場合に表示するビュー
struct UpdateRequiredView: View {
    @ObservedObject var updateService = FirebaseUpdateService.shared
    @State private var isPresented = true
    
    var body: some View {
        if updateService.requiresUpdate && isPresented {
            ZStack {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("アップデートが必要です")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(updateService.updateMessage)
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        if let url = URL(string: updateService.updateURL) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("App Storeで更新")
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
                .background(Color(UIColor.systemBackground))
                .cornerRadius(20)
                .padding()
            }
        }
    }
}

