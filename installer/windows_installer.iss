;===============================================================================
; Map Analyzer - Windows Installer Script (Inno Setup)
; Version: 1.0.0
; Description: Mapillary API & Gemini AI integration app installer
;===============================================================================

#define MyAppName "Map Analyzer"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "MapAnalyzer Project"
#define MyAppURL "https://github.com/geomatsuyama/Maptag"
#define MyAppExeName "map_analyzer.exe"
#define MyAppIcon "icon.ico"

[Setup]
; アプリケーション情報
AppId={{8B5E6F3D-9A2C-4F1E-B8D7-3C4A5F6E7D8C}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
AppUpdatesURL={#MyAppURL}/releases
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=..\LICENSE.txt
InfoBeforeFile=..\installer\README_INSTALLER.txt
OutputDir=..\installer\output
OutputBaseFilename=MapAnalyzer_Setup_v{#MyAppVersion}_x64
SetupIconFile=..\installer\icon.ico
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern

; 権限とシステム要件
PrivilegesRequired=admin
MinVersion=10.0.17763
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

; アンインストール設定
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName}

; ディレクトリとグループ
DisableProgramGroupPage=yes
DisableReadyPage=no
DisableFinishedPage=no

; Visual Studio再頒布可能パッケージチェック
;#expr Exec("powershell", "-Command ""(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64').Version""")

[Languages]
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
japanese.AdditionalInfo=このアプリケーションをインストールするには、以下の条件を満たしている必要があります:%n%n• Windows 10 (1809) 以上%n• Visual C++ Redistributable 2015-2022 (x64)%n• インターネット接続 (Mapillary API & Gemini API使用時)%n%n初回起動時は設定画面でAPIキーを入力してください。
english.AdditionalInfo=To install this application, your system must meet the following requirements:%n%n• Windows 10 (1809) or later%n• Visual C++ Redistributable 2015-2022 (x64)%n• Internet connection (for Mapillary API & Gemini API)%n%nPlease configure API keys in Settings on first launch.

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; メインアプリケーション実行ファイル
Source: "..\build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion

; Flutter ランタイム DLL
Source: "..\build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion

; データディレクトリ (アセット、リソース)
Source: "..\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

; プラグイン (file_picker, url_launcher等)
Source: "..\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion

; ドキュメントとライセンス
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion isreadme
Source: "..\LICENSE.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\推奨スペック.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\DESKTOP_BUILD_GUIDE.md"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
; スタートメニュー
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{group}\使い方ガイド"; Filename: "{app}\README.md"
Name: "{group}\推奨スペック"; Filename: "{app}\推奨スペック.md"

; デスクトップアイコン
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

; クイック起動アイコン
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Registry]
; ファイル関連付け (.json, .xlsx エクスポートファイル)
Root: HKCR; Subkey: ".mapanalyzer"; ValueType: string; ValueName: ""; ValueData: "MapAnalyzer.Document"; Flags: uninsdeletevalue
Root: HKCR; Subkey: "MapAnalyzer.Document"; ValueType: string; ValueName: ""; ValueData: "Map Analyzer Data"; Flags: uninsdeletekey
Root: HKCR; Subkey: "MapAnalyzer.Document\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName},0"
Root: HKCR; Subkey: "MapAnalyzer.Document\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""

; アプリケーション設定パス
Root: HKCU; Subkey: "Software\MapAnalyzer"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\MapAnalyzer"; ValueType: string; ValueName: "Version"; ValueData: "{#MyAppVersion}"

[Run]
; インストール完了後にアプリを起動
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

; README を開く (オプション)
Filename: "{app}\README.md"; Description: "使い方ガイドを開く"; Flags: postinstall shellexec skipifsilent unchecked

[UninstallDelete]
; アンインストール時にユーザー設定ファイルを削除
Type: filesandordirs; Name: "{localappdata}\map_analyzer"
Type: filesandordirs; Name: "{userappdata}\map_analyzer"

[Code]
// Visual C++ Redistributableチェック関数
function VCRedistNeedsInstall: Boolean;
var
  Version: String;
begin
  // VC++ 2015-2022 Redistributable (x64) が既にインストールされているか確認
  Result := not RegQueryStringValue(HKLM64, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Version', Version);
end;

// インストール前の準備処理
function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  Result := '';
  
  // VC++ Redistributableチェック
  if VCRedistNeedsInstall then
  begin
    if MsgBox('このアプリケーションには Visual C++ Redistributable 2015-2022 (x64) が必要です。' + #13#10 + 
              'インストールされていない場合、アプリが正常に動作しない可能性があります。' + #13#10#13#10 + 
              'Microsoft公式サイトからダウンロードしてインストールしてください。' + #13#10 + 
              'https://aka.ms/vs/17/release/vc_redist.x64.exe' + #13#10#13#10 + 
              'それでもインストールを続行しますか?',
              mbConfirmation, MB_YESNO) = IDNO then
    begin
      Result := 'Visual C++ Redistributableが必要です。';
    end;
  end;
end;

// インストール完了後のメッセージ
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // 初回起動時の設定案内
    MsgBox('Map Analyzerのインストールが完了しました!' + #13#10#13#10 + 
           '初回起動時に以下の設定を行ってください:' + #13#10 + 
           '1. 設定画面でMapillary APIキーを入力' + #13#10 + 
           '2. 設定画面でGemini APIキーを入力' + #13#10 + 
           '3. 無料モード/有料モードを選択' + #13#10#13#10 + 
           'APIキーの取得方法はREADME.mdを参照してください。', 
           mbInformation, MB_OK);
  end;
end;

// アンインストール前の確認
function InitializeUninstall(): Boolean;
begin
  Result := True;
  if MsgBox('Map Analyzerをアンインストールします。' + #13#10 + 
            'ユーザー設定とキャッシュファイルも削除されます。' + #13#10#13#10 + 
            'よろしいですか?',
            mbConfirmation, MB_YESNO) = IDNO then
  begin
    Result := False;
  end;
end;
