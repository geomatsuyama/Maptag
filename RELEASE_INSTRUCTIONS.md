# 📦 Map Analyzer - GitHub Releases作成ガイド

## 🎯 現状

現在、**インストーラーのスクリプトとドキュメントはGitHubにプッシュ済み**ですが、**ビルド済みインストーラーファイル**はまだアップロードされていません。

---

## 📋 必要な作業

### ステップ1: 各プラットフォームでインストーラーをビルド

インストーラーファイルを作成するには、**各OSの実機でビルド**する必要があります:

#### 🪟 Windows (Windowsマシンで実行)
```powershell
# 1. リポジトリをクローン
git clone https://github.com/geomatsuyama/Maptag.git
cd Maptag

# 2. Flutterアプリをビルド
flutter pub get
flutter build windows --release

# 3. Inno Setupでインストーラー作成
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" "installer\windows_installer.iss"

# 出力: installer\output\MapAnalyzer_Setup_v1.0.0_x64.exe
```

#### 🍎 macOS (Macで実行)
```bash
# 1. リポジトリをクローン
git clone https://github.com/geomatsuyama/Maptag.git
cd Maptag

# 2. create-dmgをインストール
brew install create-dmg

# 3. Flutterアプリをビルド
flutter pub get
flutter build macos --release

# 4. DMGインストーラー作成
cd installer/macos
chmod +x create_dmg.sh
./create_dmg.sh

# 出力: installer/macos/output/MapAnalyzer_v1.0.0_macOS.dmg
```

#### 🐧 Linux (Linux PCで実行)
```bash
# 1. リポジトリをクローン
git clone https://github.com/geomatsuyama/Maptag.git
cd Maptag

# 2. 依存関係をインストール
sudo apt-get update
sudo apt-get install -y cmake ninja-build libgtk-3-dev liblzma-dev

# 3. Flutterアプリをビルド
flutter pub get
flutter build linux --release

# 4. AppImageを作成
cd installer/linux
chmod +x create_appimage.sh
./create_appimage.sh

# 5. DEBパッケージを作成
chmod +x create_deb.sh
./create_deb.sh

# 6. Snapパッケージを作成 (オプション)
cd ../..
snapcraft

# 出力:
# - installer/linux/output/MapAnalyzer-1.0.0-x86_64.AppImage
# - installer/linux/output/map-analyzer_1.0.0_amd64.deb
# - map-analyzer_1.0.0_amd64.snap
```

---

### ステップ2: GitHub Releaseを作成

すべてのインストーラーファイルをビルドしたら、GitHub Releasesにアップロードします。

#### 方法A: GitHub Web UI (初心者向け)

1. **GitHubリポジトリを開く**
   - https://github.com/geomatsuyama/Maptag

2. **Releasesページに移動**
   - 右側のサイドバーから「Releases」をクリック

3. **新しいリリースを作成**
   - 「Draft a new release」をクリック

4. **タグを作成**
   - 「Choose a tag」 → 「v1.0.0」を入力 → 「Create new tag: v1.0.0 on publish」

5. **リリース情報を入力**
   ```
   Release title: Map Analyzer v1.0.0 - 全プラットフォーム対応
   
   Description:
   # 🎉 Map Analyzer v1.0.0 - 初回リリース
   
   ## 📦 ダウンロード
   
   以下から自分のOSに合ったインストーラーをダウンロードしてください:
   
   ### 🪟 Windows
   - `MapAnalyzer_Setup_v1.0.0_x64.exe` (25-30MB)
   - Windows 10 (1809以上) / Windows 11
   
   ### 🍎 macOS
   - `MapAnalyzer_v1.0.0_macOS.dmg` (20-25MB)
   - macOS 12 (Monterey) 以上
   
   ### 🐧 Linux
   - `MapAnalyzer-1.0.0-x86_64.AppImage` (23-28MB) - 推奨
   - `map-analyzer_1.0.0_amd64.deb` (23-28MB) - Ubuntu/Debian
   - `map-analyzer_1.0.0_amd64.snap` (30-35MB) - Snap Store
   
   ## ✨ 主な機能
   
   - Mapillary API統合 (地点+半径、矩形、ポリゴン検索)
   - Gemini AI画像分析
   - JSON/Excel/CSVエクスポート
   - 完全なEXIF/メタデータ対応
   - 無料/有料モード (100枚/200,000枚)
   
   ## 📚 ドキュメント
   
   - [ビルド不要_使い方ガイド.md](installer/ビルド不要_使い方ガイド.md) - 初心者向け
   - [README.md](README.md) - プロジェクト概要
   - [推奨スペック.md](推奨スペック.md) - システム要件
   
   ## 🌐 Web版
   
   インストール不要のWeb版もあります:
   https://5060-i6w1gve4ssf8ly2hkqauq-02b9cc79.sandbox.novita.ai
   ```

