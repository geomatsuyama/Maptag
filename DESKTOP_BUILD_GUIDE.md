# Map Analyzer - デスクトップ版ビルドガイド

このガイドでは、Map AnalyzerアプリのWindows、Mac、Linux向けデスクトップ版のビルド方法を説明します。

## 📋 前提条件

### 共通
- Flutter SDK 3.35.4以上
- Git

### Windows向け
- Visual Studio 2022 (C++ desktop development workload)
- Windows 10以上

### Mac向け
- Xcode 14以上
- macOS 12 (Monterey)以上
- CocoaPods

### Linux向け
- CMake 3.10以上
- Ninja build system
- GTK 3.0以上の開発ライブラリ

---

## 🔧 環境セットアップ

### Windows

1. **Visual Studio 2022をインストール**
   ```
   https://visualstudio.microsoft.com/downloads/
   
   必要なコンポーネント:
   - Desktop development with C++
   - Windows 10 SDK
   ```

2. **Flutter desktop supportを有効化**
   ```bash
   flutter config --enable-windows-desktop
   ```

### Mac

1. **Xcode Command Line Toolsをインストール**
   ```bash
   xcode-select --install
   ```

2. **CocoaPodsをインストール**
   ```bash
   sudo gem install cocoapods
   ```

3. **Flutter desktop supportを有効化**
   ```bash
   flutter config --enable-macos-desktop
   ```

### Linux

1. **必要なパッケージをインストール**

   **Ubuntu/Debian:**
   ```bash
   sudo apt-get update
   sudo apt-get install -y \
     cmake \
     ninja-build \
     clang \
     libgtk-3-dev \
     liblzma-dev \
     libglu1-mesa-dev
   ```

   **Fedora/RHEL:**
   ```bash
   sudo dnf install -y \
     cmake \
     ninja-build \
     clang \
     gtk3-devel \
     xz-devel \
     mesa-libGLU-devel
   ```

2. **Flutter desktop supportを有効化**
   ```bash
   flutter config --enable-linux-desktop
   ```

---

## 🏗️ ビルド手順

### 1. プロジェクトのクローン/ダウンロード

```bash
# GitHubからクローン (または圧縮ファイルを展開)
cd /path/to/flutter_app
```

### 2. 依存関係のインストール

```bash
flutter pub get
```

### 3. プラットフォームファイルの作成

```bash
# Windows向け
flutter create --platforms=windows .

# Mac向け
flutter create --platforms=macos .

# Linux向け
flutter create --platforms=linux .

# 全プラットフォーム一度に
flutter create --platforms=windows,macos,linux .
```

### 4. リリースビルドの作成

#### Windows
```bash
flutter build windows --release
```

**出力先:**
```
build/windows/x64/runner/Release/
├── map_analyzer.exe       # メインアプリケーション
├── flutter_windows.dll    # Flutter runtime
└── data/                  # アセットとリソース
```

**配布用パッケージング:**
```bash
# Releaseフォルダ全体をZIP圧縮
cd build/windows/x64/runner/
zip -r map_analyzer_windows.zip Release/
```

#### Mac
```bash
flutter build macos --release
```

**出力先:**
```
build/macos/Build/Products/Release/
└── map_analyzer.app       # macOSアプリケーションバンドル
```

**配布用パッケージング:**
```bash
# .appファイルをDMGイメージに変換
hdiutil create -volname "Map Analyzer" \
  -srcfolder build/macos/Build/Products/Release/map_analyzer.app \
  -ov -format UDZO map_analyzer_macos.dmg
```

#### Linux
```bash
flutter build linux --release
```

**出力先:**
```
build/linux/x64/release/bundle/
├── map_analyzer           # 実行ファイル
├── lib/                   # 共有ライブラリ
└── data/                  # アセットとリソース
```

**配布用パッケージング:**
```bash
# AppImage作成 (オプション)
cd build/linux/x64/release/
tar -czf map_analyzer_linux.tar.gz bundle/

# または実行可能スクリプトを作成
cat > run.sh << 'EOF'
#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR/bundle"
./map_analyzer
EOF
chmod +x run.sh
```

---

## 🚀 アプリケーションの実行

### Windows
```
map_analyzer.exe
```

### Mac
```
open map_analyzer.app
```

### Linux
```
./map_analyzer
```

---

## 📦 配布パッケージの作成

### Windows Installer (Inno Setup)

