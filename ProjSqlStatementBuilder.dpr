program ProjSqlStatementBuilder;

uses
  Vcl.Forms,
  USQLMain in 'USQLMain.pas' {frmSqlBuilder};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmSqlBuilder, frmSqlBuilder);
  Application.Run;
end.
