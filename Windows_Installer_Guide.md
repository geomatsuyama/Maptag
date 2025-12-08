# Map Analyzer - Windowsインストーラー作成ガイド

## 📋 概要

このガイドでは、Map AnalyzerアプリのWindows向けインストーラーを作成する方法を説明します。

## 🛠️ 必要なツール

### 1. Flutter開発環境 (Windows PCで実行)
```powershell
# Flutter SDKのインストール
# https://docs.flutter.dev/get-started/install/windows からダウンロード

# 環境確認
flutter doctor -v
```

### 2. インストーラー作成ツール

#### オプション A: **Inno Setup** (推奨 - 無料)
- **ダウンロード**: https://jrsoftware.org/isdl.php
- **特徴**: 
  - 完全無料・オープンソース
  - 小さなインストーラーサイズ
  - スクリプトベースで柔軟性が高い
  - Windows標準のインストール体験

#### オプション B: **Advanced Installer** (有料・機能豊富)
- **ダウンロード**: https://www.advancedinstaller.com/
- **特徴**:
  - GUIベースで直感的
  - 自動更新機能付き
  - MSI形式対応

#### オプション C: **NSIS** (無料・軽量)
- **ダウンロード**: https://nsis.sourceforge.io/Download
- **特徴**:
  - 超軽量インストーラー
  - スクリプトベース

---

## 📦 ステップ1: Windowsアプリのビルド

### 1-1. リポジトリのクローン (Windows PC)
```powershell
git clone https://github.com/geomatsuyama/Maptag.git
cd Maptag
```

### 1-2. 依存関係のインストール
```powershell
flutter pub get
```

### 1-3. Windowsリリースビルド
```powershell
flutter build windows --release
```

ビルド完了後、以下のパスに実行ファイルが作成されます:
```
build/windows/x64/runner/Release/
├── map_analyzer.exe         ← メイン実行ファイル
├── flutter_windows.dll      ← Flutter実行環境
├── data/                     ← アプリデータ
└── その他必要なDLLファイル
```

---

## 📋 ステップ2: Inno Setupでインストーラー作成 (推奨)

### 2-1. Inno Setup スクリプトの作成

プロジェクトルートに `installer_script.iss` を作成:

**完全なスクリプトは `installer_script.iss` ファイルに含まれています。**

### 2-2. インストーラービルド方法

#### 🚀 方法1: 自動ビルドスクリプト (推奨)

```powershell
# PowerShellで実行
.\build_installer.ps1
```

このスクリプトは自動的に:
1. Flutter環境をチェック
2. 依存関係をインストール (`flutter pub get`)
3. Windowsリリースビルド実行 (`flutter build windows --release`)
4. ビルドファイル確認
5. Inno Setupでインストーラービルド

**出力ファイル**: `installer_output\MapAnalyzer_Setup_v1.0.0.exe`

---

#### 方法2: 手動ビルド

1. **Inno Setup Compilerを起動**
2. `installer_script.iss` を開く
3. **Build** → **Compile** をクリック
4. インストーラーが `installer_output\` フォルダに生成されます

---

## 📤 ステップ3: インストーラーの配布

### 3-1. GitHubリリースでの配布 (推奨)

```powershell
# 1. GitHubにタグを作成
git tag -a v1.0.0 -m "Release version 1.0.0 with Windows installer"
git push origin v1.0.0

# 2. GitHub Releasesページでインストーラーをアップロード
# https://github.com/geomatsuyama/Maptag/releases/new
```

**アップロード内容**:
- `MapAnalyzer_Setup_v1.0.0.exe` (インストーラー)
- `README.md` (使用方法)
- `推奨スペック.md` (システム要件)

### 3-2. 直接配布

生成されたインストーラー (`MapAnalyzer_Setup_v1.0.0.exe`) を:
- ファイル共有サービス (Google Drive, Dropbox等)
- 組織内ネットワーク
- USBメモリ

で配布できます。

---

## 🔒 セキュリティと署名 (オプション)

### コード署名 (推奨)

Windows Defenderの警告を回避するため、インストーラーにデジタル署名を追加できます:

```powershell
# SignToolを使用 (Windows SDKに含まれる)
signtool sign /f your_certificate.pfx /p password /t http://timestamp.digicert.com installer_output\MapAnalyzer_Setup_v1.0.0.exe
```

**デジタル証明書の取得**:
- **商用**: DigiCert, Sectigo, Comodoなど ($200〜/年)
- **個人**: 自己署名証明書 (無料、警告表示あり)

---

## 🎯 インストーラーの機能

生成されるインストーラーには以下の機能が含まれます:

### ✅ インストール機能
- ✔️ **自動セットアップ**: ワンクリックインストール
- ✔️ **カスタムインストール先**: ユーザー指定可能
- ✔️ **スタートメニュー登録**: 自動でショートカット作成
- ✔️ **デスクトップアイコン**: オプション選択可能
- ✔️ **システム要件チェック**: Windows 10以降必須
- ✔️ **日本語・英語対応**: 言語自動選択

### ✅ アンインストール機能
- ✔️ **完全削除**: クリーンアンインストール
- ✔️ **設定削除オプション**: ユーザーデータ保持/削除選択可能

### ✅ 付属ドキュメント
- ✔️ README.md
- ✔️ 推奨スペック.md
- ✔️ 新機能ガイド.md

---

## 📊 インストーラーサイズ目安

| コンポーネント | サイズ |
|---------------|--------|
| Map Analyzer実行ファイル | ~50 MB |
| Flutter Runtime DLL | ~10 MB |
| データファイル | ~5 MB |
| **合計 (圧縮後)** | **約30-40 MB** |

---

## 🐛 トラブルシューティング

### エラー: "flutter: コマンドが見つかりません"
**解決策**: Flutterの環境変数PATHが設定されていません。
```powershell
# Flutter SDKのbinフォルダをPATHに追加
$env:Path += ";C:\flutter\bin"
```

### エラー: "build windows is only supported on Windows hosts"
**解決策**: このビルドはWindows PCでのみ実行できます。Linux/macOSでは実行できません。

### エラー: "Inno Setupが見つかりません"
**解決策**: https://jrsoftware.org/isdl.php からInno Setupをダウンロード・インストールしてください。

### インストーラー実行時に警告が表示される
**原因**: デジタル署名がないため、Windows Defenderが警告を表示します。  
**解決策**: 
1. **ユーザー側**: "詳細情報" → "実行" で続行可能
2. **開発者側**: コード署名証明書でインストーラーに署名

---

## 📝 チェックリスト

- [ ] Windows PCでFlutter環境構築
- [ ] GitHubリポジトリをクローン
- [ ] `flutter pub get` で依存関係インストール
- [ ] `flutter build windows --release` でビルド
- [ ] Inno Setupインストール
- [ ] `build_installer.ps1` 実行 or `installer_script.iss` を手動コンパイル
- [ ] インストーラーの動作テスト
- [ ] GitHubリリースページにアップロード
- [ ] ユーザーに配布

---

## 🎊 完了!

これでMap AnalyzerのWindows向けインストーラーが完成しました!

**生成ファイル**:
- `installer_output\MapAnalyzer_Setup_v1.0.0.exe`

**配布先**:
- GitHub Releases: https://github.com/geomatsuyama/Maptag/releases

---

## 📞 サポート

問題が発生した場合は、GitHubリポジトリでIssueを作成してください:
https://github.com/geomatsuyama/Maptag/issues
