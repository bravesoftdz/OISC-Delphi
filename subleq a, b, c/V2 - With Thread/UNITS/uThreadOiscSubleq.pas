unit uThreadOiscSubleq;

interface

uses
  Classes, Windows;

type
  TOISCIn = function: Char of object;
  TOISCOut = procedure(str: string) of object;
  THaltEvent = procedure(Sender: TObject; Addr: Longword) of object;
  TPauseEvent = procedure(Sender: TObject; Addr: Longword) of object;
  TResetEvent = procedure(Sender: TObject; Addr: Longword) of object;
  TErrorEvent = procedure(Sender: TObject; Addr: Longword; Err: Integer) of object;

  TOISCSubleq = class(TThread)
  private
    FAddr: Longword;
    FError: Integer;
    FMemTop: Longword;
    FOISCIn: TOISCIn;
    FOISCOut: TOISCOut;
    FMem: array of Integer;
    FIsRunning: Boolean;
    FIsHalted: Boolean;
    FIsPaused: Boolean;
    FIsReset: Boolean;
    FTxtBuff: string;
    FChrBuff: Char;
    FOnHalt: THaltEvent;
    FOnStart: TNotifyEvent;
    FOnPause: TPauseEvent;
    FOnReset: TResetEvent;
    FOnError: TErrorEvent;
  protected
    procedure Execute; override;
    procedure ReadChar;
    procedure WriteChar;
    procedure WriteString;
    procedure GoRunning;
    procedure GoHalted;
    procedure GoPaused;
    procedure ErrorTrap;
  public
    constructor Create(CreateSuspended: Boolean);
    procedure LoadProgr(Progr: array of Integer);
    procedure ExecPause;
    procedure ExecRun;
    procedure ExecHalt;
    procedure ExecReset;
    function Paused: Boolean;
    property OnStart: TNotifyEvent read FOnStart write FOnStart;
    property OnPause: TPauseEvent read FOnPause write FOnPause;
    property OnHalt: THaltEvent read FOnHalt write FOnHalt;
    property OnReset: TResetEvent read FOnReset write FOnReset;
    property OnError: TErrorEvent read FOnError write FOnError;
    property OnReadChar: TOISCIn read FOISCIn write FOISCIn;
    property OnWriteText: TOISCOut read FOISCOut write FOISCOut;
  end;

implementation

{ TOISCSubleq }

var
  CS: TRTLCriticalSection;

constructor TOISCSubleq.Create(CreateSuspended: Boolean);
begin
  inherited Create(False);

  Priority := tpNormal;
  FreeOnTerminate := True;

  FIsRunning := False;
  FIsHalted := False;
  FIsPaused := True;
  FIsReset := False;

  SetLength(FMem, 0);
  FAddr := 0;
end;

procedure TOISCSubleq.Execute;
var
  A, B, C: Integer;
  Ax: LongWord absolute A;
  Bx: LongWord absolute B;
  Cx: LongWord absolute C;
