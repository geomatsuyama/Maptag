# 📦 Map Analyzer - Windowsインストーラー クイックスタートガイド

## 🚀 5分で完了! インストーラー作成手順

このガイドでは、最短でMap AnalyzerのWindowsインストーラーを作成する方法を説明します。

---

## 前提条件

✅ **必須ソフトウェア:**
- Inno Setup 6.x (https://jrsoftware.org/isdl.php)
- Flutter SDK 3.35.4以上 (既にインストール済み)
- Visual Studio 2022 with C++ (既にインストール済み)

✅ **環境確認:**
```bash
flutter --version  # Flutter 3.35.4以上
flutter doctor     # すべてOKまたは軽微な警告のみ
```

---

## 📝 手順1: Flutterアプリをビルド (5-10分)

Windows PCで以下を実行:

```bash
# プロジェクトディレクトリに移動
cd C:\path\to\flutter_app

# 依存関係をインストール
flutter pub get

# Windowsリリースビルド
flutter build windows --release
```

✅ **成功確認:**
```bash
dir build\windows\x64\runner\Release\map_analyzer.exe
```

---

## 📝 手順2: 必要ファイルを確認 (1分)

以下のファイルが存在するか確認:

```
flutter_app/
├── build/windows/x64/runner/Release/
│   ├── map_analyzer.exe ✅
│   ├── flutter_windows.dll ✅
│   └── data/ ✅
├── installer/
│   ├── windows_installer.iss ✅ (作成済み)
│   └── README_INSTALLER.txt ✅ (作成済み)
├── LICENSE.txt ✅ (作成済み)
└── README.md ✅ (既存)
```

**⚠️ アイコンファイルについて:**
`installer/icon.ico` が無い場合、スクリプト内のアイコン設定をコメントアウトしてください:

```ini
; SetupIconFile=..\installer\icon.ico  ← この行をコメントアウト
```

---

## 📝 手順3: Inno Setupでビルド (1-2分)

### 方法A: GUI (初心者推奨)

1. **Inno Setup Compiler** を起動
2. `File` → `Open` → `flutter_app\installer\windows_installer.iss`
3. `Build` → `Compile` (F9キー)
4. 完了! 🎉

### 方法B: コマンドライン (自動化向け)

```bash
# PowerShellで実行
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" "C:\path\to\flutter_app\installer\windows_installer.iss"
```

✅ **出力確認:**
```bash
dir installer\output\MapAnalyzer_Setup_v1.0.0_x64.exe
```

**ファイルサイズ:** 約25-30MB

---

## 📝 手順4: インストーラーをテスト (3-5分)

1. **インストーラーを実行**
   ```
   installer\output\MapAnalyzer_Setup_v1.0.0_x64.exe
   ```

2. **インストールウィザードに従う**
   - 言語選択 (日本語/English)
   - ライセンス同意
   - インストール先選択
   - デスクトップアイコン作成オプション
   - インストール実行

3. **起動確認**
   - スタートメニューから Map Analyzer を起動
   - 設定画面でAPIキー入力欄が表示されるか確認

4. **アンインストールテスト (オプション)**
   - コントロールパネル → プログラムと機能
   - Map Analyzer をアンインストール

---

## 🎯 完了!

✅ インストーラー作成完了:
```
installer/output/MapAnalyzer_Setup_v1.0.0_x64.exe
```

このファイルを配布すれば、ユーザーは簡単にMap Analyzerをインストールできます!

---

## 📤 配布方法

### GitHub Releasesにアップロード

```bash
# GitHub CLIを使用
gh release create v1.0.0 installer\output\MapAnalyzer_Setup_v1.0.0_x64.exe ^
  --title "Map Analyzer v1.0.0 - Windows Installer" ^
  --notes "## ダウンロード%0A%0AWindows用インストーラーをダウンロードして実行してください。"
```

### 直接配布

- Google Drive
- OneDrive
- Dropbox
- 自社サーバー

---

## 🔧 トラブルシューティング

### ❌ "Source file does not exist" エラー

**原因:** Flutterビルドが完了していない

**解決:**
```bash
flutter clean
flutter pub get
flutter build windows --release
```

### ❌ "Cannot open LICENSE.txt" エラー

**原因:** LICENSE.txtファイルが存在しない (既に作成済みのため通常発生しません)

**解決:** `windows_installer.iss` の該当行をコメントアウト:
```ini
;LicenseFile=..\LICENSE.txt
```

### ❌ インストール後にアプリが起動しない

**原因:** Visual C++ Redistributableが未インストール

**解決:** 以下をインストール:
https://aka.ms/vs/17/release/vc_redist.x64.exe

---

## 📚 詳細ドキュメント

より詳細な情報は以下を参照:
- `installer/BUILD_INSTALLER.md` - 完全ビルドガイド
- `DESKTOP_BUILD_GUIDE.md` - デスクトップ版ビルド全般
- `推奨スペック.md` - システム要件

---

## ✅ チェックリスト

- [ ] Flutter Windows ビルド完了
- [ ] Inno Setup インストール済み
- [ ] インストーラービルド成功
- [ ] テスト環境でインストール確認
- [ ] アプリ起動・動作確認
- [ ] 配布パッケージ準備完了

---

**所要時間:** 約10-15分
**出力サイズ:** 約25-30MB
**対象OS:** Windows 10 (1809以上) / Windows 11

**Map Analyzer v1.0.0**
© 2025 MapAnalyzer Project
