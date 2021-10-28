program ProjSqlStatementBuilder;

uses
  Vcl.Forms,
  USQLMain in 'USQLMain.pas' {frmSqlBuilder},
  UExeInfo in 'UExeInfo.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmSqlBuilder, frmSqlBuilder);
  Application.Run;
end.
