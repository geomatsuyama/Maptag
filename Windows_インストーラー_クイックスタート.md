# 🚀 Map Analyzer - Windows向けインストーラー クイックスタートガイド

## 📦 3ステップで完成!

### ステップ1: 必要なツールをインストール

#### 1-1. Inno Setupをダウンロード・インストール
**URL**: https://jrsoftware.org/isdl.php

**インストール手順**:
1. 上記URLから最新版をダウンロード
2. インストーラーを実行
3. 全てデフォルト設定でOK

**所要時間**: 約2分

---

### ステップ2: リポジトリをクローン & ビルド

Windows PC上で以下を実行:

```powershell
# リポジトリをクローン
git clone https://github.com/geomatsuyama/Maptag.git
cd Maptag

# 自動ビルドスクリプトを実行 (これだけでOK!)
.\build_installer.ps1
```

**スクリプトが自動実行する内容**:
1. ✅ Flutter環境チェック
2. ✅ 依存関係インストール (`flutter pub get`)
3. ✅ Windowsリリースビルド (`flutter build windows --release`)
4. ✅ ビルドファイル確認
5. ✅ Inno Setupでインストーラー生成

**所要時間**: 約5-10分 (初回はビルド時間がかかります)

---

### ステップ3: インストーラー完成!

**生成ファイル**:
```
installer_output\MapAnalyzer_Setup_v1.0.0.exe
```

**サイズ**: 約30-40 MB (圧縮済み)

**このファイルで以下が可能**:
- ✅ ワンクリックインストール
- ✅ スタートメニュー登録
- ✅ デスクトップショートカット作成
- ✅ アンインストーラー付属

---

## 🎯 配布方法

### 方法1: GitHub Releasesで配布 (推奨)

```powershell
# 1. バージョンタグを作成
git tag -a v1.0.0 -m "Windows installer release v1.0.0"
git push origin v1.0.0

# 2. GitHub Releasesページへ
# https://github.com/geomatsuyama/Maptag/releases/new
# ここで MapAnalyzer_Setup_v1.0.0.exe をアップロード
```

**ユーザー側の操作**:
1. GitHubのReleasesページからダウンロード
2. `MapAnalyzer_Setup_v1.0.0.exe` をダブルクリック
3. インストール完了!

---

### 方法2: 直接配布

以下のサービスでインストーラーを共有:
- Google Drive
- Dropbox
- OneDrive
- 組織内ファイルサーバー

---

## ⚡ トラブルシューティング

### Q1: "flutter: コマンドが見つかりません"
**A**: Flutterが環境変数PATHに登録されていません。

```powershell
# PowerShellで実行
$env:Path += ";C:\flutter\bin"
```

または、Flutter SDKの公式インストール手順に従ってください:
https://docs.flutter.dev/get-started/install/windows

---

### Q2: Windows Defenderの警告が出る
**A**: デジタル署名がないため警告が出ますが、問題ありません。

**ユーザー側の対応**:
1. 警告画面で「詳細情報」をクリック
2. 「実行」ボタンをクリック
3. インストール続行

**開発者側の対応** (オプション):
- コード署名証明書を購入してインストーラーに署名
- 費用: $200〜/年 (DigiCert, Sectigo等)

---

### Q3: ビルドスクリプトが失敗する
**A**: 以下を確認してください:

```powershell
# Flutter環境確認
flutter doctor -v

# 依存関係の再インストール
flutter clean
flutter pub get

# 再度ビルド実行
.\build_installer.ps1
```

---

## 📊 インストーラーの内容

| 項目 | 詳細 |
|------|------|
| **インストール先** | `C:\Program Files\Map Analyzer\` |
| **スタートメニュー** | ✅ 自動登録 |
| **デスクトップアイコン** | ✅ オプション選択可能 |
| **アンインストーラー** | ✅ 含まれる |
| **言語** | 日本語・英語対応 |
| **システム要件チェック** | Windows 10以降必須 |
| **付属ドキュメント** | README, 推奨スペック, 新機能ガイド |

---

## 🔄 バージョンアップ時

### 新バージョンのインストーラー作成手順

1. **バージョン番号の更新**

`installer_script.iss` の3行目を編集:
```iss
#define MyAppVersion "1.1.0"  ← ここを変更
```

`pubspec.yaml` のバージョンも更新:
```yaml
version: 1.1.0+2  ← ここを変更 (version: バージョン番号+ビルド番号)
```

2. **ビルド実行**

```powershell
.\build_installer.ps1
```

3. **新しいインストーラーが生成**

```
installer_output\MapAnalyzer_Setup_v1.1.0.exe
```

4. **GitHubリリース**

```powershell
git tag -a v1.1.0 -m "Release version 1.1.0"
git push origin v1.1.0
# GitHub Releasesページで新しいインストーラーをアップロード
```

---

## 📝 まとめ

**作業時間**: 合計 **約10-15分**
- Inno Setupインストール: 2分
- リポジトリクローン: 1分
- ビルド実行: 5-10分
- アップロード: 2分

**生成物**: `MapAnalyzer_Setup_v1.0.0.exe` (約30-40 MB)

**配布先**: 
- ✅ GitHub Releases (推奨)
- ✅ ファイル共有サービス
- ✅ 直接配布

---

## 🎉 完了!

これで誰でもインストール可能なWindows向けインストーラーが完成しました!

**詳細ドキュメント**: `Windows_Installer_Guide.md` を参照してください。

**サポート**: https://github.com/geomatsuyama/Maptag/issues

---

**作成者**: Map Analyzer Team  
**ライセンス**: MIT License  
**リポジトリ**: https://github.com/geomatsuyama/Maptag
