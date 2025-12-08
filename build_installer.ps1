# Map Analyzer - Windowsインストーラー自動ビルドスクリプト
# PowerShell スクリプト

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Map Analyzer - Windowsインストーラービルド" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 1. Flutter環境チェック
Write-Host "[1/5] Flutter環境を確認中..." -ForegroundColor Yellow
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "エラー: Flutterがインストールされていません。" -ForegroundColor Red
    Write-Host "https://docs.flutter.dev/get-started/install/windows からインストールしてください。" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Flutter環境OK" -ForegroundColor Green
flutter --version
Write-Host ""

# 2. 依存関係のインストール
Write-Host "[2/5] 依存関係をインストール中..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "エラー: 依存関係のインストールに失敗しました。" -ForegroundColor Red
    exit 1
}
Write-Host "✓ 依存関係インストール完了" -ForegroundColor Green
Write-Host ""

# 3. Windowsリリースビルド
Write-Host "[3/5] Windowsアプリをビルド中..." -ForegroundColor Yellow
Write-Host "この処理には数分かかる場合があります..." -ForegroundColor Gray
flutter build windows --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "エラー: ビルドに失敗しました。" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Windowsビルド完了" -ForegroundColor Green
Write-Host ""

# 4. ビルドファイルの確認
$exePath = "build\windows\x64\runner\Release\map_analyzer.exe"
if (-not (Test-Path $exePath)) {
    Write-Host "エラー: 実行ファイルが見つかりません: $exePath" -ForegroundColor Red
    exit 1
}
Write-Host "✓ 実行ファイル確認OK: $exePath" -ForegroundColor Green
Write-Host ""

# 5. Inno Setup確認とインストーラービルド
Write-Host "[4/5] Inno Setupを確認中..." -ForegroundColor Yellow
$innoSetupPaths = @(
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles}\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles(x86)}\Inno Setup 5\ISCC.exe",
    "${env:ProgramFiles}\Inno Setup 5\ISCC.exe"
)

$isccPath = $null
foreach ($path in $innoSetupPaths) {
    if (Test-Path $path) {
        $isccPath = $path
        break
    }
}

if ($null -eq $isccPath) {
    Write-Host "警告: Inno Setupが見つかりません。" -ForegroundColor Yellow
    Write-Host "Inno Setupをインストールしてください:" -ForegroundColor Yellow
    Write-Host "https://jrsoftware.org/isdl.php" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "手動でインストーラーを作成する場合:" -ForegroundColor Yellow
    Write-Host "1. Inno Setupをインストール" -ForegroundColor Gray
    Write-Host "2. installer_script.iss をInno Setup Compilerで開く" -ForegroundColor Gray
    Write-Host "3. 'Compile'ボタンをクリック" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Windowsビルドは完了しました!" -ForegroundColor Green
    Write-Host "ビルドファイル: build\windows\x64\runner\Release\" -ForegroundColor Cyan
    exit 0
}

Write-Host "✓ Inno Setup発見: $isccPath" -ForegroundColor Green
Write-Host ""

# 6. インストーラービルド
Write-Host "[5/5] インストーラーをビルド中..." -ForegroundColor Yellow
& $isccPath "installer_script.iss"
if ($LASTEXITCODE -ne 0) {
    Write-Host "エラー: インストーラーのビルドに失敗しました。" -ForegroundColor Red
    exit 1
}
Write-Host "✓ インストーラービルド完了" -ForegroundColor Green
Write-Host ""

# 7. 完了メッセージ
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🎉 ビルド完了!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📦 生成されたファイル:" -ForegroundColor Yellow
Write-Host "  - Windowsアプリ: build\windows\x64\runner\Release\map_analyzer.exe" -ForegroundColor Cyan
$installerPath = "installer_output\MapAnalyzer_Setup_v1.0.0.exe"
if (Test-Path $installerPath) {
    $fileSize = (Get-Item $installerPath).Length / 1MB
    Write-Host "  - インストーラー: $installerPath" -ForegroundColor Cyan
    Write-Host "    サイズ: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Gray
}
Write-Host ""
Write-Host "🚀 次のステップ:" -ForegroundColor Yellow
Write-Host "  1. インストーラーをテストしてください" -ForegroundColor Gray
Write-Host "  2. GitHubのReleasesページにアップロード" -ForegroundColor Gray
Write-Host "  3. ユーザーに配布" -ForegroundColor Gray
Write-Host ""
