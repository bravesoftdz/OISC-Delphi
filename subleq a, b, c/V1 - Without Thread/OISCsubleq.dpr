program OISCsubleq;

uses
  Forms,
  uOisc1Subleq in 'UNITS\uOisc1Subleq.pas' {FrmOISCSubleq},
  ClsOISCSubleq in 'UNITS\ClsOISCSubleq.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmOISCSubleq, FrmOISCSubleq);
  Application.Run;
end.
