unit uOisc1Subleq;

interface

uses
  Windows, StdCtrls, Buttons, Controls, Classes, Messages, Forms;

const
  WM_MYMEMO_ENTER = WM_USER + 500;

type
  TFrmOISCSubleq = class(TForm)
    Display: TMemo;
    btnStart: TBitBtn;
    lblHalt: TLabel;
    btnClear: TBitBtn;
    btnStop: TBitBtn;
    LblRunning: TLabel;
    procedure btnStartClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure DisplayKeyPress(Sender: TObject; var Key: Char);
    procedure DisplayEnter(Sender: TObject);
    procedure DisplayExit(Sender: TObject);
    procedure DisplayChange(Sender: TObject);
  private
  public
    procedure WMMYMEMOENTER(var Message: TMessage); message WM_MYMEMO_ENTER;
  end;

var
  FrmOISCSubleq: TFrmOISCSubleq;

implementation

{$R *.dfm}

uses
  SysUtils, StrUtils;

const
  {
  // OSIC self-interpreter
  Progr: array[0..(*152*) 206] of Integer = (
     15, 15, 3,
     148, 147, 6,
     147, 15, 9,
     147, 147, 12,
     117, 117, 15,
     0, 147, 18,
     147, 117, 21,
     147, 147, 24,
     152, 117, 27,
     151, 148, 30,
     45, 45, 33,
     148, 147, 36,
     147, 45, 39,
     147, 147, 42,
     118, 118, 45,
     0, 147, 48,
     147, 118, 51,
     147, 147, 54,
     15, 15, 57,
     150, 147, 60,
     147, 15, 63,
     147, 147, 66,
     45, 45, 69,
     118, 147, 72,
     147, 45, 75,
     147, 147, 78,
     150, 45, 84,
     147, 147, 87,
     118, 15, 90,
     152, 118, 90,
     151, 148, 93,
     108, 108, 96,
     148, 147, 99,
     147, 108, 102,
     147, 147, 105,
     149, 149, 108,
     0, 147, 111,
     147, 149, 114,
     147, 147, 117,
     0, 0, 126,
     151, 148, 123,
     147, 147, 0,
     148, 148, 129,
     149, 147, 132,
     147, 148, 135,
     147, 147, 138,
     151, 149, -1,
     152, 148, 144,
     147, 147, 0,
     0, 153, 0, -1, -1, -153,
  //);
  }

  {
  Progr: array[0..53] of Integer = (
     12, 12, 3,
     36, 37, 6,
     37, 12, 9,
     37, 37, 12,
     0, -1, 15,
     38, 36, 18,
     12, 12, 21,
     53, 37, 24,
     37, 12, 27,
     37, 37, 30,
     36, 12, -1,
     37, 37, 0,
     39, 0, -1,
     72, 101, 108,
     108, 111, 44,
     32, 87, 111,
     114, 108, 100,
     33, 10, 53
  );
  }

  //{
  Progr: array[0..33] of Integer = (
    { 0}-1, 31, 3,
    { 3}32, 32, 6,
    { 6}33, 32, 9,
    { 9}31, 32, 12,
    {12}32, 30, 18,
    {15}30, 30, 24,
    {18}30, 30, 21,
    {21}30, 32, -1,
    {24}31, -1, 27,
    {27}30, 30, 0,
    {30}0,
    {31}0,
    {32}0,
    {33}-27
    );
  //}

var
  Mem: array of Integer;
  BufKey: array[0..100] of Char;
  ABufKey: array[0..100] of Byte absolute BufKey;
  PosBuf: Integer = -1;
  ReadingKey: Boolean = False;

procedure TFrmOISCSubleq.btnClearClick(Sender: TObject);
begin
  Display.Lines.Clear;
end;

procedure TFrmOISCSubleq.btnStartClick(Sender: TObject);
var
  i: Longword;
  p: Integer;
  A, B, C: Integer;
  Ax: LongWord absolute A;
  Bx: LongWord absolute B;
  Cx: LongWord absolute C;
begin
  btnStart.Enabled := False;
  btnClear.Enabled := False;
  lblHalt.Visible := False;
  LblRunning.Visible := True;
  Display.Lines.Clear;
  btnStop.Enabled := True;

  try
    Application.ProcessMessages;

    SetLength(Mem, Length(Progr));

    for i := 0 to Length(Progr) - 1 do
      Mem[i] := Progr[i];

    i := 0;

    Display.SetFocus;

    while True do
    begin
      Application.ProcessMessages;

      if lblHalt.Visible then
        Exit;

      A := Mem[i];
      B := Mem[i + 1];
      C := Mem[i + 2];

      if Ax = $FFFFFFFF then // Mem[Bx] = KeyPressed
      begin
        while not lblHalt.Visible and (PosBuf = -1) do
          Application.ProcessMessages;

        if lblHalt.Visible then
          Exit;

        ReadingKey := True;

        try
          if PosBuf = -1 then
            Mem[Bx] := 0
          else
          begin
            Mem[Bx] := ABufKey[0];

            for p := 1 to PosBuf do
              BufKey[p - 1] := BufKey[p];

            ABufKey[PosBuf] := 0;
            Dec(PosBuf);
          end;
        finally
          ReadingKey := False;
        end;
      end
      else if Bx = $FFFFFFFF then // Display Mem[Ax]
      begin
        if Mem[Ax] = 10 then
          Display.Lines.Text := Display.Lines.Text + #13#10
        else if Mem[Ax] = 8 then
        begin
          if Length(Display.Lines.Text) = 0 then
            MessageBeep(MB_ICONASTERISK)
          else if RightStr(Display.Lines.Text, 1) = #10 then
            Display.Lines.Text := LeftStr(Display.Lines.Text, Length(Display.Lines.Text) - 2)
          else
            Display.Lines.Text := LeftStr(Display.Lines.Text, Length(Display.Lines.Text) - 1);
        end
        else
          Display.Lines.Text := Display.Lines.Text + Chr(Mem[Ax]);

        if Display.Lines.Count > 24 then
          Display.Lines.Delete(0);

        Display.Refresh;
        Display.SelStart := Length(Display.Lines.Text);
      end
      else // Execute instruction
      begin
        Mem[Bx] := Mem[Bx] - Mem[Ax];

        if Mem[Bx] <= 0 then
          if Cx = $FFFFFFFF then // Exec HALT
          begin
            lblHalt.Caption := ' HALT at ' + IntToStr(i) + ' ';
            lblHalt.Visible := True;
            Exit;
          end
          else
          begin
            i := Cx;
            Continue;
          end;
      end;

      Inc(i, 3);
    end;
  finally
    LblRunning.Visible := False;
    btnStop.Enabled := False;
    btnStart.Enabled := True;
    btnClear.Enabled := True;
  end;
end;

procedure TFrmOISCSubleq.btnStopClick(Sender: TObject);
begin
  lblHalt.Visible := True;
  LblRunning.Visible := False;
end;

procedure TFrmOISCSubleq.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if btnStop.Enabled then
  begin
    lblHalt.Visible := True;
    LblRunning.Visible := False;
  end;
end;

procedure TFrmOISCSubleq.FormCreate(Sender: TObject);
begin
  Display.Lines.Clear;
  lblHalt.Transparent := False;
  LblRunning.Transparent := False;
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

end.

