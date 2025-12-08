# 🗺️ Map Analyzer

**Mapillary API統合 × Gemini AI分析 × GISデータエクスポート**

[![Flutter](https://img.shields.io/badge/Flutter-3.35.4-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Map Analyzerは、Mapillary APIから大量のストリートビュー画像メタデータを収集し、Gemini AIで分析、GIS用データとしてエクスポートできるクロスプラットフォームアプリケーションです。

---

## ✨ 主な機能

### 🔍 Mapillary画像検索
- **3つの検索方式**:
  - 地点+半径検索 (Point + Radius)
  - 矩形範囲検索 (Bounding Box)
  - 任意ポリゴン検索 (Custom Polygon)
- **大量データ対応**: 最大200,000枚の画像メタデータ収集
- **効率的な取得**: 画像本体をダウンロードせず、メタデータのみ取得

### 🤖 Gemini AI分析
- 任意のプロンプトで画像を分析
- クイックプロンプト機能搭載
- バッチ処理対応

### 📊 完全なEXIF/メタデータ対応
- **位置情報**: 緯度・経度・高度
- **撮影情報**: 日時・方位角
- **カメラ情報**: メーカー・モデル
- **Mapillary情報**: シーケンスID・撮影者

### 💾 データエクスポート
- **JSON形式**: GIS解析に最適
- **Excel形式**: スプレッドシート分析用
- **CSV形式**: 汎用データ形式

### 🎯 無料/有料モード
- **無料モード**: 100枚/検索
- **有料モード**: 200,000枚/検索

---

## 🚀 クイックスタート

### 💻 Windowsインストーラー (推奨)
**🎯 最も簡単な方法**: ワンクリックインストール!

1. **[Releases](https://github.com/geomatsuyama/Maptag/releases)** から最新の `MapAnalyzer_Setup_v1.0.0_x64.exe` をダウンロード
2. インストーラーを実行 (管理者権限が必要)
3. セットアップウィザードに従ってインストール
4. スタートメニューから Map Analyzer を起動

**システム要件**:
- Windows 10 (1809以上) または Windows 11
- 64-bit (x64) アーキテクチャ
- RAM: 8GB以上推奨
- ディスク: 500MB以上の空き容量
- Visual C++ Redistributable 2015-2022 (自動チェック)

**特徴**:
- ✅ ワンクリックインストール
- ✅ 日本語/英語対応
- ✅ スタートメニュー登録
- ✅ デスクトップショートカット
- ✅ 簡単アンインストール
- ✅ Visual C++ Redistributable チェック機能
- ✅ レジストリ登録とファイル関連付け

**📚 インストーラー関連ドキュメント**:
- 📖 **[WINDOWS_INSTALLER_QUICK_START.md](installer/WINDOWS_INSTALLER_QUICK_START.md)** - 5分で完了!クイックガイド
- 📖 **[BUILD_INSTALLER.md](installer/BUILD_INSTALLER.md)** - インストーラーのビルド方法 (開発者向け)
- 📖 **[INSTALLER_FAQ.md](installer/INSTALLER_FAQ.md)** - よくある質問と回答
- 📖 **[推奨スペック.md](推奨スペック.md)** - システム要件とパフォーマンスガイド

### 🍎 macOSインストーラー
**🎯 DMG形式で簡単インストール!**

1. **[Releases](https://github.com/geomatsuyama/Maptag/releases)** から最新の `MapAnalyzer_v1.0.0_macOS.dmg` をダウンロード
2. DMGファイルをダブルクリックしてマウント
3. `Map Analyzer.app` を `Applications` フォルダにドラッグ
4. DMGをイジェクト
5. Launchpadから起動

**システム要件**:
- macOS 12 (Monterey) 以上
- Apple Silicon (M1/M2/M3) または Intel プロセッサ
- RAM: 8GB以上推奨
- ディスク: 500MB以上の空き容量

**特徴**:
- ✅ ドラッグ&ドロップでインストール
- ✅ macOS標準の配布形式
- ✅ 管理者権限不要
- ✅ ネイティブmacOSアプリ

**📚 ドキュメント**:
- 📖 **[installer/macos/create_dmg.sh](installer/macos/create_dmg.sh)** - DMG作成スクリプト (開発者向け)

### 🐧 Linuxインストーラー (3形式)
**🎯 お好みの形式を選択!**

#### AppImage (推奨・最も簡単)
1. **[Releases](https://github.com/geomatsuyama/Maptag/releases)** から `MapAnalyzer-1.0.0-x86_64.AppImage` をダウンロード
2. 実行権限を付与: `chmod +x MapAnalyzer-1.0.0-x86_64.AppImage`
3. 実行: `./MapAnalyzer-1.0.0-x86_64.AppImage`

**特徴**:
- ✅ インストール不要
- ✅ すべてのLinuxディストリビューションで動作
- ✅ 管理者権限不要
- ✅ ポータブル実行

#### Debian Package (.deb)
```bash
# Ubuntu/Debianでインストール
sudo dpkg -i map-analyzer_1.0.0_amd64.deb
sudo apt-get install -f

# 起動
map-analyzer
```

**特徴**:
- ✅ システム統合 (アプリメニュー登録)
- ✅ 依存関係の自動解決
- ✅ `apt`で管理可能

#### Snap Package
```bash
sudo snap install map-analyzer_1.0.0_amd64.snap --dangerous
```

**特徴**:
- ✅ 自動更新
- ✅ サンドボックスセキュリティ
- ✅ Ubuntu App Store対応

**システム要件 (共通)**:
- Ubuntu 20.04+ / Debian 11+ / Fedora 35+ / その他Linux
- RAM: 8GB以上推奨
- ディスク: 500MB以上の空き容量

**📚 ドキュメント**:
- 📖 **[installer/linux/create_appimage.sh](installer/linux/create_appimage.sh)** - AppImage作成スクリプト
- 📖 **[installer/linux/create_deb.sh](installer/linux/create_deb.sh)** - DEB作成スクリプト
- 📖 **[installer/linux/create_snap.yaml](installer/linux/create_snap.yaml)** - Snap設定ファイル

### 📚 全プラットフォーム対応ガイド
- 📖 **[installer/BUILD_ALL_PLATFORMS.md](installer/BUILD_ALL_PLATFORMS.md)** - 全プラットフォーム向けビルドガイド (英語)
- 📖 **[installer/全プラットフォーム_インストーラー作成ガイド.md](installer/全プラットフォーム_インストーラー作成ガイド.md)** - 完全日本語ガイド

### 🌐 Webバージョン
**今すぐアクセス**: https://5060-i6w1gve4ssf8ly2hkqauq-02b9cc79.sandbox.novita.ai

1. 設定でAPIキーを入力
2. Mapillaryタブで検索実行
3. 結果をエクスポート

---

## 📋 必要なAPIキー

### Mapillary API
- **取得先**: https://www.mapillary.com/developer
- **用途**: ストリートビュー画像メタデータの検索・取得

### Gemini API
- **取得先**: https://makersuite.google.com/app/apikey
- **用途**: AI画像分析

---

## 🛠️ 技術スタック

### フレームワーク
- **Flutter 3.35.4** - UIフレームワーク
- **Dart 3.9.2** - プログラミング言語

### 状態管理
- **Provider 6.1.5+1** - アプリ全体の状態管理

### ネットワーク
- **http 1.5.0** - REST API通信

### ローカルストレージ
- **shared_preferences 2.5.3** - 設定・APIキー保存
- **hive 2.2.3** + **hive_flutter 1.1.0** - ローカルデータベース

### データエクスポート
- **excel 4.0.3** - Excel形式出力
- **exif 3.3.0** - EXIF処理

### その他
- **file_picker 6.1.1** - ファイル選択
- **geolocator 10.1.0** - 位置情報
- **path_provider 2.1.1** - ファイルパス管理

---

## 📱 対応プラットフォーム

| プラットフォーム | 状態 | 配布方法 | インストーラー | サイズ |
|-----------------|------|----------|---------------|--------|
| 🌐 Web | ✅ 動作中 | ブラウザで即座にアクセス | 不要 | - |
| 🪟 Windows | ✅ インストーラー提供 | [Releases](https://github.com/geomatsuyama/Maptag/releases) | `.exe` (Inno Setup) | 25-30MB |
| 🍎 macOS | ✅ インストーラー提供 | [Releases](https://github.com/geomatsuyama/Maptag/releases) | `.dmg` (DMG) | 20-25MB |
| 🐧 Linux | ✅ インストーラー提供 (3形式) | [Releases](https://github.com/geomatsuyama/Maptag/releases) | `.AppImage` / `.deb` / `.snap` | 23-35MB |
| 📱 Android | 🔜 予定 | - | - | - |
| 🍏 iOS | 🔜 予定 | - | - | - |

---

## 📁 プロジェクト構造

```
lib/
├── main.dart                    # エントリーポイント
├── models/                      # データモデル
│   ├── mapillary_image.dart     # 画像データ(EXIF含む)
│   ├── search_area.dart         # 検索エリア定義
│   └── app_settings.dart        # アプリ設定
├── services/                    # ビジネスロジック
│   ├── mapillary_service.dart   # Mapillary API統合
│   ├── gemini_service.dart      # Gemini AI統合
│   └── export_service.dart      # データエクスポート
├── providers/                   # 状態管理
│   └── settings_provider.dart   # 設定プロバイダー
└── screens/                     # UI画面
    ├── home_screen.dart         # ホーム
    ├── mapillary_search_screen.dart  # 検索
    ├── analysis_screen.dart     # AI分析
    ├── data_export_screen.dart  # エクスポート
    └── settings_screen.dart     # 設定
```

---

## 💡 使用例

### 1. 東京タワー周辺の画像検索
```dart
// 地点+半径検索
SearchArea.pointRadius(
  latitude: 35.6586,
  longitude: 139.7454,
  radiusMeters: 1000,
)
```

### 2. 矩形範囲で大量データ収集
```dart
// 渋谷エリア全体
SearchArea.boundingBox(
  minLongitude: 139.69,
  minLatitude: 35.65,
  maxLongitude: 139.71,
  maxLatitude: 35.67,
)
```

### 3. エクスポートデータの利用
```python
# QGIS/Python での読み込み例
import geopandas as gpd
import json

# JSONデータ読み込み
with open('mapillary_export.json') as f:
    data = json.load(f)

# GeoDataFrameに変換
gdf = gpd.GeoDataFrame(
    data,
    geometry=gpd.points_from_xy(
        [d['longitude'] for d in data],
        [d['latitude'] for d in data]
    ),
    crs='EPSG:4326'
)

# GISで可視化・解析
gdf.plot()
```

---

## 🎯 ユースケース

### 都市計画
- 道路インフラの状況把握
- 交通標識の配置分析
- 街路樹の分布調査

### 防災
- 避難経路の安全性評価
- 危険箇所の特定
- 被害状況のモニタリング

### 研究
- 都市景観の変化追跡
- 建物の外観分析
- 土地利用パターンの研究

### マーケティング
- 店舗の視認性分析
- 広告看板の設置最適化
- 競合店舗の位置分析

---

## 🔧 開発セットアップ

### 前提条件
- Flutter SDK 3.35.4
- Dart 3.9.2

### インストール
```bash
# リポジトリクローン
git clone <repository-url>
cd flutter_app

# 依存関係インストール
flutter pub get

# Web版起動
flutter run -d chrome

# デスクトップ版起動
flutter run -d windows  # Windows
flutter run -d macos    # Mac
flutter run -d linux    # Linux
```

---

## 📊 パフォーマンス

### 処理速度
- **検索速度**: 1,000枚/分 (Mapillary API制限による)
- **エクスポート速度**: 10,000レコード/秒 (JSON)、5,000レコード/秒 (Excel)

### メモリ使用量
- **軽量**: 画像本体をメモリに保持しない
- **効率的**: ストリーミング処理でメタデータのみ取得

---

## 🤝 コントリビューション

プルリクエストを歓迎します!以下の手順でコントリビュートしてください:

1. このリポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

---

## 📄 ライセンス

このプロジェクトはMITライセンスの下でライセンスされています。詳細は [LICENSE](LICENSE) ファイルを参照してください。

---

## 🙏 謝辞

- [Mapillary](https://www.mapillary.com/) - ストリートビュー画像API提供
- [Google Gemini](https://deepmind.google/technologies/gemini/) - AI分析API提供
- [Flutter](https://flutter.dev/) - クロスプラットフォームフレームワーク

---

## 📞 サポート

問題や質問がある場合:
- **Issue**: GitHubのIssueを作成
- **Email**: support@example.com
- **Documentation**: [Wiki](../../wiki)

---

## 🗺️ ロードマップ

- [x] ✅ **Windowsインストーラー対応** (v1.0.0)
- [x] ✅ **macOSインストーラー対応 (DMG)** (v1.0.0)
- [x] ✅ **Linuxインストーラー対応 (AppImage/DEB/Snap)** (v1.0.0)
- [x] ✅ **地図上での検索エリア指定** (v1.0.0)
- [x] ✅ **AI分析サンプルプレビュー** (v1.0.0)
- [ ] Android/iOSモバイルアプリ版
- [ ] リアルタイムデータ同期
- [ ] チーム共有機能
- [ ] クラウドストレージ統合
- [ ] カスタム分析テンプレート
- [ ] 自動レポート生成

---

## 📦 インストーラービルド (開発者向け)

### 🪟 Windows インストーラー

**必要なツール:**
- Flutter SDK 3.35.4+
- Visual Studio 2022 (C++ desktop development)
- Inno Setup 6 (無料): https://jrsoftware.org/isdl.php

**ビルド手順:**
```powershell
git clone https://github.com/geomatsuyama/Maptag.git
cd Maptag
flutter pub get
flutter build windows --release

# GUI: Inno Setup Compiler → installer/windows_installer.iss → Compile (F9)
# CLI:
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" "installer\windows_installer.iss"
```

**出力**: `installer/output/MapAnalyzer_Setup_v1.0.0_x64.exe` (25-30MB)

---

### 🍎 macOS DMGインストーラー

**必要なツール:**
- Flutter SDK 3.35.4+
- Xcode 14+
- Homebrew + `create-dmg`

**ビルド手順:**
```bash
brew install create-dmg
git clone https://github.com/geomatsuyama/Maptag.git
cd Maptag
flutter pub get
flutter build macos --release
cd installer/macos
./create_dmg.sh
```

**出力**: `installer/macos/output/MapAnalyzer_v1.0.0_macOS.dmg` (20-25MB)

---

### 🐧 Linux インストーラー (3形式)

**必要なツール:**
- Flutter SDK 3.35.4+
- CMake, Ninja, GTK3開発ライブラリ

```bash
sudo apt-get install cmake ninja-build libgtk-3-dev
```

**ビルド手順:**

**AppImage:**
```bash
git clone https://github.com/geomatsuyama/Maptag.git
cd Maptag
flutter pub get
flutter build linux --release
cd installer/linux
./create_appimage.sh
```
**出力**: `installer/linux/output/MapAnalyzer-1.0.0-x86_64.AppImage` (23-28MB)

**Debian Package:**
```bash
cd installer/linux
./create_deb.sh
```
**出力**: `installer/linux/output/map-analyzer_1.0.0_amd64.deb` (23-28MB)

**Snap Package:**
```bash
snapcraft
```
**出力**: `map-analyzer_1.0.0_amd64.snap` (30-35MB)

---

### 📚 詳細ドキュメント

**Windows:**
- 📖 [BUILD_INSTALLER.md](installer/BUILD_INSTALLER.md) - 完全ビルドガイド (自動化、トラブルシューティング)
- 📖 [WINDOWS_INSTALLER_QUICK_START.md](installer/WINDOWS_INSTALLER_QUICK_START.md) - 5分で完了!最短手順
- 📖 [INSTALLER_FAQ.md](installer/INSTALLER_FAQ.md) - よくある質問28選
- 📖 [インストーラー作成手順_日本語.md](installer/インストーラー作成手順_日本語.md) - 日本語完全ガイド

**全プラットフォーム:**
- 📖 [BUILD_ALL_PLATFORMS.md](installer/BUILD_ALL_PLATFORMS.md) - 全プラットフォームビルドガイド (英語)
- 📖 [全プラットフォーム_インストーラー作成ガイド.md](installer/全プラットフォーム_インストーラー作成ガイド.md) - 日本語完全ガイド

---

**Map Analyzer** - Powered by Mapillary & Gemini AI  
Version 1.0.0 | © 2025
