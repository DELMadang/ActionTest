unit uMain;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.SysUtils,
  System.Classes,
  System.Actions,
  System.ImageList,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.ActnList,
  Vcl.ToolWin,
  Vcl.ImgList,
  Vcl.Clipbrd;

type
  TfrmMain = class(TForm)
    MainMenu: TMainMenu;
    MenuFile: TMenuItem;
    MenuEdit: TMenuItem;
    MenuHelp: TMenuItem;
    ActionList: TActionList;
    actNew: TAction;
    actOpen: TAction;
    actSave: TAction;
    actSaveAs: TAction;
    actExit: TAction;
    actUndo: TAction;
    actCut: TAction;
    actCopy: TAction;
    actPaste: TAction;
    actSelectAll: TAction;
    actAbout: TAction;
    MenuItemNew: TMenuItem;
    MenuItemOpen: TMenuItem;
    MenuItemSave: TMenuItem;
    MenuItemSaveAs: TMenuItem;
    MenuItemSeparator1: TMenuItem;
    MenuItemExit: TMenuItem;
    MenuItemUndo: TMenuItem;
    MenuItemSeparator2: TMenuItem;
    MenuItemCut: TMenuItem;
    MenuItemCopy: TMenuItem;
    MenuItemPaste: TMenuItem;
    MenuItemSeparator3: TMenuItem;
    MenuItemSelectAll: TMenuItem;
    MenuItemAbout: TMenuItem;
    StatusBar: TStatusBar;
    ToolBar: TToolBar;
    ToolButtonNew: TToolButton;
    ToolButtonOpen: TToolButton;
    ToolButtonSave: TToolButton;
    ToolButtonSeparator1: TToolButton;
    ToolButtonCut: TToolButton;
    ToolButtonCopy: TToolButton;
    ToolButtonPaste: TToolButton;
    MemoMain: TMemo;
    PopupMenu: TPopupMenu;
    PopupMenuUndo: TMenuItem;
    PopupMenuSeparator1: TMenuItem;
    PopupMenuCut: TMenuItem;
    PopupMenuCopy: TMenuItem;
    PopupMenuPaste: TMenuItem;
    PopupMenuSeparator2: TMenuItem;
    PopupMenuSelectAll: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    ImageList: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actNewExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actSaveAsExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actUndoExecute(Sender: TObject);
    procedure actUndoUpdate(Sender: TObject);
    procedure actCutExecute(Sender: TObject);
    procedure actCutUpdate(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actCopyUpdate(Sender: TObject);
    procedure actPasteExecute(Sender: TObject);
    procedure actPasteUpdate(Sender: TObject);
    procedure actSelectAllExecute(Sender: TObject);
    procedure actSelectAllUpdate(Sender: TObject);
    procedure actAboutExecute(Sender: TObject);
    procedure MemoMainChange(Sender: TObject);
  private
    FFileName: string;
    FModified: Boolean;
    function  CheckSave: Boolean;
    procedure SetModified(const Value: Boolean);
    procedure UpdateCaption;
  public
    property Modified: Boolean read FModified write SetModified;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FFileName := '';
  Modified := False;
  UpdateCaption;

  // 파일 다이얼로그 초기 설정
  OpenDialog.Filter := '텍스트 파일(*.txt)|*.txt|모든 파일(*.*)|*.*';
  SaveDialog.Filter := OpenDialog.Filter;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := CheckSave;
end;

function TfrmMain.CheckSave: Boolean;
var
  LResult: Integer;
begin
  Result := True;
  if Modified then
  begin
    LResult := MessageDlg('변경된 내용을 저장하시겠습니까?', mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    case LResult of
      mrYes:
        actSave.Execute;
      mrCancel:
        Result := False;
    end;
  end;
end;

procedure TfrmMain.SetModified(const Value: Boolean);
begin
  FModified := Value;
  UpdateCaption;
end;

procedure TfrmMain.UpdateCaption;
var
  DisplayName: string;
begin
  if FFileName = '' then
    DisplayName := '제목 없음'
  else
    DisplayName := ExtractFileName(FFileName);
    
  if Modified then
    Caption := DisplayName + ' *- 메모장'
  else
    Caption := DisplayName + ' - 메모장';
    
  // 상태바 업데이트
  StatusBar.Panels[0].Text := '문자 수: ' + IntToStr(Length(MemoMain.Text));
end;

procedure TfrmMain.MemoMainChange(Sender: TObject);
begin
  Modified := True;
end;

{ 파일 관련 액션 핸들러 }

procedure TfrmMain.actNewExecute(Sender: TObject);
begin
  if CheckSave then
  begin
    MemoMain.Clear;
    FFileName := '';
    Modified := False;
  end;
end;

procedure TfrmMain.actOpenExecute(Sender: TObject);
begin
  if CheckSave and OpenDialog.Execute then
  begin
    MemoMain.Lines.LoadFromFile(OpenDialog.FileName);
    FFileName := OpenDialog.FileName;
    Modified := False;
  end;
end;

procedure TfrmMain.actSaveExecute(Sender: TObject);
begin
  if FFileName = '' then
    actSaveAs.Execute
  else
  begin
    MemoMain.Lines.SaveToFile(FFileName);
    Modified := False;
  end;
end;

procedure TfrmMain.actSaveAsExecute(Sender: TObject);
begin
  SaveDialog.FileName := FFileName;
  if SaveDialog.Execute then
  begin
    MemoMain.Lines.SaveToFile(SaveDialog.FileName);
    FFileName := SaveDialog.FileName;
    Modified := False;
  end;
end;

procedure TfrmMain.actExitExecute(Sender: TObject);
begin
  Close;
end;

{ 편집 관련 액션 핸들러 }

procedure TfrmMain.actUndoExecute(Sender: TObject);
begin
  MemoMain.Undo;
end;

procedure TfrmMain.actUndoUpdate(Sender: TObject);
begin
  actUndo.Enabled := MemoMain.CanUndo;
end;

procedure TfrmMain.actCutExecute(Sender: TObject);
begin
  MemoMain.CutToClipboard;
end;

procedure TfrmMain.actCutUpdate(Sender: TObject);
begin
  actCut.Enabled := MemoMain.SelLength > 0;
end;

procedure TfrmMain.actCopyExecute(Sender: TObject);
begin
  MemoMain.CopyToClipboard;
end;

procedure TfrmMain.actCopyUpdate(Sender: TObject);
begin
  actCopy.Enabled := MemoMain.SelLength > 0;
end;

procedure TfrmMain.actPasteExecute(Sender: TObject);
begin
  MemoMain.PasteFromClipboard;
end;

procedure TfrmMain.actPasteUpdate(Sender: TObject);
begin
  actPaste.Enabled := Clipboard.HasFormat(CF_TEXT);
end;

procedure TfrmMain.actSelectAllExecute(Sender: TObject);
begin
  MemoMain.SelectAll;
end;

procedure TfrmMain.actSelectAllUpdate(Sender: TObject);
begin
  actSelectAll.Enabled := MemoMain.Text <> '';
end;

procedure TfrmMain.actAboutExecute(Sender: TObject);
begin
  ShowMessage('TAction 예제 메모장 애플리케이션' + #13#10 + '버전 1.0');
end;

end.