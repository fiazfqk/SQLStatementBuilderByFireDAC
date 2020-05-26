unit USQLMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  System.IOUtils,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  inifiles, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TfrmSqlBuilder = class(TForm)
    Memo1: TMemo;
    edtCName: TEdit;
    Label1: TLabel;
    chbSqlWith: TCheckBox;
    cmbSqlType: TComboBox;
    Label2: TLabel;
    btnSqlBuilder: TButton;
    Label3: TLabel;
    Memo2: TMemo;
    Label5: TLabel;
    edtUserName: TEdit;
    Label6: TLabel;
    edtPassword: TEdit;
    Label7: TLabel;
    cmbTblName: TComboBox;
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    edtServerName: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    edtDriverID: TEdit;
    cmbDatabase: TComboBox;
    btnGetCatalogNames: TButton;
    btnGetTblName: TButton;
    FDManager: TFDManager;
    btnDBConnect: TButton;
    procedure btnSqlBuilderClick(Sender: TObject);
    procedure btnGetCatalogNamesClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cmbTblNameClick(Sender: TObject);
    procedure cmbTblNameChange(Sender: TObject);
    procedure btnDBConnectClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
  FStrListKeyField : TStringList;
  FStrKeyField : String;
  function DBConnect: Boolean;
  procedure ReadConnectionINI;
  procedure InsertWith();
  procedure InsertWithout();
  procedure UpdateWith();
  procedure UpdateWithout();

  public
    { Public declarations }
  end;

var
  frmSqlBuilder: TfrmSqlBuilder;
  UserName,PassWord,InitialCatalog,Server,DriverID : String;

implementation

{$R *.dfm}

uses UExeInfo;

procedure TfrmSqlBuilder.ReadConnectionINI();
var ini : TIniFile;
ExePath : string;
begin
  ExePath := TPath.GetDirectoryName(GetModuleName(HInstance));
  ini := TIniFile.Create(TPath.Combine(ExePath, 'DBCredential.ini'));
  try
    UserName:= ini.ReadString('DB','UserName','');
    edtUserName.Text := ini.ReadString('DB','UserName','');
    PassWord:= ini.ReadString('DB','PassWord','');
    edtPassword.Text := ini.ReadString('DB','PassWord','');
    InitialCatalog:= ini.ReadString('DB','InitialCatalog','');
    //edtDatabase.Text := ini.ReadString('DB','InitialCatalog','');
    Server:= ini.ReadString('DB','Server','');
    edtServerName.Text := ini.ReadString('DB','Server','');
    DriverID:= ini.ReadString('DB','DriverID','');
    edtDriverID.Text := ini.ReadString('DB','DriverID','');
  finally
    ini.Free;
  end;
end;

function TfrmSqlBuilder.DBConnect() : Boolean;
var Params : TStrings;
begin
Result:= False;
  btnDBConnect.Caption := 'Not Connected';

  Params := TStringList.Create;
  {Private Connection}
   try
    Params.Add('User_Name='+edtUserName.Text);
    Params.Add('Password='+edtPassword.Text);
    Params.Add('Server='+edtServerName.Text);
    if cmbDatabase.Text <> '' then
        Params.Add('Database='+cmbDatabase.Text);
    Params.Add('DriverID='+edtDriverID.Text);
    Params.Add('Pooled= True');
    FDManager.AddConnectionDef('MSSQL_Connection', 'MSSQL', Params);
   finally
   Params.Free;
   end;

  if FDConnection1.Connected then FDConnection1.Connected := False;
  FDConnection1.LoginPrompt := False;
    try
     FDConnection1.ConnectionDefName := 'MSSQL_Connection';
     FDConnection1.Connected := True;
     btnDBConnect.Caption := 'DB Connected';
     Result:= True;
    except
     on E : Exception do
     begin
      Result:= False;
      MessageDlg(E.Message, mtError, [mbOK], 0);
    end;
   end;
end;

procedure TfrmSqlBuilder.btnDBConnectClick(Sender: TObject);
begin
   if DBConnect() then
   begin
   try
   btnGetCatalogNamesClick(self);
   if (cmbDatabase.Text <> '') then cmbTblNameClick(Self);
   except
    on E : Exception do
    begin
      MessageDlg('Exception Message : ' + E.Message, mtError, [mbOK], 0);
    end;
   end;
   end;
end;

procedure TfrmSqlBuilder.InsertWith;
var
  StrList : TStringList;
  F : String;
  I: Integer;
