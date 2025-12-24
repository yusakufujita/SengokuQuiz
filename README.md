# 戦国時代クイズアプリ

戦国時代に関するクイズアプリです。100問を10問ずつに分けて出題し、正解数に応じてレベルが上がるシステムです。

## 機能

- **レベルシステム**: 小大名 → 大大名 → 群雄 → 覇者 → 天下人
- **進捗管理**: 100問正解で大大名、さらに100問正解で群雄に昇格
- **広告表示**: 10問解くごとにインターステイシャル広告を表示
- **バナー広告**: 画面下部に常時表示
- **プレミアムプラン**: 月額500円でインターステイシャル広告を削除
- **Firebase強制アップデート**: Remote Configを使用した強制アップデート機能
- **ATT許可ダイアログ**: App Tracking Transparencyの許可ダイアログ表示

## セットアップ

### 1. Firebaseの設定

1. Firebase Consoleでプロジェクトを作成
2. iOSアプリを追加
3. `GoogleService-Info.plist`をダウンロードしてプロジェクトに追加
4. Firebase Remote Configで以下のキーを設定:
   - `minimum_version`: 最小バージョン（例: "1.0.0"）
   - `force_update_message`: アップデートメッセージ
   - `update_url`: App StoreのURL

### 2. AdMobの設定

1. AdMobでアプリを登録
2. バナー広告とインターステイシャル広告のユニットIDを取得
3. `AdManager.swift`の以下の部分を実際のIDに置き換え:
   ```swift
   private let bannerAdUnitID = "YOUR_BANNER_AD_UNIT_ID"
   private let interstitialAdUnitID = "YOUR_INTERSTITIAL_AD_UNIT_ID"
   ```

### 3. App Store Connectの設定

1. App Store Connectでアプリを登録
2. サブスクリプション商品を作成（月額500円）
3. `PremiumManager.swift`の`premiumProductID`を実際のプロダクトIDに置き換え:
   ```swift
   let premiumProductID = "com.yourcompany.sengokuquiz.premium.monthly"
   ```

### 4. Info.plistの設定

`Info.plist`に以下のキーを追加:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>広告のパーソナライズのためにトラッキングを使用します。</string>
```

## 問題の追加方法

問題を追加するには、`Services/QuizDataService.swift`の`loadQuestions()`メソッドを編集してください。

```swift
private func loadQuestions() {
    let questions = [
        QuizQuestion(
            id: 1,
            question: "問題文",
            options: ["選択肢1", "選択肢2", "選択肢3", "選択肢4"],
            correctAnswer: 0, // 0-3のインデックス
            explanation: "解説（オプション）"
        ),
        // さらに問題を追加...
    ]
    self.questionSet = QuizQuestionSet(questions: questions)
}
```

### 問題の形式

- `id`: 問題の一意のID（Int）
- `question`: 問題文（String）
- `options`: 選択肢の配列（[String]、4つ）
- `correctAnswer`: 正解のインデックス（Int、0-3）
- `explanation`: 解説（String?、オプション）

## アーキテクチャ

### モデル
- `QuizQuestion`: クイズ問題のデータモデル
- `UserLevel`: ユーザーレベルの定義
- `UserProgress`: ユーザーの進捗管理

### サービス
- `QuizDataService`: クイズデータの管理
- `AdManager`: 広告の管理
- `PremiumManager`: プレミアムプランの管理
- `FirebaseUpdateService`: Firebase強制アップデートの管理
- `ATTService`: App Tracking Transparencyの管理

### ビュー
- `MainView`: メイン画面（クイズ画面とバナー広告）
- `QuizView`: クイズ画面
- `PremiumView`: プレミアムプラン購入画面
- `UpdateRequiredView`: 強制アップデートダイアログ
- `BannerAdView`: バナー広告ビュー
- `InterstitialAdViewController`: インターステイシャル広告表示用

## レベルシステム

- **小大名**: 初期レベル（0問正解）
- **大大名**: 100問正解で昇格
- **群雄**: 200問正解で昇格
- **覇者**: 300問正解で昇格
- **天下人**: 400問正解で昇格

## ライセンス

このプロジェクトは個人利用のためのものです。

