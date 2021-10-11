unit SysIconU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ShellAPI, ImgList;

type
  TForm1 = class(TForm)
    chkActive: TCheckBox;
    ImageList: TImageList;
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure chkActiveClick(Sender: TObject);
  private
    Bmp: TBitmap;
    Icon: TIcon;
    TextWidth,
    DrawOffset: Integer;
    procedure ScrollText;
    procedure ImgListToSysTray(Operation: DWord);
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

{$ifdef DelphiLessThan3}
function Win32Check(RetVal: Bool): Bool;
begin
  if not RetVal then
    raise Exception.Create(SysErrorMessage(GetLastError));
  Result := RetVal;
end;
{$endif}

const
  ScrollingText = 'The Delphi Clinic, only in The Delphi Magazine.';

procedure TForm1.ScrollText;
begin
  //Refill bitmap with white
  Bmp.Canvas.FillRect(Rect(0, 0, Bmp.Width, Bmp.Height));
  //Draw text from starting offset
  Bmp.Canvas.TextOut(DrawOffset, 0, ScrollingText);
  //Move offset leftwards
  Dec(DrawOffset, 2);
  if DrawOffset <= -Textwidth then
    //If at end of text, reset offset
    DrawOffSet := Bmp.Width;
  ImgListToSysTray(NIM_MODIFY);
end;

procedure TForm1.ImgListToSysTray(Operation: DWord);
const
  ClinicID = 100;
var
  BmpIndex: Integer;
  NID: TNotifyIconData;
begin
  //Clear image list and add bitmap, with background made transparent
  ImageList.Clear;
  BmpIndex := ImageList.AddMasked(Bmp, Bmp.Canvas.Brush.Color);
  ImageList.GetIcon(BmpIndex, Icon);

  //Setup TNotifyIconData record
  FillChar(NID, SizeOf(NID), 0); //Clear record
  NID.cbSize := SizeOf(NID); //Set byte count field
  NID.Wnd := Handle; //Set owner
  NID.uID := ClinicID; //Set icon ID
  NID.uFlags := NIF_ICON or NIF_TIP; //Identify which other fields are valid
  NID.hICon := Icon.Handle; //set icon handle
  NID.szTip := 'The Delphi Tray Text Scroller'; //Set tooltip

  //Set icon in system tray
  Win32Check(Shell_NotifyIcon(Operation, @NID));
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  //Create icon
  Icon := TIcon.Create;

  //Set up bitmap
  Bmp := TBitmap.Create;
  Bmp.Width := GetSystemMetrics(SM_CXSMICON);
  Bmp.Height := GetSystemMetrics(SM_CYSMICON);
  Bmp.Canvas.Brush.Color := clWindow;
  Bmp.Canvas.Font.Name := 'Verdana';
  Bmp.Canvas.Font.Size := 10;
  Bmp.Canvas.Font.Color := clWindowText;
  TextWidth := Bmp.Canvas.TextWidth(ScrollingText);

  //Start text off at right-hand side of bitmap
  DrawOffSet := Bmp.Width;

  //Set up image list
  ImageList.Width := Bmp.Width;
  ImageList.Height := Bmp.Height;

  ImgListToSysTray(NIM_ADD);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  //Remove icon from system tray and tidy up
  ImgListToSysTray(NIM_DELETE);
  Bmp.Free;
  Icon.Free;
end;

procedure TForm1.TimerTimer(Sender: TObject);
begin
  ScrollText
end;

procedure TForm1.chkActiveClick(Sender: TObject);
begin
  Timer.Enabled := chkActive.Checked
end;

end.
