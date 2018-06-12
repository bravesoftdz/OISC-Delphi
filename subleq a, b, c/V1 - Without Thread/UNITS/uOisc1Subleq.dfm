object FrmOISCSubleq: TFrmOISCSubleq
  Left = 275
  Top = 166
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'OISC - subleq a, b, c'
  ClientHeight = 362
  ClientWidth = 851
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    851
    362)
  PixelsPerInch = 96
  TextHeight = 13
  object lblRunning: TLabel
    Left = 674
    Top = 8
    Width = 119
    Height = 25
    Caption = ' Running... '
    Color = clGreen
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Layout = tlCenter
    Visible = False
  end
  object lblHalt: TLabel
    Left = 674
    Top = 8
    Width = 67
    Height = 25
    Caption = ' HALT '
    Color = clRed
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    ShowAccelChar = False
    Transparent = False
    Layout = tlCenter
  end
  object Display: TMemo
    Left = 8
    Top = 8
    Width = 659
    Height = 346
    Anchors = [akLeft, akTop, akBottom]
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier'
    Font.Style = []
    Lines.Strings = (
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890'
      
        '1234567890123456789012345678901234567890123456789012345678901234' +
        '5678901234567890')
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
    OnChange = DisplayChange
    OnEnter = DisplayEnter
    OnExit = DisplayExit
    OnKeyPress = DisplayKeyPress
  end
  object btnStart: TBitBtn
    Left = 770
    Top = 64
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 1
    OnClick = btnStartClick
  end
  object btnClear: TBitBtn
    Left = 674
    Top = 64
    Width = 75
    Height = 25
    Caption = 'Clear'
    TabOrder = 2
    OnClick = btnClearClick
  end
  object btnStop: TBitBtn
    Left = 770
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Stop'
    Enabled = False
    TabOrder = 3
    OnClick = btnStopClick
  end
end
