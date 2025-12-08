# 📦 Map Analyzer - 全プラットフォーム向けインストーラービルドガイド

## 🌍 概要

このガイドでは、Map Analyzerの**すべてのプラットフォーム**向けインストーラーをビルドする方法を説明します。

### 対応プラットフォーム

| プラットフォーム | インストーラー形式 | ビルド環境 | サイズ |
|-----------------|-------------------|-----------|--------|
| 🪟 Windows | `.exe` (Inno Setup) | Windows | 25-30MB |
| 🍎 macOS | `.dmg` (DMG) | macOS | 20-25MB |
| 🐧 Linux | `.AppImage`, `.deb`, `.snap` | Linux | 23-28MB |

---

## 🪟 Windows インストーラー

### 前提条件
- Windows 10以上
- Flutter SDK 3.35.4+
- Visual Studio 2022 (C++ desktop development)
- Inno Setup 6.x

### ビルド手順

```powershell
# 1. Flutterアプリをビルド
cd /path/to/flutter_app
flutter pub get
flutter build windows --release

# 2. Inno Setupでインストーラー作成
# GUI: Inno Setup Compiler → installer/windows_installer.iss を開く → Compile (F9)

# CLI:
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" "installer\windows_installer.iss"
```

**出力:**
```
installer/output/MapAnalyzer_Setup_v1.0.0_x64.exe
```

**詳細:** [windows_installer.iss](windows_installer.iss), [BUILD_INSTALLER.md](BUILD_INSTALLER.md)

---

## 🍎 macOS DMGインストーラー

### 前提条件
- macOS 12 (Monterey)以上
- Flutter SDK 3.35.4+
- Xcode 14+
- Homebrewと`create-dmg`

### ビルド手順

```bash
# 1. Homebrewで create-dmg をインストール
brew install create-dmg

# 2. Flutterアプリをビルド
cd /path/to/flutter_app
flutter pub get
flutter build macos --release

# 3. DMGインストーラー作成
cd installer/macos
chmod +x create_dmg.sh
./create_dmg.sh
```

**出力:**
```
installer/macos/output/MapAnalyzer_v1.0.0_macOS.dmg
```

### DMG作成の仕組み

`create_dmg.sh`スクリプトは以下を実行します:

1. Flutter buildの検証
2. `create-dmg`ツールで以下を含むDMGを作成:
   - アプリケーションバンドル
   - Applicationsフォルダへのドラッグ&ドロップリンク
   - カスタム背景画像 (オプション)
   - アイコンレイアウト

### インストール (エンドユーザー)

1. DMGファイルをダウンロード
2. ダブルクリックでマウント
3. `Map Analyzer.app` を `Applications` フォルダにドラッグ
4. DMGをイジェクト
5. Launchpadから起動

---

## 🐧 Linux インストーラー (3形式)

### 前提条件
- Ubuntu 20.04+ / Debian 11+ / その他Linux
- Flutter SDK 3.35.4+
- CMake, Ninja, GTK3開発ライブラリ

```bash
# 依存関係インストール (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y cmake ninja-build clang libgtk-3-dev liblzma-dev libglu1-mesa-dev
```

---

### 📦 形式1: AppImage (推奨・ポータブル)

**特徴:**
- ✅ インストール不要、ダウンロードして即実行
- ✅ すべてのLinuxディストリビューションで動作
- ✅ サンドボックス実行
- ✅ 簡単な統合 (AppImageLauncher)

**ビルド手順:**

```bash
# 1. Flutterアプリをビルド
cd /path/to/flutter_app
flutter pub get
flutter build linux --release

# 2. AppImage作成
cd installer/linux
chmod +x create_appimage.sh
./create_appimage.sh
```

**出力:**
```
installer/linux/output/MapAnalyzer-1.0.0-x86_64.AppImage
```

**使用方法 (エンドユーザー):**
```bash
chmod +x MapAnalyzer-1.0.0-x86_64.AppImage
./MapAnalyzer-1.0.0-x86_64.AppImage
```

---

### 📦 形式2: Debian Package (.deb)

**特徴:**
- ✅ Ubuntu/Debian標準のパッケージ形式
- ✅ `apt`で管理可能
- ✅ 依存関係の自動解決
- ✅ システム統合 (デスクトップアイコン、アプリメニュー)

**ビルド手順:**

```bash
# 1. Flutterアプリをビルド
cd /path/to/flutter_app
flutter pub get
flutter build linux --release

# 2. .debパッケージ作成
cd installer/linux
chmod +x create_deb.sh
./create_deb.sh
```

**出力:**
```
installer/linux/output/map-analyzer_1.0.0_amd64.deb
```

**インストール (エンドユーザー):**
```bash
sudo dpkg -i map-analyzer_1.0.0_amd64.deb
sudo apt-get install -f  # 依存関係を修正

# 起動
map-analyzer
```

**アンインストール:**
```bash
sudo apt-get remove map-analyzer
```

---

### 📦 形式3: Snap Package

**特徴:**
- ✅ Ubuntu標準のアプリストア配信
- ✅ 自動更新
- ✅ サンドボックスセキュリティ
- ✅ トランザクショナルアップデート

**ビルド手順:**

```bash
# 1. snapcraft をインストール
sudo snap install snapcraft --classic

# 2. Snapパッケージをビルド
cd /path/to/flutter_app
snapcraft --use-lxd

# または、設定ファイルをコピーして使用
cp installer/linux/create_snap.yaml snapcraft.yaml
snapcraft
```

