unit ClsOISCSubleq;

interface

uses
  Classes, StdCtrls;

type
  TOISCIn = function: Char of object;
  TOISCOut = procedure(str: string) of object;

  TOISCSubleq = class(TThread)
  private
    Addr: Longword;
    FOISCIn: TOISCIn;
    FOISCOut: TOISCOut;
    FLblRunning: TLabel;
    FLblHalt: TLabel;
    FLblPaused: TLabel;
    Mem: array of Integer;
    FIsHalted: Boolean;
    FIsPaused: Boolean;
    FIsReset: Boolean;
    TxtBuff: string;
    ChrBuff: Char;
  protected
    procedure Execute; override;
    procedure ReadChar;
    procedure WriteChar;
    procedure WriteString;
    procedure GoRunning;
    procedure GoHalted;
    procedure GoPaused;
  public
    constructor Create(Progr: array of Integer;
      OISCIn: TOISCIn; OISCOut: TOISCOut;
      LblRunning: TLabel; LblHalt: TLabel; LblPaused: TLabel);
    procedure Pause;
    procedure Run;
    procedure Halt;
    procedure Reset;
  end;

implementation

uses
  SysUtils;
  
{ TOISCSubleq }

constructor TOISCSubleq.Create(Progr: array of Integer;
  OISCIn: TOISCIn; OISCOut: TOISCOut;
  LblRunning: TLabel; LblHalt: TLabel; LblPaused: TLabel);
var
  i: Integer;
begin
  inherited Create(True);

  Priority := tpNormal;
  FreeOnTerminate := False;

  FOISCIn := OISCIn;
  FOISCOut := OISCOut;
  FLblHalt := LblHalt;
  FLblRunning := LblRunning;
  FLblPaused := LblPaused;

  SetLength(Mem, Length(Progr));

  for i := 0 to Length(Progr) - 1 do
    Mem[i] := Progr[i];
end;

procedure TOISCSubleq.Execute;
var
  A, B, C: Integer;
  Ax: LongWord absolute A;
  Bx: LongWord absolute B;
  Cx: LongWord absolute C;
begin
  inherited;

  Synchronize(GoRunning);

  if Length(Mem) = 0 then
    Exit;

  Addr := 0;

  while True do
  begin
    if FIsReset then
      Addr := 0
    else if FIsHalted then
      Exit
    else if FIsPaused then
      Continue;

    A := Mem[Addr];
    B := Mem[Addr + 1];
    C := Mem[Addr + 2];

    if Ax = $FFFFFFFF then // Ler teclado e armazenar em Mem[Bx]
    begin
      if Assigned(FOISCIn) then
      begin
        Synchronize(ReadChar);

        while not FIsHalted and (ChrBuff <> #0) do
          Synchronize(ReadChar);
      end;

      if FIsHalted then
        Exit;

      Mem[Bx] := Ord(ChrBuff);
    end
    else if Bx = $FFFFFFFF then // Exibir conteúdo de Mem[Ax]
    begin
      if (Mem[Ax] = 10) or (Mem[Ax] = 13) then
      begin
        TxtBuff := #13#10;
        Synchronize(WriteString);
      end
      else
      begin
        ChrBuff := Chr(Mem[Ax]);
        Synchronize(WriteChar);
      end;
    end
    else // Executar o processo
    begin
      Mem[Bx] := Mem[Bx] - Mem[Ax];

      if Mem[Bx] <= 0 then
        if Cx = $FFFFFFFF then // Executa HALT
        begin
          Synchronize(GoHalted);
          Exit;
        end
        else
        begin
          Addr := Cx;
          Continue;
        end;
    end;

    Inc(Addr, 3);
  end;
end;

procedure TOISCSubleq.WriteString;
var
  i: Integer;
begin
  if Assigned(FOISCOut) then
  begin
    for i := 1 to Length(TxtBuff) do
      FOISCOut(TxtBuff[i]);

    TxtBuff := '';
  end;
end;

procedure TOISCSubleq.GoHalted;
begin
  FIsHalted := True;
  FIsPaused := False;

  if Assigned(FLblRunning) then
  begin
    FLblRunning.Visible := False;
    FLblRunning.Refresh;
  end;

  if Assigned(FLblPaused) then
  begin
    FLblPaused.Visible := False;
    FLblPaused.Refresh;
  end;

  if Assigned(FLblHalt) then
  begin
    FLblHalt.Caption := ' HALTED at ' + IntToStr(Addr) + ' ';
    FLblHalt.Visible := True;
    FLblHalt.Refresh;
  end;
end;

procedure TOISCSubleq.ReadChar;
begin
  if Assigned(FOISCIn) then
    ChrBuff := FOISCIn()
  else
    ChrBuff := #0;
end;

procedure TOISCSubleq.GoRunning;
begin
  if FIsHalted then
    Exit;

  FIsReset := False;
  FIsHalted := False;
  FIsPaused := False;

  if Assigned(FLblHalt) then
  begin
    FLblHalt.Visible := False;
    FLblHalt.Refresh;
  end;

  if Assigned(FLblPaused) then
  begin
    FLblPaused.Visible := False;
    FLblPaused.Refresh;
  end;

  if Assigned(FLblRunning) then
  begin
    FLblRunning.Visible := True;
    FLblRunning.Refresh;
  end;
end;

procedure TOISCSubleq.WriteChar;
begin
  if Assigned(FOISCOut) then
  begin
    FOISCOut(ChrBuff);
    ChrBuff := #0;
  end;
end;

procedure TOISCSubleq.GoPaused;
begin
  FIsPaused := True;

  if Assigned(FLblRunning) then
  begin
    FLblRunning.Visible := False;
    FLblRunning.Refresh;
  end;

  if Assigned(FLblHalt) then
  begin
    FLblHalt.Visible := False;
    FLblHalt.Refresh;
  end;

  if Assigned(FLblPaused) then
  begin
    FLblPaused.Caption := ' PAUSED at ' + IntToStr(Addr) + ' ';
    FLblPaused.Visible := True;
    FLblPaused.Refresh;
  end;
end;

procedure TOISCSubleq.Halt;
begin
  Synchronize(GoHalted);
end;

procedure TOISCSubleq.Pause;
begin
  if not FIsPaused then
    Synchronize(GoPaused);
end;

procedure TOISCSubleq.Run;
begin
  if FIsPaused then
    Synchronize(GoRunning);
end;

procedure TOISCSubleq.Reset;
begin
  FIsReset := True;
  FIsHalted := False;
  FIsPaused := False;
end;

end.
