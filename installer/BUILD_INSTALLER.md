# Map Analyzer - Windowsインストーラービルドガイド

このガイドでは、Map AnalyzerのWindows向けインストーラーをInno Setupで作成する手順を説明します。

---

## 📋 前提条件

### 必須ソフトウェア

1. **Inno Setup 6.x**
   - ダウンロード: https://jrsoftware.org/isdl.php
   - インストール: `innosetup-6.x.x.exe` を実行
   - 言語パック: 日本語サポートを含む

2. **Flutter SDK**
   - バージョン: 3.35.4以上
   - Windows desktop support有効化済み

3. **Visual Studio 2022**
   - C++ desktop development workload
   - Windows 10 SDK

### ビルド前チェックリスト

- [ ] Flutter Windows リリースビルドが正常に完了している
- [ ] `build/windows/x64/runner/Release/` に実行ファイルが存在する
- [ ] アプリが正常に起動・動作することを確認済み
- [ ] ドキュメント (README.md, LICENSE.txt等) が最新版である

---

## 🏗️ ビルド手順

### ステップ1: Flutterアプリのリリースビルド

まず、Windows向けのFlutterリリースビルドを作成します:

```bash
# プロジェクトディレクトリに移動
cd /path/to/flutter_app

# 依存関係をインストール
flutter pub get

# Windowsリリースビルドを作成
flutter build windows --release

# ビルド成功を確認
dir build\windows\x64\runner\Release\map_analyzer.exe
```

**出力先:**
```
build/windows/x64/runner/Release/
├── map_analyzer.exe          # メインアプリケーション (約15MB)
├── flutter_windows.dll       # Flutter runtime (約2MB)
├── data/                     # アセットとリソース (約10MB)
│   ├── icudtl.dat
│   ├── flutter_assets/
│   └── ...
├── file_picker_plugin.dll    # file_pickerプラグイン
├── url_launcher_windows_plugin.dll  # url_launcherプラグイン
└── ...
```

**ビルドサイズ:**
- 合計: 約60MB (圧縮前)
- インストーラー: 約25-30MB (圧縮後)

---

### ステップ2: アイコンとドキュメントの準備

インストーラー用のアイコンとドキュメントを準備します:

```bash
# installerディレクトリを作成 (既に存在する場合はスキップ)
mkdir installer
mkdir installer\output

# アイコンファイルを配置
# (既存のアイコンを icon.ico に変換、または以下のツールで生成)
# https://convertio.co/png-ico/

# 必要なドキュメントを確認
dir README.md
dir LICENSE.txt
dir 推奨スペック.md
dir DESKTOP_BUILD_GUIDE.md
```

**必須ファイル:**
- `LICENSE.txt` - アプリケーションライセンス
- `installer/icon.ico` - インストーラーアイコン (256x256推奨)
- `installer/README_INSTALLER.txt` - インストール案内文 (既に作成済み)
- `installer/windows_installer.iss` - Inno Setupスクリプト (既に作成済み)

**LICENSE.txtが無い場合は作成:**
```bash
# MIT Licenseテンプレート (例)
cat > LICENSE.txt << 'EOF'
MIT License

Copyright (c) 2025 MapAnalyzer Project

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
```

---

### ステップ3: Inno Setupでインストーラーをビルド

#### 方法A: GUI経由でビルド (推奨・初心者向け)

1. **Inno Setup Compilerを起動**
   - スタートメニュー → Inno Setup → Inno Setup Compiler

2. **スクリプトを開く**
   - `File` → `Open` → `flutter_app/installer/windows_installer.iss` を選択

3. **設定を確認**
   - スクリプト内のパスとバージョン情報を確認
   - 必要に応じて編集 (バージョン、出力ディレクトリ等)

4. **ビルド実行**
   - `Build` → `Compile` (または F9キー)
   - ビルドログを確認

5. **出力確認**
   - 成功すると `installer/output/MapAnalyzer_Setup_v1.0.0_x64.exe` が生成される

#### 方法B: コマンドライン経由でビルド (自動化向け)

```bash
# Inno Setup Compilerのパス (デフォルトインストール先)
set ISCC="C:\Program Files (x86)\Inno Setup 6\ISCC.exe"

# インストーラースクリプトをコンパイル
%ISCC% "flutter_app\installer\windows_installer.iss"

# 出力確認
dir flutter_app\installer\output\MapAnalyzer_Setup_v1.0.0_x64.exe
```

**ビルドオプション:**
```bash
# 詳細ログ出力
%ISCC% /V5 "flutter_app\installer\windows_installer.iss"

# 出力ディレクトリを変更
%ISCC% /O"C:\Builds" "flutter_app\installer\windows_installer.iss"

# 複数スクリプトを一括ビルド
%ISCC% /Q "flutter_app\installer\*.iss"
```

---

### ステップ4: インストーラーのテスト

ビルドしたインストーラーを実際にテストします:

1. **テスト環境の準備**
   - クリーンなWindows環境 (仮想マシン推奨)
   - Visual C++ Redistributableが**未インストール**の状態

2. **インストーラーを実行**
   ```bash
   MapAnalyzer_Setup_v1.0.0_x64.exe
   ```

3. **インストールフローを確認**
   - 言語選択 (日本語/英語)
   - ライセンス同意画面
   - インストール先指定
   - タスク選択 (デスクトップアイコン等)
   - インストール実行
   - 完了後の起動オプション

4. **インストール後の確認**
   - スタートメニューにアイコンが追加されているか
   - デスクトップアイコンが作成されているか
   - アプリが正常に起動するか
   - 設定画面でAPIキーが保存できるか

