# Map Analyzer - PC版ビルドガイド (簡易版)

## 🖥️ PC版について

Map Analyzerは**Windows、Mac、Linux**のデスクトップアプリとして動作します。

### 📱 Web版 vs PC版

| 機能 | Web版 | PC版 |
|------|-------|------|
| **インストール** | 不要 | 必要 |
| **起動速度** | ブラウザに依存 | 高速 |
| **ファイルアクセス** | 制限あり | 完全 |
| **オフライン動作** | ✗ | ✅ |
| **パフォーマンス** | 中 | 高 |

---

## ⚡ クイックスタート (各OS)

### 🪟 Windows版

**必要なもの:**
- Windows 10以上
- Visual Studio 2022 (C++ desktop development)

**ビルド手順:**
```bash
# 1. プロジェクトディレクトリに移動
cd flutter_app

# 2. Windows対応を有効化
flutter config --enable-windows-desktop

# 3. Windowsプラットフォームファイル作成
flutter create --platforms=windows .

# 4. ビルド実行
flutter build windows --release
```

**実行ファイル:**
```
build/windows/x64/runner/Release/map_analyzer.exe
```

**配布方法:**
`Release`フォルダ全体をZIP圧縮して配布

---

### 🍎 Mac版

**必要なもの:**
- macOS 12 (Monterey)以上
- Xcode 14以上

**ビルド手順:**
```bash
# 1. プロジェクトディレクトリに移動
cd flutter_app

# 2. macOS対応を有効化
flutter config --enable-macos-desktop

# 3. macOSプラットフォームファイル作成
flutter create --platforms=macos .

# 4. ビルド実行
flutter build macos --release
```

**実行ファイル:**
```
build/macos/Build/Products/Release/map_analyzer.app
```

**配布方法:**
`.app`ファイルをDMGイメージに変換して配布

---

### 🐧 Linux版

**必要なもの:**
- Ubuntu 20.04以上 (または他のLinuxディストリビューション)
- CMake、Ninja、GTK 3.0開発ライブラリ

**依存関係インストール (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install -y cmake ninja-build libgtk-3-dev
```

**ビルド手順:**
```bash
# 1. プロジェクトディレクトリに移動
cd flutter_app

# 2. Linux対応を有効化
flutter config --enable-linux-desktop

# 3. Linuxプラットフォームファイル作成
flutter create --platforms=linux .

# 4. ビルド実行
flutter build linux --release
```

**実行ファイル:**
```
build/linux/x64/release/bundle/map_analyzer
```

**配布方法:**
`bundle`フォルダ全体をtar.gz圧縮して配布

---

## 📦 配布パッケージの作成

### Windows (ZIP)
```bash
cd build/windows/x64/runner/
# PowerShellで圧縮
Compress-Archive -Path Release -DestinationPath map_analyzer_windows.zip
```

### Mac (DMG)
```bash
# create-dmgツール使用
brew install create-dmg
create-dmg --volname "Map Analyzer" \
  MapAnalyzer.dmg \
  build/macos/Build/Products/Release/map_analyzer.app
```

### Linux (TAR.GZ)
```bash
cd build/linux/x64/release/
tar -czf map_analyzer_linux.tar.gz bundle/
```

---

## 🎯 実行方法

### Windows
```
map_analyzer.exe をダブルクリック
```

### Mac
```
map_analyzer.app をダブルクリック
(初回はセキュリティ設定で許可が必要)
```

### Linux
```bash
cd bundle
./map_analyzer
```

---

## ⚙️ 開発者向け: デバッグ実行

### すべてのプラットフォーム
```bash
# デバッグモードで起動
flutter run -d windows  # Windows
flutter run -d macos    # Mac
flutter run -d linux    # Linux

# リリースモードで起動
flutter run --release -d <platform>
```

---

## 🔍 トラブルシューティング

### Windows: "Visual Studio not found"
**原因**: Visual Studio 2022がインストールされていない  
**解決**: Visual Studio 2022をインストール (C++ desktop development workload)

### Mac: "Xcode not found"
**原因**: Xcodeがインストールされていない  
**解決**: 
```bash
xcode-select --install
```

### Linux: "CMake not found"
**原因**: CMakeがインストールされていない  
**解決**:
```bash
sudo apt-get install cmake ninja-build libgtk-3-dev
```

---

## 📊 ビルドサイズ

| OS | 圧縮前 | 圧縮後 |
|----|--------|--------|
| Windows | ~60 MB | ~25 MB |
| macOS | ~45 MB | ~20 MB |
| Linux | ~55 MB | ~23 MB |

---

## 🌐 Web版を使う (推奨)

PC版のビルドが面倒な場合、Web版が最も簡単です:

**🔗 プレビューURL**: https://5060-i6w1gve4ssf8ly2hkqauq-02b9cc79.sandbox.novita.ai

- インストール不要
- ブラウザですぐに使える
- すべての機能が利用可能

---

## 💡 推奨環境

### 開発環境
- **Flutter SDK**: 3.35.4
- **Dart**: 3.9.2

### 本番環境
- **RAM**: 最低4GB (推奨8GB以上)
- **ストレージ**: 100MB以上の空き容量
- **ネットワーク**: インターネット接続 (API利用のため)

---

## 📚 詳細ガイド

より詳しいビルド手順や配布方法については、以下のドキュメントを参照してください:

📄 **[DESKTOP_BUILD_GUIDE.md](DESKTOP_BUILD_GUIDE.md)** - 完全版ビルドガイド

---

## ✅ クイックチェックリスト

デスクトップ版ビルド前に確認:

- [ ] Flutter SDK 3.35.4がインストール済み
- [ ] 各OS向けの開発環境が整っている
- [ ] `flutter doctor`でエラーがない
- [ ] プロジェクトディレクトリに移動済み
- [ ] `flutter pub get`で依存関係をインストール済み

---

**Map Analyzer v1.0.0**  
デスクトップ版ビルドガイド - 2025