**出力:**
```
map-analyzer_1.0.0_amd64.snap
```

**インストール (エンドユーザー):**
```bash
sudo snap install map-analyzer_1.0.0_amd64.snap --dangerous
```

**Snap Store公開 (オプション):**
```bash
snapcraft login
snapcraft upload map-analyzer_1.0.0_amd64.snap
snapcraft release map-analyzer 1.0.0 stable
```

---

## 🔧 トラブルシューティング

### Windows

**エラー:** "Source file does not exist"
```powershell
flutter clean
flutter pub get
flutter build windows --release
```

### macOS

**エラー:** "create-dmg: command not found"
```bash
brew install create-dmg
```

**エラー:** "Code signing required"
```bash
# 開発者モードでスキップ
# または、Xcodeでコード署名を設定
```

### Linux

**エラー:** "appimagetool not found"
```bash
# スクリプトが自動ダウンロード、または手動で:
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage
sudo mv appimagetool-x86_64.AppImage /usr/local/bin/appimagetool
```

**エラー:** "dpkg-deb: command not found"
```bash
sudo apt-get install dpkg
```

---

## 📊 ビルド時間とサイズ比較

| プラットフォーム | ビルド時間 | サイズ (圧縮前) | サイズ (圧縮後) |
|-----------------|-----------|----------------|----------------|
| Windows `.exe` | 10-15分 | 60MB | 25-30MB |
| macOS `.dmg` | 8-12分 | 45MB | 20-25MB |
| Linux `.AppImage` | 7-10分 | 55MB | 23-28MB |
| Linux `.deb` | 5-8分 | 55MB | 23-28MB |
| Linux `.snap` | 15-25分 | 70MB | 30-35MB |

---

## 🚀 自動化: CI/CDパイプライン

### GitHub Actions での自動ビルド

```yaml
name: Build Installers

on:
  push:
    tags:
      - 'v*'

jobs:
  build-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build windows --release
      - run: iscc installer\windows_installer.iss
      - uses: actions/upload-artifact@v3
        with:
          name: windows-installer
          path: installer/output/*.exe

  build-macos:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: brew install create-dmg
      - run: flutter build macos --release
      - run: cd installer/macos && ./create_dmg.sh
      - uses: actions/upload-artifact@v3
        with:
          name: macos-installer
          path: installer/macos/output/*.dmg

  build-linux:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: |
          sudo apt-get update
          sudo apt-get install -y cmake ninja-build libgtk-3-dev
      - run: flutter build linux --release
      - run: cd installer/linux && ./create_appimage.sh
      - run: cd installer/linux && ./create_deb.sh
      - uses: actions/upload-artifact@v3
        with:
          name: linux-installers
          path: |
            installer/linux/output/*.AppImage
            installer/linux/output/*.deb
```

---

## 📦 配布方法

### GitHub Releases

```bash
# すべてのインストーラーをGitHub Releaseにアップロード
gh release create v1.0.0 \
  installer/output/MapAnalyzer_Setup_v1.0.0_x64.exe \
  installer/macos/output/MapAnalyzer_v1.0.0_macOS.dmg \
  installer/linux/output/MapAnalyzer-1.0.0-x86_64.AppImage \
  installer/linux/output/map-analyzer_1.0.0_amd64.deb \
  --title "Map Analyzer v1.0.0 - All Platforms" \
  --notes "Multi-platform release with Windows, macOS, and Linux installers"
```

### プラットフォーム別ストア

| ストア | 形式 | 配布方法 |
|--------|------|---------|
| Microsoft Store | `.msix` | Windows Dev Center |
| Mac App Store | `.app` (署名済み) | App Store Connect |
| Snap Store | `.snap` | snapcraft upload |
| Flathub | `.flatpak` | Flathub GitHub repo |

---

## ✅ チェックリスト

### ビルド前
- [ ] Flutter SDK 3.35.4+ インストール済み
- [ ] 各プラットフォームのビルドツールインストール済み
- [ ] `flutter doctor` でエラーなし
- [ ] プロジェクトの依存関係が最新

### ビルド中
- [ ] Windows: Inno Setup でコンパイル成功
- [ ] macOS: DMG作成成功
- [ ] Linux: AppImage/DEB作成成功

### テスト
- [ ] 各インストーラーが正常に動作
- [ ] アプリが起動し、基本機能が動作
- [ ] アンインストールが正常に完了

### 配布
- [ ] インストーラーファイル名にバージョン番号
- [ ] ファイルサイズが想定範囲内
- [ ] ウイルススキャン完了
- [ ] GitHub Releases または各ストアにアップロード

---

## 📚 関連ドキュメント

- **Windows:** [BUILD_INSTALLER.md](BUILD_INSTALLER.md), [WINDOWS_INSTALLER_QUICK_START.md](WINDOWS_INSTALLER_QUICK_START.md)
- **macOS:** [macos/create_dmg.sh](macos/create_dmg.sh) (スクリプト内コメント参照)
- **Linux:** [linux/create_appimage.sh](linux/create_appimage.sh), [linux/create_deb.sh](linux/create_deb.sh)
- **全般:** [DESKTOP_BUILD_GUIDE.md](../DESKTOP_BUILD_GUIDE.md)

---

**Map Analyzer v1.0.0**
© 2025 MapAnalyzer Project

すべてのプラットフォームでMap Analyzerをお楽しみください!
