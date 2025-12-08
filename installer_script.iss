; Map Analyzer - Inno Setup インストーラースクリプト
#define MyAppName "Map Analyzer"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Map Analyzer Team"
#define MyAppURL "https://github.com/geomatsuyama/Maptag"
#define MyAppExeName "map_analyzer.exe"

[Setup]
; アプリケーション基本情報
AppId={{8A3F5D2E-1B4C-4F6E-9A2D-7C8E3F1B5A9D}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
; インストーラー出力設定
OutputDir=installer_output
OutputBaseFilename=MapAnalyzer_Setup_v{#MyAppVersion}
Compression=lzma2/max
SolidCompression=yes
; UIカスタマイズ
WizardStyle=modern
SetupIconFile=windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
; 権限とアーキテクチャ
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; ライセンス
LicenseFile=LICENSE

[Languages]
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Map Analyzer実行ファイル一式 (全ファイル再帰的にコピー)
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; ドキュメント
Source: "README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "推奨スペック.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "新機能ガイド.md"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
; スタートメニューショートカット
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\README"; Filename: "{app}\README.md"
Name: "{group}\推奨スペック"; Filename: "{app}\推奨スペック.md"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
; デスクトップショートカット
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
; インストール完了後にアプリを起動
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
// カスタムセットアップメッセージ (日本語)
function InitializeSetup(): Boolean;
begin
  Result := True;
  if (GetWindowsVersion shr 24) < 10 then
  begin
    MsgBox('このアプリケーションにはWindows 10以降が必要です。', mbError, MB_OK);
    Result := False;
  end;
end;