6. **インストーラーファイルをアップロード**
   - 「Attach binaries by dropping them here or selecting them」エリアに以下をドラッグ:
     - `MapAnalyzer_Setup_v1.0.0_x64.exe`
     - `MapAnalyzer_v1.0.0_macOS.dmg`
     - `MapAnalyzer-1.0.0-x86_64.AppImage`
     - `map-analyzer_1.0.0_amd64.deb`
     - `map-analyzer_1.0.0_amd64.snap` (オプション)

7. **リリースを公開**
   - 「Publish release」をクリック

---

#### 方法B: GitHub CLI (自動化向け)

```bash
# 前提: gh CLI がインストール済み
# https://cli.github.com/

# 1. 認証 (初回のみ)
gh auth login

# 2. リリース作成
gh release create v1.0.0 \
  installer/output/MapAnalyzer_Setup_v1.0.0_x64.exe \
  installer/macos/output/MapAnalyzer_v1.0.0_macOS.dmg \
  installer/linux/output/MapAnalyzer-1.0.0-x86_64.AppImage \
  installer/linux/output/map-analyzer_1.0.0_amd64.deb \
  map-analyzer_1.0.0_amd64.snap \
  --title "Map Analyzer v1.0.0 - 全プラットフォーム対応" \
  --notes "詳細はリリースページをご覧ください" \
  --repo geomatsuyama/Maptag
```

---

## 🚨 重要な注意点

### 1. クロスコンパイルは不可

**各OSのインストーラーは、そのOS上でビルドする必要があります:**
- Windows → Windowsマシン必須
- macOS → Mac必須
- Linux → Linux PC必須

### 2. Flutter SDKが必要

インストーラーをビルドするには、**Flutter SDK 3.35.4以上**が必要です。

### 3. プラットフォーム固有のツール

- **Windows**: Inno Setup 6.x
- **macOS**: create-dmg (Homebrew)
- **Linux**: appimagetool, dpkg, snapcraft

---

## 🔄 代替案: CI/CD自動ビルド

各OSの実機を用意するのが難しい場合、**GitHub Actions**で自動ビルドできます:

### `.github/workflows/release.yml` (例)

```yaml
name: Build and Release

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
        with:
          flutter-version: '3.35.4'
      - run: flutter pub get
      - run: flutter build windows --release
      - run: choco install innosetup -y
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
        with:
          flutter-version: '3.35.4'
      - run: brew install create-dmg
      - run: flutter pub get
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
        with:
          flutter-version: '3.35.4'
      - run: |
          sudo apt-get update
          sudo apt-get install -y cmake ninja-build libgtk-3-dev
      - run: flutter pub get
      - run: flutter build linux --release
      - run: cd installer/linux && ./create_appimage.sh
      - run: cd installer/linux && ./create_deb.sh
      - uses: actions/upload-artifact@v3
        with:
          name: linux-installers
          path: |
            installer/linux/output/*.AppImage
            installer/linux/output/*.deb

  create-release:
    needs: [build-windows, build-macos, build-linux]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v3
      - uses: softprops/action-gh-release@v1
        with:
          files: |
            windows-installer/*
            macos-installer/*
            linux-installers/*
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## 🎯 現時点での状況

### ✅ 完了済み
- リポジトリにすべてのコードをプッシュ
- ビルドスクリプト作成
- ドキュメント完備

### 🔄 次のステップ (あなたがやること)
1. **各OSの実機を用意** (Windows PC、Mac、Linux PC)
2. **各OSでインストーラーをビルド**
3. **GitHub Releasesにアップロード**

### ⚡ 簡単な方法
**GitHub Actions**を使えば、実機不要で自動ビルド可能です!

---

## 💡 推奨ワークフロー

### オプション1: 手動ビルド
1. 友人や同僚に各OSの実機を借りる
2. 各OSでビルド実行
3. ファイルを集めてGitHub Releasesにアップロード

### オプション2: クラウドサービス利用
1. クラウドVM (AWS, Azure, GCP等) を利用
2. 各OSのVMでビルド実行
3. ファイルをダウンロードしてGitHub Releasesにアップロード

### オプション3: GitHub Actions (推奨!)
1. 上記のワークフローファイルを `.github/workflows/release.yml` に作成
2. Gitタグを作成: `git tag v1.0.0 && git push origin v1.0.0`
3. GitHub Actionsが自動でビルド&リリース 🎉

---

## 📞 サポート

質問がある場合:
- GitHub Issues: https://github.com/geomatsuyama/Maptag/issues
- ドキュメント参照

---

## 🎉 まとめ

**現状**: コードとドキュメントはすべて完成!

**次のステップ**: 各OSでビルドしてGitHub Releasesにアップロード

**最も簡単**: GitHub Actionsを使った自動ビルド

---

**Map Analyzer v1.0.0**
© 2025 MapAnalyzer Project

**あと一歩でリリース完了です! 🚀**