begin
  FAddr := 0;

  if Length(FMem) = 0 then
  begin
    FError := 1;
    Synchronize(ErrorTrap);
    Exit;
  end;

  FError := 0;
  ExecRun;

  while not Terminated do
  begin
    if FAddr + 3 > FMemTop then
    begin
      FError := 1;
      Synchronize(ErrorTrap);
      Break;
    end;

    if FIsReset then
    begin
      FAddr := 0;
      FIsReset := False;
    end
    else if FIsHalted then
      Break
    else if FIsPaused then
      Continue;

    A := FMem[FAddr];
    B := FMem[FAddr + 1];
    C := FMem[FAddr + 2];

    if Ax = $FFFFFFFF then // FMem[Bx] = key (wait key)
    begin
      if Assigned(FOISCIn) then
      begin
        Synchronize(ReadChar);

        while not (FIsHalted or FIsReset or FIsPaused) and (FChrBuff = #0) do
          Synchronize(ReadChar);

        if FIsHalted or FIsReset or FIsPaused then
          Continue;

        FMem[Bx] := Ord(FChrBuff);
      end
      else
        FMem[Bx] := 0;
    end
    else if Ax = $FFFFFFFE then // FMem[Bx] = key (don't wait key)
    begin
      Synchronize(ReadChar);
      FMem[Bx] := Ord(FChrBuff);
    end
    else if Ax > FMemTop then
    begin
      FError := 2;
      Synchronize(ErrorTrap);
      Break;
    end
    else if Bx = $FFFFFFFF then // Display FMem[Ax]
    begin
      FChrBuff := Chr(FMem[Ax]);
      Synchronize(WriteChar);
    end
    else if Bx > FMemTop then
    begin
      FError := 3;
      Synchronize(ErrorTrap);
      Break;
    end
    else // Execute instruction
    begin
      FMem[Bx] := FMem[Bx] - FMem[Ax];

      if FMem[Bx] <= 0 then
        if Cx = $FFFFFFFF then // Execute HALT
        begin
          Inc(FAddr, 2);
          ExecHalt;
          Break;
        end
        else if Cx > FMemTop then
        begin
          FError := 4;
          Synchronize(ErrorTrap);
          Break;
        end
        else
        begin
          FAddr := Cx;
          Continue;
        end;
    end;

    Inc(FAddr, 3);
  end;
end;

procedure TOISCSubleq.WriteString;
var
  i: Integer;
begin
  if Assigned(FOISCOut) then
  begin
    for i := 1 to Length(FTxtBuff) do
      FOISCOut(FTxtBuff[i]);

    FTxtBuff := '';
  end;
end;

procedure TOISCSubleq.GoHalted;
begin
  FIsHalted := True;
  FIsPaused := False;

  if Assigned(FOnHalt) then
    FOnHalt(Self, Self.FAddr);
end;

procedure TOISCSubleq.ReadChar;
begin
  if Assigned(FOISCIn) then
    FChrBuff := FOISCIn()
  else
    FChrBuff := #0;
end;

procedure TOISCSubleq.GoRunning;
begin
  if FIsHalted then
    Exit;

  FIsReset := False;
  FIsHalted := False;
  FIsPaused := False;

  if Assigned(FOnStart) then
    FOnStart(Self);
end;

procedure TOISCSubleq.WriteChar;
begin
  if Assigned(FOISCOut) then
  begin
    FOISCOut(FChrBuff);
    FChrBuff := #0;
  end;
end;

procedure TOISCSubleq.GoPaused;
begin
  FIsPaused := True;

  if Assigned(FOnPause) then
    FOnPause(Self, Self.FAddr);
end;

procedure TOISCSubleq.ExecHalt;
begin
  EnterCriticalSection(CS);

  try
    Synchronize(GoHalted);
  finally
    LeaveCriticalSection(CS);
  end;
end;

procedure TOISCSubleq.ExecPause;
begin
  EnterCriticalSection(CS);

  try
    if not FIsPaused then
    begin
      Synchronize(GoPaused);
    end;
  finally
    LeaveCriticalSection(CS);
  end;
end;

procedure TOISCSubleq.ExecRun;
begin
  EnterCriticalSection(CS);

  try
    if FIsPaused then
      Synchronize(GoRunning);
  finally
    LeaveCriticalSection(CS);
  end;
end;

procedure TOISCSubleq.ExecReset;
begin
  EnterCriticalSection(CS);

  try
    FIsReset := True;
    FIsHalted := False;
    FIsPaused := False;

    if Assigned(FonReset) then
      FOnReset(Self, Self.FAddr);
  finally
    LeaveCriticalSection(CS);
  end;
end;

procedure TOISCSubleq.LoadProgr(Progr: array of Integer);
var
  i: Longword;
begin
  ExecPause;

  EnterCriticalSection(CS);

  try
    SetLength(FMem, Length(Progr));

    for i := 0 to Length(Progr) - 1 do
      FMem[i] := Progr[i];

    FAddr := 0;
    FMemTop := High(FMem);
  finally
    LeaveCriticalSection(CS);
  end;
end;

function TOISCSubleq.Paused: Boolean;
begin
  Result := FIsPaused;
end;

procedure TOISCSubleq.ErrorTrap;
begin
  FIsHalted := True;
  FIsPaused := False;

  if Assigned(FOnError) then
    FOnError(Self, Self.FAddr, Self.FError);
end;

initialization
  InitializeCriticalSection(CS);
  //OleInitialize(nil);

finalization
  DeleteCriticalSection(CS);
  //OleUninitialize;

end.

