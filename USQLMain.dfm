object frmSqlBuilder: TfrmSqlBuilder
  Left = 0
  Top = 0
  Caption = 'SQL Statement Builder for Firedac'
  ClientHeight = 562
  ClientWidth = 703
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
  object Label1: TLabel
    Left = 11
    Top = 199
    Width = 79
    Height = 13
    Caption = 'Componet Name'
  end
  object Label2: TLabel
    Left = 8
    Top = 229
    Width = 46
    Height = 13
    Caption = 'SQL Type'
  end
  object Label3: TLabel
    Left = 255
    Top = 285
    Width = 56
    Height = 13
    Caption = 'Table Name'
  end
  object Label5: TLabel
    Left = 255
    Top = 256
    Width = 76
    Height = 13
    Caption = 'Database Name'
  end
  object Label6: TLabel
    Left = 255
    Top = 226
    Width = 52
    Height = 13
    Caption = 'User Name'
  end
  object Label7: TLabel
    Left = 488
    Top = 226
    Width = 46
    Height = 13
    Caption = 'Password'
  end
  object Label8: TLabel
    Left = 255
    Top = 199
    Width = 62
    Height = 13
    Caption = 'Server Name'
  end
  object Label9: TLabel
    Left = 488
    Top = 199
    Width = 43
    Height = 13
    Caption = 'Driver ID'
  end
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 703
    Height = 193
    Align = alTop
    Lines.Strings = (
      '<enter table column name>')
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object edtCName: TEdit
    Left = 96
    Top = 199
    Width = 145
    Height = 21
    TabOrder = 1
  end
  object chbSqlWith: TCheckBox
    Left = 96
    Top = 253
    Width = 97
    Height = 17
    Caption = 'With Statement'
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
  object cmbSqlType: TComboBox
    Left = 96
    Top = 226
    Width = 145
    Height = 21
    ItemIndex = 0
    TabOrder = 3
    Text = 'Insert'
    Items.Strings = (
      'Insert'
      'Update')
  end
  object btnSqlBuilder: TButton
    Left = 8
    Top = 278
    Width = 97
    Height = 25
    Caption = 'Build Statement'
    TabOrder = 4
    OnClick = btnSqlBuilderClick
  end
  object Memo2: TMemo
    Left = 0
    Top = 309
    Width = 703
    Height = 253
    Align = alBottom
    ScrollBars = ssBoth
    TabOrder = 5
  end
  object edtUserName: TEdit
    Left = 345
    Top = 226
    Width = 130
    Height = 21
    TabOrder = 6
  end
  object edtPassword: TEdit
    Left = 565
    Top = 226
    Width = 130
    Height = 21
    PasswordChar = '*'
    TabOrder = 7
  end
  object cmbTblName: TComboBox
    Left = 345
    Top = 282
    Width = 214
    Height = 21
    TabOrder = 8
    OnChange = cmbTblNameChange
  end
  object edtServerName: TEdit
    Left = 345
    Top = 199
    Width = 130
    Height = 21
    TabOrder = 9
  end
  object edtDriverID: TEdit
    Left = 565
    Top = 199
    Width = 130
    Height = 21
    TabOrder = 10
  end
  object cmbDatabase: TComboBox
    Left = 345
    Top = 255
    Width = 214
    Height = 21
    TabOrder = 11
  end
  object btnGetCatalogNames: TButton
    Left = 574
    Top = 253
    Width = 121
    Height = 21
    Caption = 'Get Catalog Name'
    TabOrder = 12
    OnClick = btnGetCatalogNamesClick
  end
  object btnGetTblName: TButton
    Left = 574
    Top = 283
    Width = 121
    Height = 21
    Caption = 'Get Table Name'
    TabOrder = 13
    OnClick = cmbTblNameClick
  end
  object btnDBConnect: TButton
    Left = 144
    Top = 278
    Width = 97
    Height = 25
    Caption = 'DB Connect'
    TabOrder = 14
    OnClick = btnDBConnectClick
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
    Left = 416
    Top = 32
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
end