5. **アンインストールテスト**
   - コントロールパネル → プログラムと機能 → Map Analyzerをアンインストール
   - ユーザー設定ファイルが削除されているか確認

---

## 🔧 カスタマイズ

### バージョン番号の変更

`installer/windows_installer.iss` の冒頭を編集:

```ini
#define MyAppVersion "1.1.0"  ; バージョンを更新
```

### アプリ名の変更

```ini
#define MyAppName "My Custom Analyzer"
```

### インストール先の変更

```ini
DefaultDirName={autopf}\MyCustomPath
```

### 言語追加

```ini
[Languages]
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
```

### Visual C++ Redistributable自動インストール (高度)

**注意:** これには別途VC++ Redistributableインストーラーファイルが必要です。

```ini
[Files]
Source: "vc_redist.x64.exe"; DestDir: {tmp}; Flags: deleteafterinstall

[Run]
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "Installing Visual C++ Redistributable..."; Check: VCRedistNeedsInstall
```

---

## 📦 配布

### インストーラーの配布方法

1. **GitHub Releases**
   ```bash
   # GitHubリリースにアップロード
   gh release create v1.0.0 installer/output/MapAnalyzer_Setup_v1.0.0_x64.exe \
     --title "Map Analyzer v1.0.0" \
     --notes "詳細な変更履歴..."
   ```

2. **直接ダウンロード**
   - インストーラーを自社サーバーにアップロード
   - ダウンロードリンクをWebサイトに掲載

3. **クラウドストレージ**
   - Google Drive、OneDrive、Dropbox等
   - 公開リンクを共有

### 配布前チェックリスト

- [ ] ファイル名にバージョン番号が含まれている
- [ ] ファイルサイズが妥当 (25-35MB程度)
- [ ] デジタル署名 (オプション、推奨)
- [ ] ウイルススキャン完了
- [ ] テスト環境でのインストール確認
- [ ] README、ライセンス等のドキュメント同梱確認

---

## 🛡️ デジタル署名 (オプション・推奨)

信頼性を高めるため、インストーラーにデジタル署名を付与できます:

### 必要なもの
- コード署名証明書 (Code Signing Certificate)
- SignTool.exe (Windows SDK付属)

### 署名手順

```bash
# Windows SDKのSignToolパス
set SIGNTOOL="C:\Program Files (x86)\Windows Kits\10\bin\10.0.22000.0\x64\signtool.exe"

# インストーラーに署名
%SIGNTOOL% sign /f "certificate.pfx" /p "password" /tr http://timestamp.digicert.com /td sha256 /fd sha256 "MapAnalyzer_Setup_v1.0.0_x64.exe"
```

---

## 🔍 トラブルシューティング

### エラー: "Source file does not exist"

**原因:** Flutterビルドが完了していない、またはパスが間違っている

**解決策:**
```bash
# ビルドを再実行
flutter clean
flutter pub get
flutter build windows --release

# ファイルの存在確認
dir build\windows\x64\runner\Release\map_analyzer.exe
```

### エラー: "Cannot open file LICENSE.txt"

**原因:** LICENSE.txtファイルが存在しない

**解決策:**
```bash
# LICENSE.txtを作成 (ステップ2参照)
# またはInno Setupスクリプトから削除:
# LicenseFile=..\LICENSE.txt  ← この行をコメントアウト
```

### 警告: "Japanese.isl not found"

**原因:** Inno Setup日本語言語ファイルが未インストール

**解決策:**
```ini
; 日本語言語ファイルを削除またはコメントアウト
;Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
```

### インストーラー実行時: "Visual C++ Redistributable not found"

**原因:** VC++ Redistributable未インストール

**解決策:**
- ユーザーに以下をインストールしてもらう:
  https://aka.ms/vs/17/release/vc_redist.x64.exe

---

## 📊 ビルド時間とサイズ

| ステップ | 所要時間 | 出力サイズ |
|---------|---------|-----------|
| Flutter Windows build | 5-10分 | 60MB |
| Inno Setup compile | 1-2分 | 25-30MB |
| デジタル署名 (オプション) | 30秒 | - |
| **合計** | **約10-15分** | **25-30MB** |

---

## 🚀 自動化 (CI/CD)

GitHub Actionsで自動ビルドを設定する例:

```yaml
name: Build Windows Installer

on:
  push:
    tags:
      - 'v*'

jobs:
  build-installer:
    runs-on: windows-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.35.4'
        channel: 'stable'
    
    - name: Build Flutter Windows
      run: |
        flutter pub get
        flutter build windows --release
    
    - name: Install Inno Setup
      run: choco install innosetup -y
    
    - name: Build Installer
      run: |
        & "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" "installer\windows_installer.iss"
    
    - name: Upload Installer
      uses: actions/upload-artifact@v3
      with:
        name: windows-installer
        path: installer/output/*.exe
    
    - name: Create Release
      uses: softprops/action-gh-release@v1
      with:
        files: installer/output/*.exe
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## 📞 サポート

問題が発生した場合:
1. Inno Setupビルドログを確認 (`Build` → `View Output`)
2. Flutter Windowsビルドが成功していることを確認
3. 必要なファイルがすべて存在するか確認

---

## ✅ 完了チェックリスト

- [ ] Flutter Windows リリースビルド完了
- [ ] LICENSE.txt、README.md等のドキュメント準備完了
- [ ] Inno Setupインストーラースクリプト設定完了
- [ ] インストーラービルド成功
- [ ] クリーンな環境でインストールテスト完了
- [ ] アプリケーション動作確認完了
- [ ] アンインストールテスト完了
- [ ] (オプション) デジタル署名完了
- [ ] 配布パッケージ準備完了

---

**Map Analyzer v1.0.0**
© 2025 MapAnalyzer Project