1. **Inno Setupをインストール**
   ```
   https://jrsoftware.org/isdl.php
   ```

2. **インストーラースクリプト作成** (`installer.iss`):
   ```ini
   [Setup]
   AppName=Map Analyzer
   AppVersion=1.0.0
   DefaultDirName={pf}\MapAnalyzer
   DefaultGroupName=Map Analyzer
   OutputDir=output
   OutputBaseFilename=MapAnalyzer_Setup
   
   [Files]
   Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs
   
   [Icons]
   Name: "{group}\Map Analyzer"; Filename: "{app}\map_analyzer.exe"
   Name: "{commondesktop}\Map Analyzer"; Filename: "{app}\map_analyzer.exe"
   ```

3. **ビルド実行**
   ```bash
   iscc installer.iss
   ```

### Mac DMG

```bash
# create-dmg ツールを使用
brew install create-dmg

create-dmg \
  --volname "Map Analyzer" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --app-drop-link 600 185 \
  "MapAnalyzer.dmg" \
  "build/macos/Build/Products/Release/map_analyzer.app"
```

### Linux Snap Package

1. **snapcraft.yamlを作成**:
   ```yaml
   name: map-analyzer
   version: '1.0.0'
   summary: Mapillary API and Gemini AI integration
   description: |
     Map Analyzer integrates Mapillary street view images with Gemini AI
     for advanced image analysis and GIS data export.
   
   base: core22
   confinement: strict
   grade: stable
   
   parts:
     map-analyzer:
       plugin: flutter
       source: .
       flutter-target: lib/main.dart
   
   apps:
     map-analyzer:
       command: map_analyzer
       extensions: [gnome]
   ```

2. **Snapパッケージビルド**:
   ```bash
   snapcraft
   ```

---

## 🎯 ビルドサイズの最適化

### リリースビルドオプション
```bash
# サイズ最適化
flutter build <platform> --release --split-debug-info=debug_info --obfuscate

# Tree-shaking有効化 (不要なコード削除)
flutter build <platform> --release --tree-shake-icons
```

---

## 🔍 トラブルシューティング

### Windows: Visual Studioエラー
```
エラー: Visual Studio not found
解決: Visual Studio 2022のC++デスクトップ開発をインストール
```

### Mac: Codesign エラー
```
エラー: Code signing failed
解決: 
1. Xcode > Preferences > Accounts > Apple IDでサインイン
2. Signing & Capabilities > Signing を設定
```

### Linux: GTK エラー
```
エラー: gtk-3.0 not found
解決: sudo apt-get install libgtk-3-dev
```

---

## 📊 ビルドサイズ比較

| プラットフォーム | サイズ (圧縮前) | サイズ (圧縮後) |
|-----------------|----------------|----------------|
| Windows         | ~60 MB         | ~25 MB         |
| macOS           | ~45 MB         | ~20 MB         |
| Linux           | ~55 MB         | ~23 MB         |

---

## 🌐 Webバージョンとの違い

| 機能 | Web | Desktop |
|------|-----|---------|
| ファイルシステムアクセス | 制限あり | フルアクセス |
| パフォーマンス | 中 | 高 |
| オフライン動作 | 限定的 | 完全対応 |
| インストール | 不要 | 必要 |
| 自動更新 | 自動 | 手動 |

---

## 💡 推奨: クロスプラットフォームビルド

同じマシンですべてのプラットフォーム向けにビルドすることはできません。
以下のような環境を推奨します:

- **Windows開発**: Windows PC (Windowsビルド)
- **Mac開発**: Mac (macOS + iOSビルド)
- **Linux開発**: Linux PC (Linuxビルド)
- **Web**: どのプラットフォームでも可能

または、GitHub ActionsなどのCI/CDを利用して自動ビルドを設定できます。

---

## 📞 サポート

問題が発生した場合:
1. `flutter doctor -v` で環境を確認
2. `flutter clean` で一時ファイルをクリア
3. 依存関係を再インストール: `flutter pub get`

---

## ✅ チェックリスト

デスクトップ版リリース前:
- [ ] すべての依存関係がインストール済み
- [ ] リリースビルドが正常に完了
- [ ] アプリが起動して動作確認済み
- [ ] APIキー設定が正常に保存される
- [ ] ファイルエクスポート機能が動作
- [ ] アイコンとアセットが正しく表示される
- [ ] 配布パッケージのサイズを確認

---

**Map Analyzer v1.0.0**
© 2025 - All Rights Reserved