begin
   StrList := TStringlist.Create;
   StrList.CommaText:= Trim(Memo1.Text);
   try
   if StrList.Count > 0 then
    begin
     F:= ('With '+ edtCName.Text + ' do' + #13#10 +  'begin' + #13#10 +  'Close;' + #13#10 +
      'SQL.Clear;' + #13#10 + 'SQL.Add('+''''+'INSERT INTO ' +  cmbTblName.Text  + ' (');

     //Delete the Primary Key Field from List
     if FStrKeyField <> '' then
      StrList.Delete(StrList.IndexOf(FStrKeyField));

     for I := 0 to StrList.Count-1 do
     begin
     if (I <> StrList.Count-1) then
      begin
      F:=  (F + StrList[I] + ',');
      end else
      begin
      F:=  (F + StrList[I]);
      end;
     end;
     F:= (F+' ) '+ '''' + ');' + #13#10 );

     F:= F + ('SQL.Add('+ '''' +'VALUES (');
     for I := 0 to StrList.Count-1 do
     begin
     if (I <> StrList.Count-1) then
      begin
      F:=  (F + ':' + StrList[I] + ',');
      end else
      begin
      F:=  (F + ':' + StrList[I]);
      end;
     end;
     F:= (F+' ) '+ '''' + ');' + #13#10 );

     for I := 0 to StrList.Count-1 do
     begin
      begin
      F :=  (F + 'ParamByName(' + '''' + StrList[I] + '''' + ')' + #13#10);
      end;
     end;
     F:= (F + 'ExecSQL;' + #13#10 + 'end;');

    end;

    Memo2.Lines.Add(F);
    Memo2.Perform(EM_SCROLLCARET, 0, 0);
   finally
    StrList.Free;
   end;
end;

procedure TfrmSqlBuilder.InsertWithout;
var
  StrList : TStringList;
  F : String;
  I: Integer;
begin
   StrList := TStringlist.Create;
   StrList.CommaText:= Trim(Memo1.Text);
   try
   if StrList.Count > 0 then
    begin
     F:= (edtCName.Text+'.Close;' + #13#10 + edtCName.Text+'.SQL.Clear;' + #13#10 + edtCName.Text+'.SQL.Add('+''''+'INSERT INTO ' +  cmbTblName.Text  + ' (');

     //Delete the Primary Key Field from List
     if FStrKeyField <> '' then
      StrList.Delete(StrList.IndexOf(FStrKeyField));

     for I := 0 to StrList.Count-1 do
     begin
     if (I <> StrList.Count-1) then
      begin
      F:=  (F + StrList[I] + ',');
      end else
      begin
      F:=  (F + StrList[I]);
      end;
     end;
     F:= (F+' ) '+ '''' + ');' + #13#10 );

     F:= F + (edtCName.Text+'.SQL.Add('+ '''' +'VALUES (');
     for I := 0 to StrList.Count-1 do
     begin
     if (I <> StrList.Count-1) then
      begin
      F:=  (F + ':' + StrList[I] + ',');
      end else
      begin
      F:=  (F + ':' + StrList[I]);
      end;
     end;
     F:= (F+' ) '+ '''' + ');' + #13#10 );

     for I := 0 to StrList.Count-1 do
     begin
      begin
      F :=  (F + edtCName.Text+'.ParamByName(' + '''' + StrList[I] + '''' + ')' + #13#10);
      end;
     end;
     F:= (F + edtCName.Text+'.ExecSQL;');

    end;

    Memo2.Lines.Add(F);
    Memo2.Perform(EM_SCROLLCARET, 0, 0);
   finally
    StrList.Free;
   end;
end;

procedure TfrmSqlBuilder.UpdateWith;
var
  StrList : TStringList;
  F : String;
  I: Integer;
begin
   StrList := TStringlist.Create;
   StrList.CommaText:= Trim(Memo1.Text);
   try
    if StrList.Count > 0 then
    begin
     F:= ('With '+ edtCName.Text + ' do' + #13#10 +  'begin' + #13#10 +  'Close;' +
      #13#10 + 'SQL.Clear;' + #13#10 + 'SQL.Add('+''''+'UPDATE '+ cmbTblName.Text +' SET ');

     //Delete the Primary Key Field from List
     if FStrKeyField <> '' then
      StrList.Delete(StrList.IndexOf(FStrKeyField));

     for I := 0 to StrList.Count-1 do
     begin
     if (I <> StrList.Count-1) then
      begin
      F:=  (F + StrList[I] + ' = ');
      F:=  (F + ':' + StrList[I] + ',');
      end else
      begin
            F:=  (F + StrList[I] + ' = ');
      F:=  (F + ':' + StrList[I]);
      end;
     end;
     F:= (F+ '''' + ');' + #13#10 );

     F:= (F + ('SQL.Add('+''''+'WHERE '+ FStrKeyField + ' = ' + '''' +'+ QuotedStr('+'Your ID her'+')' +');' + #13#10));

     for I := 0 to StrList.Count-1 do
     begin
      begin
      F :=  (F + 'ParamByName(' + '''' + StrList[I] + '''' + ')' + #13#10);
      end;
     end;
     F:= (F + 'ExecSQL;' + #13#10 + 'end;');

    Memo2.Lines.Add(F);
    Memo2.Perform(EM_SCROLLCARET, 0, 0);
    end;

   finally
    StrList.Free;
   end;
end;

procedure TfrmSqlBuilder.UpdateWithout;
var
  StrList : TStringList;
  F : String;
  I: Integer;
begin
   StrList := TStringlist.Create;
   StrList.CommaText:= Trim(Memo1.Text);
   try
    if StrList.Count > 0 then
    begin
     F:= (edtCName.Text+'.Close;' + #13#10 + edtCName.Text+'.SQL.Clear;' + #13#10 + edtCName.Text+'.SQL.Add('+''''+'UPDATE '+ cmbTblName.Text +' SET ');

     //Delete the Primary Key Field from List
     if FStrKeyField <> '' then
      StrList.Delete(StrList.IndexOf(FStrKeyField));

     for I := 0 to StrList.Count-1 do
     begin
     if (I <> StrList.Count-1) then
      begin
      F:=  (F + StrList[I] + ' = ');
      F:=  (F + ':' + StrList[I] + ',');
      end else
      begin
            F:=  (F + StrList[I] + ' = ');
      F:=  (F + ':' + StrList[I]);
      end;
     end;
     F:= (F+ '''' + ');' + #13#10 );

     F:= (F + (edtCName.Text+'.SQL.Add('+''''+'WHERE '+ FStrKeyField + ' = ' + '''' +'+ QuotedStr('+'Your ID her'+')' +');' + #13#10));

     for I := 0 to StrList.Count-1 do
     begin
      begin
      F :=  (F + edtCName.Text+'.ParamByName(' + '''' + StrList[I] + '''' + ')' + #13#10);
      end;
     end;
     F:= (F + edtCName.Text+'.ExecSQL;');

    Memo2.Lines.Add(F);
    Memo2.Perform(EM_SCROLLCARET, 0, 0);
    end;

   finally
    StrList.Free;
   end;
end;

procedure TfrmSqlBuilder.FormDestroy(Sender: TObject);
begin
  FDConnection1.Free;
end;

procedure TfrmSqlBuilder.FormShow(Sender: TObject);
begin
  ReadConnectionINI();
  self.Caption := self.Caption + ' - ' + ExeReadVerInfo();
end;

procedure TfrmSqlBuilder.btnGetCatalogNamesClick(Sender: TObject);
begin
 if (edtServerName.Text <> '') and (edtDriverID.Text <> '') and (edtUserName.Text <> '') and
    (edtPassword.Text <> '') then
  begin
    if FDConnection1.Connected then
    begin
      cmbDatabase.Items.Clear;
      FDConnection1.GetCatalogNames('', cmbDatabase.Items);
      cmbDatabase.ItemIndex := 0;
    end else begin
       if DBConnect then btnGetCatalogNamesClick(self);
    end;
  end
end;

procedure TfrmSqlBuilder.cmbTblNameChange(Sender: TObject);
begin
   Memo1.Clear;
 if FDConnection1.Connected then
 begin
   FDConnection1.GetFieldNames(cmbDatabase.Text, '', cmbTblName.Text, '', Memo1.Lines);

   //Get keyFiled Name
  FStrListKeyField := TStringList.Create;
  try
  FDConnection1.GetKeyFieldNames(cmbDatabase.Text, '', cmbTblName.Text, '',  FStrListKeyField);
  finally
   if (FStrListKeyField.Strings[0] <> '') then FStrKeyField := FStrListKeyField[0];
   FStrListKeyField.Free;
  end;
 end else
      begin
       if DBConnect then btnGetCatalogNamesClick(self);
      end;
end;

procedure TfrmSqlBuilder.cmbTblNameClick(Sender: TObject);
begin
if (edtServerName.Text <> '') and (edtDriverID.Text <> '') and (edtUserName.Text <> '') and
   (edtPassword.Text <> '') and (cmbDatabase.Text <> '' ) then
  begin
  if FDConnection1.Connected then
    begin
    cmbTblName.Items.Clear;
    FDConnection1.GetTableNames(cmbDatabase.Text, '', '', cmbTblName.Items, [osMy], [tkTable], False);
    cmbTblName.ItemIndex := 0;
     if cmbTblName.Text <> '' then  cmbTblNameChange(self);

    end else begin
       if DBConnect then cmbTblNameClick(self);
      end;
  end;
end;

procedure TfrmSqlBuilder.btnSqlBuilderClick(Sender: TObject);
begin
  Memo2.Clear;
  if (edtCName.Text = '') then
  begin
  ShowMessage('Please enter the Firedac Component Name');
  exit;
  end;

  if (chbSqlWith.Checked = True) and (cmbSqlType.ItemIndex = 0) then
  begin
  InsertWith();
  end else
  if (chbSqlWith.Checked = False) and (cmbSqlType.ItemIndex = 0) then
  begin
  InsertWithout();
  end else
  if (chbSqlWith.Checked = True) and (cmbSqlType.ItemIndex = 1) then
  begin
  UpdateWith();
  end else
  if (chbSqlWith.Checked = False) and (cmbSqlType.ItemIndex = 1) then
  begin
  UpdateWithout();
  end;

end;

end.
