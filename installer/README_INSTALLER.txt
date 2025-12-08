========================================
Map Analyzer - インストールガイド
========================================

【重要事項】
このインストーラーは、Map Analyzerアプリケーションをお使いのWindows PCにインストールします。
インストール前に、以下の内容をご確認ください。

【システム要件】
✓ OS: Windows 10 (バージョン 1809) 以上 / Windows 11
✓ アーキテクチャ: 64-bit (x64)
✓ メモリ: 8GB以上推奨 (大量データ処理時は16GB以上推奨)
✓ ストレージ: 500MB以上の空き容量
✓ インターネット接続: 必須 (Mapillary API、Gemini API使用時)
✓ 必須コンポーネント: Visual C++ Redistributable 2015-2022 (x64)

【インストール先】
デフォルトインストール先: C:\Program Files\Map Analyzer\
※カスタムインストール先を指定することもできます

【インストール内容】
以下のファイルとフォルダがインストールされます:
- map_analyzer.exe (メインアプリケーション)
- flutter_windows.dll (Flutter ランタイム)
- data/ (アプリケーションアセット、リソース)
- 各種プラグイン DLL (file_picker, url_launcher等)
- ドキュメント (README.md, 推奨スペック.md等)

【必要な前提ソフトウェア】
Map Analyzerを実行するには、Microsoft Visual C++ Redistributable 2015-2022 (x64)が必要です。
インストールされていない場合は、以下からダウンロードしてインストールしてください:

https://aka.ms/vs/17/release/vc_redist.x64.exe

【初回起動時の設定】
インストール完了後、初回起動時に以下の設定を行う必要があります:

1. Mapillary APIキーの設定
   - Mapillary公式サイトでアカウント登録
   - APIキーを取得: https://www.mapillary.com/developer
   - アプリの設定画面でAPIキーを入力

2. Gemini APIキーの設定
   - Google AI Studioでアカウント登録
   - APIキーを取得: https://makersuite.google.com/app/apikey
   - アプリの設定画面でAPIキーを入力

3. 無料モード/有料モードの選択
   - 無料モード: 1回の検索で最大100枚の画像データ
   - 有料モード: 1回の検索で最大200,000枚の画像データ

【アンインストール】
コントロールパネルの「プログラムと機能」、またはスタートメニューの
「Map Analyzer > Map Analyzerのアンインストール」からアンインストールできます。

アンインストール時、以下のデータも削除されます:
- ユーザー設定ファイル
- キャッシュファイル
- APIキー情報

【サポート】
問題が発生した場合は、GitHubリポジトリをご確認ください:
https://github.com/geomatsuyama/Maptag

【ライセンス】
Map Analyzerのライセンス条項は、次の画面で表示されます。
インストールを続行する前に必ずお読みください。

========================================
© 2025 MapAnalyzer Project
All Rights Reserved
========================================
