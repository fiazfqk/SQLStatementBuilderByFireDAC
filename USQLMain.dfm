object frmSqlBuilder: TfrmSqlBuilder
  Left = 0
  Top = 0
  Caption = 'SQL Statement Builder for Firedac'
  ClientHeight = 600
  ClientWidth = 950
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 264
    Top = 0
    Width = 5
    Height = 600
    Color = clBtnFace
    MinSize = 264
    ParentColor = False
    ExplicitLeft = 260
    ExplicitTop = 1
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 0
    Width = 264
    Height = 600
    Align = alLeft
    TabOrder = 0
    DesignSize = (
      264
      600)
    object lblComponetName: TLabel
      Left = 9
      Top = 311
      Width = 79
      Height = 13
      Caption = 'Componet Name'
    end
    object lblSQLQueryType: TLabel
      Left = 9
      Top = 338
      Width = 79
      Height = 13
      Caption = 'SQL Query Type'
    end
    object lblTableName: TLabel
      Left = 6
      Top = 195
      Width = 56
      Height = 13
      Caption = 'Table Name'
    end
    object lblDatabaseName: TLabel
      Left = 6
      Top = 164
      Width = 76
      Height = 13
      Caption = 'Database Name'
    end
    object lblUserName: TLabel
      Left = 6
      Top = 103
      Width = 52
      Height = 13
      Caption = 'User Name'
    end
    object lblPassword: TLabel
      Left = 6
      Top = 134
      Width = 46
      Height = 13
      Caption = 'Password'
    end
    object lblServerName: TLabel
      Left = 6
      Top = 73
      Width = 62
      Height = 13
      Caption = 'Server Name'
    end
    object lblDriverID: TLabel
      Left = 6
      Top = 42
      Width = 43
      Height = 13
      Caption = 'Driver ID'
    end
    object lblServerType: TLabel
      Left = 12
      Top = 12
      Width = 62
      Height = 13
      Caption = 'Server  Type'
    end
    object btnDBConnect: TButton
      Left = 6
      Top = 233
      Width = 118
      Height = 25
      Caption = 'DB Connect'
      TabOrder = 0
      OnClick = btnDBConnectClick
    end
    object btnGetDBNames: TButton
      Left = 6
      Top = 264
      Width = 118
      Height = 25
      Caption = 'Get Database'
      TabOrder = 1
      OnClick = btnGetDBNamesClick
    end
    object btnGetTblName: TButton
      Left = 130
      Top = 264
      Width = 124
      Height = 25
      Caption = 'Get DB Tables'
      TabOrder = 2
      OnClick = cmbTblNameClick
    end
    object btnSqlBuilder: TButton
      Left = 130
      Top = 362
      Width = 124
      Height = 25
      Caption = 'Build Statement'
      TabOrder = 3
      OnClick = btnSqlBuilderClick
    end
    object chbSqlWith: TCheckBox
      Left = 9
      Top = 366
      Width = 97
      Height = 17
      Caption = 'With Statement'
      Checked = True
      State = cbChecked
      TabOrder = 4
    end
    object cmbDatabase: TComboBox
      Left = 109
      Top = 162
      Width = 145
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 5
    end
    object cmbSqlType: TComboBox
      Left = 109
      Top = 335
      Width = 145
      Height = 21
      ItemIndex = 0
      TabOrder = 6
      Text = 'Insert'
      Items.Strings = (
        'Insert'
        'Update')
    end
    object cmbTblName: TComboBox
      Left = 109
      Top = 193
      Width = 145
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 7
      OnChange = cmbTblNameChange
    end
    object edtCName: TEdit
      Left = 109
      Top = 308
      Width = 145
      Height = 21
      TabOrder = 8
    end
    object edtDriverID: TEdit
      Left = 109
      Top = 42
      Width = 145
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 9
    end
    object edtPassword: TEdit
      Left = 109
      Top = 132
      Width = 145
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      PasswordChar = '*'
      TabOrder = 10
    end
    object edtServerName: TEdit
      Left = 109
      Top = 72
      Width = 145
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 11
    end
    object edtUserName: TEdit
      Left = 109
      Top = 102
      Width = 145
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 12
    end
    object cbbServerType: TComboBox
      Left = 109
      Top = 15
      Width = 145
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 13
      OnChange = cbbServerTypeChange
      Items.Strings = (
        'SQL Server'
        'MySQL')
    end
    object btnDBDisconnect: TButton
      Left = 130
      Top = 233
      Width = 124
      Height = 25
      Caption = 'DB Connect'
      Enabled = False
      TabOrder = 14
      OnClick = btnDBDisconnectClick
    end
  end
  object pnlRight: TPanel
    Left = 269
    Top = 0
    Width = 681
    Height = 600
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 264
    ExplicitWidth = 686
    object Splitter2: TSplitter
      Left = 1
      Top = 286
      Width = 679
      Height = 5
      Cursor = crVSplit
      Align = alTop
      Color = clBtnFace
      ParentColor = False
      ExplicitLeft = -8
      ExplicitTop = 253
      ExplicitWidth = 950
    end
    object pnlRightTop: TPanel
      Left = 1
      Top = 1
      Width = 679
      Height = 285
      Align = alTop
      TabOrder = 0
      object Memo1: TMemo
        Left = 1
        Top = 1
        Width = 677
        Height = 283
        Align = alClient
        Lines.Strings = (
          '<enter table column name>')
        ScrollBars = ssBoth
        TabOrder = 0
        ExplicitLeft = 0
        ExplicitTop = 2
        ExplicitHeight = 294
      end
    end
    object pnlRightBottom: TPanel
      Left = 1
      Top = 291
      Width = 679
      Height = 308
      Align = alClient
      TabOrder = 1
      ExplicitTop = 296
      ExplicitHeight = 303
      object Memo2: TMemo
        Left = 1
        Top = 1
        Width = 677
        Height = 306
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
        ExplicitWidth = 682
        ExplicitHeight = 346
      end
    end
  end
  object FDConnection1: TFDConnection
    Left = 528
    Top = 24
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection1
    Left = 616
    Top = 24
  end
  object FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink
    Left = 336
    Top = 24
  end
  object FDManager: TFDManager
    WaitCursor = gcrAppWait
    FormatOptions.AssignedValues = [fvMapRules]
    FormatOptions.OwnMapRules = True
    FormatOptions.MapRules = <>
    Active = True
    Left = 536
    Top = 88
  end
  object FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink
    Left = 338
    Top = 74
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 334
    Top = 129
  end
end
