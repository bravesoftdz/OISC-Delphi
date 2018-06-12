program OISCsubleq;

uses
  Forms,
  uOiscSubleq in 'UNITS\uOiscSubleq.pas' {FrmOISCSubleq},
  uThreadOiscSubleq in 'UNITS\uThreadOiscSubleq.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'OISC Emulator';
  Application.CreateForm(TFrmOISCSubleq, FrmOISCSubleq);
  Application.Run;
end.
