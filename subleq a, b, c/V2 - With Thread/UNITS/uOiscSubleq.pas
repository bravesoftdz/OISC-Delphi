unit uOiscSubleq;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, uThreadOiscSubleq;

const
  WM_MYMEMO_ENTER = WM_USER + 500;

type
  TFrmOISCSubleq = class(TForm)
    Display: TMemo;
    lblHalt: TLabel;
    lblRunning: TLabel;
    lblPaused: TLabel;
    btnClear: TBitBtn;
    btnStart: TBitBtn;
    btnPause: TBitBtn;
    btnHalt: TBitBtn;
    btnReset: TBitBtn;
    btnLoad: TBitBtn;
    lblError: TLabel;
    procedure btnClearClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnHaltClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure DisplayKeyPress(Sender: TObject; var Key: Char);
    procedure DisplayEnter(Sender: TObject);
    procedure DisplayExit(Sender: TObject);
    procedure DisplayChange(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnPauseClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
  private
    ThreadOisc: TOISCSubleq;
    FPaused: Boolean;
    procedure StartEvent(Sender: TObject);
    procedure HaltEvent(Sender: TObject; Addr: Longword);
    procedure PauseEvent(Sender: TObject; Addr: Longword);
    procedure ResetEvent(Sender: TObject; Addr: Longword);
    procedure ErrorEvent(Sender: TObject; Addr: Longword; Error: Integer);
    procedure Write(Str: string);
    function Read: Char;
  public
    procedure WMMYMEMOENTER(var Message: TMessage); message WM_MYMEMO_ENTER;
  end;

var
  FrmOISCSubleq: TFrmOISCSubleq;

implementation

{$R *.dfm}

uses
  StrUtils;

const
  (*
  // OSIC self-interpreter
  Progr: array[0..152] of Integer = (
    { 0}   15,  15,    3, // if ([15] = [15] - [15]) <= 0 goto 3
    { 3}  148, 147,    6, // if ([147] = [147] - [148]) <= 0 goto 6
    { 6}  147,  15,    9, // if ([15] = [15] - [147]) <= 0 goto 9
    { 9}  147, 147,   12, // if ([147] = [147] - [147]) <= 0 goto 12
    {12}  117, 117,   15, // if ([117] = [117] - [117]) <= 0 goto 15
    {15}    0, 147,   18, // if ([147] = [147] - [0]) <= 0 goto 18
    {18}  147, 117,   21, // if ([117] = [117] - [147]) <= 0 goto 21
    {21}  147, 147,   24, // if ([147] = [147] - [147]) <= 0 goto 24
    {24}  152, 117,   27, // if ([117] = [117] - [152]) <= 0 goto 27
    {27}  151, 148,   30, // if ([148] = [148] - [151]) <= 0 goto 30
    {30}   45,  45,   33, // if ([45] = [45] - [45]) <= 0 goto 33
    {33}  148, 147,   36, // if ([147] = [147] - [148]) <= 0 goto 36
    {36}  147,  45,   39, // if ([45] = [45] - [147]) <= 0 goto 39
    {39}  147, 147,   42, // if ([147] = [147] - [147]) <= 0 goto 42
    {42}  118, 118,   45, // if ([118] = [118] - [118]) <= 0 goto 45
    {45}    0, 147,   48, // if ([147] = [147] - [0]) <= 0 goto 48
    {48}  147, 118,   51, // if ([118] = [118] - [147]) <= 0 goto 51
    {51}  147, 147,   54, // if ([147] = [147] - [147]) <= 0 goto 54
    {54}   15,  15,   57, // if ([15] = [15] - [15]) <= 0 goto 57
    {57}  150, 147,   60, // if ([147] = [147] - [150]) <= 0 goto 60
    {60}  147,  15,   63, // if ([15] = [15] - [147]) <= 0 goto 63
    {63}  147, 147,   66, // if ([147] = [147] - [147]) <= 0 goto 66
    {66}   45,  45,   69, // if ([45] = [45] - [45]) <= 0 goto 69
    {69}  118, 147,   72, // if ([147] = [147] - [118]) <= 0 goto 72
    {72}  147,  45,   75, // if ([45] = [45] - [147]) <= 0 goto 75
    {75}  147, 147,   78, // if ([147] = [147] - [147]) <= 0 goto 78
    {78}  150,  45,   84, // if ([45] = [45] - [150]) <= 0 goto 84
    {81}  147, 147,   87, // if ([147] = [147] - [147]) <= 0 goto 87
    {84}  118,  15,   90, // if ([15] = [15] - [118]) <= 0 goto 90
    {87}  152, 118,   90, // if ([118] = [118] - [152]) <= 0 goto 90
    {90}  151, 148,   93, // if ([148] = [148] - [151]) <= 0 goto 93
    {93}  108, 108,   96, // if ([108] = [108] - [108]) <= 0 goto 96
    {96}  148, 147,   99, // if ([147] = [147] - [148]) <= 0 goto 99
    {99}  147, 108,  102, // if ([108] = [108] - [147]) <= 0 goto 102
   (102}  147, 147,  105, // if ([147] = [147] - [147]) <= 0 goto 105
   (105}  149, 149,  108, // if ([149] = [149] - [149]) <= 0 goto 108
   (108}    0, 147,  111, // if ([147] = [147] - [0]) <= 0 goto 111
   (111}  147, 149,  114, // if ([149] = [149] - [147]) <= 0 goto 114
   (114}  147, 147,  117, // if ([147] = [147] - [147]) <= 0 goto 117
   (117}    0,   0,  126, // if ([0] = [0] - [0]) <= 0 goto 126
   (120}  151, 148,  123, // if ([148] = [148] - [151]) <= 0 goto 123
   (123}  147, 147,    0, // if ([147] = [147] - [147]) <= 0 goto 0
   (126}  148, 148,  129, // if ([148] = [148] - [148]) <= 0 goto 129
   (129}  149, 147,  132, // if ([147] = [147] - [149]) <= 0 goto 132
   (132}  147, 148,  135, // if ([148] = [148] - [147]) <= 0 goto 135
   (135}  147, 147,  138, // if ([147] = [147] - [147]) <= 0 goto 138
   (138}  151, 149,   -1, // if ([149] = [149] - [151]) <= 0 goto -1
   (141}  152, 148,  144, // if ([148] = [148] - [152]) <= 0 goto 144
   (144}  147, 147,    0, // if ([147] = [147] - [147]) <= 0 goto 0
   (147}    0,
   (148)  153,
   (149)    0,
   (150}   -1,
   (151)   -1,
   (152) -153
  );
  *)

  (*
  // HELLO, WORLD!
  Progr: array[0..54] of Integer = (
    { 0}  12,  12,   3, // if {[12] = [12] - [12]) = 0 goto 3  // Limpa [12]
    { 3}  36,  38,   6, // if {[38] = [38] - [36]) = 0 goto 6  // ObtTm positpo do caracter (-[38])
    { 6}  38,  12,   9, // if {[12] = [12] - [38]) = 0 goto 9  // Coloca o caracter em [12]
    { 9}  38,  38,  12, // if {[38] = [38] - [38]) = 0 goto 12 // Limpa [38]
    {12}   0,  -1,  15, // Print [12] ([40] ~ [52])
    {15}  39,  36,  18, // if {[36] = [36] - [39]) = 0 goto 18 // Incrementa [36]
    {18}  12,  12,  21, // if {[12] = [12] - [12]) = 0 goto 21 // Limpa [12]
    {21}  37,  38,  24, // if {[38] = [38] - [37]) = 0 goto 24 // [38] = -[37] = -37
    {24}  38,  12,  27, // if {[12] = [12] - [38]) = 0 goto 27 //
    {27}  38,  38,  30, // if {[38] = [38] - [38]) = 0 goto 30
    {30}  36,  12,  -1, // if ([12] = [12] - [36]) = 0 HALT
    {33}  38,  38,   0, // if {[38] = [38] - [38]) = 0 goto 0
    {36}  40,
    {37}  55,
    {38}   0,
    {39}  -1,
    {40}  12, // CLS
    {41}  72, // H
    {42} 101, // E
    {43} 108, // L
    {44} 108, // L
    {45} 111, // O
    {46}  44, // ,
    {47}  32, //
    {48}  87, // W
    {49} 111, // O
    {50} 114, // R
    {51} 108, // L
    {52} 100, // D
    {53}  33, // !
    {54}  10  // LF
  );
  *)

  //(*
  // Read a key and display it until ESC is pressed.
  Progr: array[0..43] of Integer = (
    { 0} 40, 40,  3, // if ([40] = [40] - [40]) <= 0 goto 3 --> [40] = 0
    { 3} 43, 40,  6, // if ([40] = [40] - [43]) <= 0 goto 3 --> [40] = 0 - (-12) = 12
    { 6} 40, -1,  9, // Print Chr(12) = CLS
    { 9} -1, 40, 12, // [40] = InKey
    {12} 41, 41, 15, // if ([41] = [41] - [41]) <= 0 goto 15 --> [41] = 0
    {15} 42, 41, 18, // if ([41] = [41] - [42]) <= 0 goto 18 --> [41] = 0 - (-27) = 27
    {18} 40, 41, 21, // if ([41] = [41] - [40]) <= 0 goto 21 --> [41] = 27 - Key
    {21} 41, 39, 30, // if ([39] = [39] - [41]) <= 0 goto 27 --> [39] = 0 - (27 - Key) ==> If key < 27, [39] <= 0; jump to 30
    {24} 39, 39, 33, // if ([39] = [39] - [39]) <= 0 goto 33 --> [39] = 0
    {27} 39, 39, 30, // if ([39] = [39] - [39]) <= 0 goto 30 --> [39] = 0
    {30} 39, 41, -1, // if ([41] = [41] - [39]) <= 0 HALT
    {33} 40, -1, 36, // Print [40]
    {36} 39, 39,  9, // if ([39] = [39] - [39]) <= 0 goto 9 --> [39] = 0
    {39}   0,
    {40}   0,   // InKey
    {41}   0,
    {42} -27, // ESC
    {43} -12  // CLS
    );
  //*)

var
  BufKey: array[0..100] of Char;
  ABufKey: array[0..100] of Byte absolute BufKey;
  PosBuf: Integer = -1;
  ReadingKey: Boolean = False;

procedure TFrmOISCSubleq.btnClearClick(Sender: TObject);
begin
  Display.Lines.Clear;
end;

procedure TFrmOISCSubleq.btnHaltClick(Sender: TObject);
begin
  if Assigned(ThreadOisc) then
  begin
    ThreadOisc.ExecHalt;
    ThreadOisc := nil;
  end;
end;

procedure TFrmOISCSubleq.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if btnHalt.Enabled then
    if Assigned(ThreadOisc) then
      ThreadOisc.ExecHalt;
end;

procedure TFrmOISCSubleq.FormCreate(Sender: TObject);
begin
  Display.Lines.Clear;
  lblHalt.Transparent := False;
  lblRunning.Transparent := False;
  lblPaused.Transparent := False;
  lblError.Transparent := False;
  ThreadOisc := nil;
  FPaused := False;
end;

procedure TFrmOISCSubleq.DisplayKeyPress(Sender: TObject; var Key: Char);
{$J+}
const
  process: Boolean = false;
  {$J-}
begin
  while ReadingKey do
    Application.ProcessMessages;

  if not process and not lblHalt.Visible then
  begin
    process := True;

    try
      if PosBuf = 100 then
        MessageBeep(MB_ICONASTERISK)
      else
      begin
        Inc(PosBuf);
        BufKey[PosBuf] := Key;
      end;
    finally
      Key := #0;
      process := False;
    end;
  end;
end;

procedure TFrmOISCSubleq.WMMYMEMOENTER(var Message: TMessage);
begin
  //CreateCaret(Display.Handle, 0, 0, 0);
end;

procedure TFrmOISCSubleq.DisplayEnter(Sender: TObject);
begin
  //PostMessage(Handle, WM_MYMEMO_ENTER, 0, 0);
end;

procedure TFrmOISCSubleq.DisplayExit(Sender: TObject);
begin
  //CreateCaret(Display.Handle, 1, 1, 1);
end;

procedure TFrmOISCSubleq.DisplayChange(Sender: TObject);
begin
  //CreateCaret(Display.Handle, 0, 0, 0);
end;

procedure TFrmOISCSubleq.Write(Str: string);
var
  i: Integer;
begin
  for i := 1 to Length(Str) do
    if str[i] = #10 then
      Display.Lines.Text := Display.Lines.Text + #13#10
    else if str[i] = #12 then
      Display.Lines.Clear
    else if str[i] = #8 then
    begin
      if Length(Display.Lines.Text) = 0 then
        MessageBeep(MB_ICONASTERISK)
      else if RightStr(Display.Lines.Text, 1) = #10 then
        Display.Lines.Text := LeftStr(Display.Lines.Text, Length(Display.Lines.Text) - 2)
      else
        Display.Lines.Text := LeftStr(Display.Lines.Text, Length(Display.Lines.Text) - 1);
    end
    else
      Display.Lines.Text := Display.Lines.Text + str[i];

  if Display.Lines.Count > 24 then
    Display.Lines.Delete(0);

  Display.Refresh;
  Display.SelStart := Length(Display.Lines.Text);
end;

function TFrmOISCSubleq.Read: Char;
var
  i: Integer;
begin
  ReadingKey := True;

  try
    if PosBuf = -1 then
      Result := #0
    else
    begin
      Result := Chr(ABufKey[0]);

      for i := 1 to PosBuf do
        BufKey[i - 1] := BufKey[i];

      ABufKey[PosBuf] := 0;
      Dec(PosBuf);
    end;
  finally
    ReadingKey := False;
  end;
end;

procedure TFrmOISCSubleq.HaltEvent(Sender: TObject; Addr: Longword);
begin
  lblRunning.Visible := False;

  LblHalt.Caption := ' HALTED at ' + IntToStr(Addr) + ' ';
  LblHalt.Visible := True;

  btnHalt.Enabled := False;
  btnPause.Enabled := False;
  btnReset.Enabled := False;
  btnLoad.Enabled := False;
  btnStart.Enabled := True;
  btnClear.Enabled := True;
end;

procedure TFrmOISCSubleq.PauseEvent(Sender: TObject; Addr: Longword);
begin
  lblRunning.Visible := False;
  LblPaused.Caption := ' PAUSED at ' + IntToStr(Addr) + ' ';
  LblPaused.Visible := True;

  btnHalt.Enabled := False;
  btnPause.Enabled := False;
  btnReset.Enabled := False;
  btnLoad.Enabled := False;
  btnStart.Enabled := True;
end;

procedure TFrmOISCSubleq.ResetEvent(Sender: TObject; Addr: Longword);
begin
  LblHalt.Visible := False;
  LblHalt.Refresh;

  LblPaused.Visible := False;
  LblPaused.Refresh;

  lblRunning.Visible := True;
  lblRunning.Refresh;
end;

procedure TFrmOISCSubleq.StartEvent(Sender: TObject);
begin
  LblHalt.Visible := False;
  LblPaused.Visible := False;
  lblError.Visible := False;
  lblRunning.Visible := True;

  btnStart.Enabled := False;
  btnClear.Enabled := False;

  FPaused := False;

  btnHalt.Enabled := True;
  btnPause.Enabled := True;
  btnReset.Enabled := True;
  btnLoad.Enabled := True;
  Display.SetFocus;
end;

procedure TFrmOISCSubleq.btnStartClick(Sender: TObject);
begin
  if Assigned(ThreadOisc) and ThreadOisc.Paused then
    ThreadOisc.ExecRun
  else
  begin
    ThreadOisc := TOISCSubleq.Create(True);
    ThreadOisc.LoadProgr(Progr);
    ThreadOisc.OnHalt := HaltEvent;
    ThreadOisc.OnPause := PauseEvent;
    ThreadOisc.OnReadChar := Read;
    ThreadOisc.OnReset := ResetEvent;
    ThreadOisc.OnError := ErrorEvent;
    ThreadOisc.OnStart := StartEvent;
    ThreadOisc.OnWriteText := Write;
  end;
end;

procedure TFrmOISCSubleq.btnPauseClick(Sender: TObject);
begin
  if Assigned(ThreadOisc) then
  begin
    FPaused := True;
    ThreadOisc.ExecPause;
  end;
end;

procedure TFrmOISCSubleq.btnResetClick(Sender: TObject);
begin
  if Assigned(ThreadOisc) then
  begin
    ThreadOisc.ExecReset;
    Display.SetFocus;
  end;
end;

procedure TFrmOISCSubleq.btnLoadClick(Sender: TObject);
begin
  ThreadOisc.LoadProgr(Progr);
  Display.SetFocus;
end;

procedure TFrmOISCSubleq.ErrorEvent(Sender: TObject; Addr: Longword; Error: Integer);
begin
  lblRunning.Visible := False;
  lblError.Caption := ' ERROR ' + IntToStr(Error) + ' at ' + IntToStr(Addr) + ' ';
  lblError.Visible := True;

  btnHalt.Enabled := False;
  btnPause.Enabled := False;
  btnReset.Enabled := False;
  btnLoad.Enabled := False;
  btnStart.Enabled := True;
  btnClear.Enabled := True;
end;

end.

