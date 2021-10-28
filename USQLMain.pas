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
  FireDAC.Comp.Client, Vcl.ExtCtrls, FireDAC.Phys.MySQLDef, FireDAC.Phys.MySQL,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite;

type
  TfrmSqlBuilder = class(TForm)
    Memo1: TMemo;
    edtCName: TEdit;
    lblComponetName: TLabel;
    chbSqlWith: TCheckBox;
    cmbSqlType: TComboBox;
    lblSQLQueryType: TLabel;
    btnSqlBuilder: TButton;
    lblTableName: TLabel;
    Memo2: TMemo;
    lblDatabaseName: TLabel;
    edtUserName: TEdit;
    lblUserName: TLabel;
    edtPassword: TEdit;
    lblPassword: TLabel;
    cmbTblName: TComboBox;
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    edtServerName: TEdit;
    lblServerName: TLabel;
    lblDriverID: TLabel;
    edtDriverID: TEdit;
    cmbDatabase: TComboBox;
    btnGetDBNames: TButton;
    btnGetTblName: TButton;
    FDManager: TFDManager;
    btnDBConnect: TButton;
    pnlRight: TPanel;
    pnlLeft: TPanel;
    Splitter1: TSplitter;
    cbbServerType: TComboBox;
    lblServerType: TLabel;
    pnlRightTop: TPanel;
    pnlRightBottom: TPanel;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    btnDBDisconnect: TButton;
    Splitter2: TSplitter;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    procedure btnSqlBuilderClick(Sender: TObject);
    procedure btnGetDBNamesClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cmbTblNameClick(Sender: TObject);
    procedure cmbTblNameChange(Sender: TObject);
    procedure btnDBConnectClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbbServerTypeChange(Sender: TObject);
    procedure btnDBDisconnectClick(Sender: TObject);
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
  IniSection : String;
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
    UserName:= ini.ReadString(IniSection,'UserName','');
    edtUserName.Text := ini.ReadString(IniSection,'UserName','');
    PassWord:= ini.ReadString(IniSection,'PassWord','');
    edtPassword.Text := ini.ReadString(IniSection,'PassWord','');
    InitialCatalog:= ini.ReadString(IniSection,'InitialCatalog','');
    //edtDatabase.Text := ini.ReadString('DB','InitialCatalog','');
    Server:= ini.ReadString(IniSection,'Server','');
    edtServerName.Text := ini.ReadString(IniSection,'Server','');
    DriverID:= ini.ReadString(IniSection,'DriverID','');
    edtDriverID.Text := ini.ReadString(IniSection,'DriverID','');
  finally
    ini.Free;
  end;
end;

function TfrmSqlBuilder.DBConnect() : Boolean;
var Params : TStrings;
begin
Result:= False;
  btnDBConnect.Caption := 'Not Connected';
  ReadConnectionINI();

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
    FDManager.AddConnectionDef('SQLQueryBuilder_Connection', edtDriverID.Text, Params);
   finally
   Params.Free;
   end;

  if FDConnection1.Connected then FDConnection1.Connected := False;
  FDConnection1.LoginPrompt := False;
    try
     FDConnection1.ConnectionDefName := 'SQLQueryBuilder_Connection';
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
   btnDBDisconnectClick(self);

   if DBConnect() then
   begin
   try
   btnGetDBNamesClick(self);
   if (cmbDatabase.Text <> '') then cmbTblNameClick(Self);
   btnDBDisconnect.Enabled:= True;
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
  self.Caption := self.Caption + ' - ' + ExeReadVerInfo();
end;

procedure TfrmSqlBuilder.btnDBDisconnectClick(Sender: TObject);
begin
    if FDConnection1.Connected then begin
    FDManager.Close;
    FDConnection1.Connected := False;
    FDManager.Close;
    cmbDatabase.Clear;
    cmbDatabase.Items.Clear;
    cmbDatabase.ItemIndex:= -1;
    cmbTblName.Clear;
    cmbTblName.Items.Clear;
    cmbTblName.ItemIndex:= -1;
   end;
end;

procedure TfrmSqlBuilder.btnGetDBNamesClick(Sender: TObject);
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
       if DBConnect then btnGetDBNamesClick(self);
    end;
  end
end;

procedure TfrmSqlBuilder.cbbServerTypeChange(Sender: TObject);
begin
  case cbbServerType.ItemIndex of
   0: begin edtDriverID.Text:= 'MSSQL'; IniSection:= 'MSSQLDB'; end;
   1: begin edtDriverID.Text:= 'MySQL';  IniSection:= 'MySQLDB'; end;
  end;
  ReadConnectionINI();
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
       if DBConnect then btnGetDBNamesClick(self);
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
    FDConnection1.GetTableNames(cmbDatabase.Text, '', '', cmbTblName.Items, [osMy, osOther], [tkTable], False);
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
