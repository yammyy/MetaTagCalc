unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Winapi.D2D1, Winapi.ActiveX, System.Win.ComObj, Vcl.ExtCtrls,
  Vcl.ComCtrls, System.IniFiles;

type
  /// <summary> Class representing a DirectWrite handler using a singleton pattern. </summary>
  TDWHandler = class
  protected
    FDLL: HMODULE;
    DWriteCreateFactory: function(factoryType: Integer; const riid: TGUID;
                                  out factory: IUnknown): HRESULT; stdcall;
    FDWriteFactory: IUnknown;
    class var FInstance: TDWHandler;
    class var FRefCount: Integer;
    /// 🔒 Getter for the singleton
    class function GetInstance: TDWHandler; static;
    class procedure ReleaseInstance;
    /// 🔒 Private constructor
    constructor CreatePrivate;
    destructor DestroyPrivate;
    /// <summary> 🔒 Get the DirectWrite factory </summary>
    function getFactory: IDWriteFactory;
    /// <summary> 🔒 Initializes DirectWrite: checks if it is available and loads the Dwrite.dll library. </summary>
    function getDirectWrite(): Boolean;
    /// <summary> 🔒 Assigns the function to create the DirectWrite factory. </summary>
    function assignFactory(): Boolean;
    /// <summary> 🔒 Creates the DirectWrite factory. </summary>
    function createFactory(): Boolean;
  public
    constructor Create; deprecated 'Use TDWHandler.Instance instead of Create';
    destructor Destroy; deprecated 'Use TDWHandler.ReleseInstance instead of Destroy';
    class property Instance: TDWHandler read GetInstance;
    /// <summary> DirectWrite factory. </summary>
    property Factory: IDWriteFactory read getFactory;
  end;

  /// <summary> Class for working with text formats in DirectWrite, representing a font. </summary>
  TDWFont = class
  protected
    DWHandler: TDWHandler;
    /// 🔹 Font name
    FFontName: string;
    /// 🔹 Font size
    FFontSize: Single;
    /// 🔹 Font weight
    FFontWeight: DWRITE_FONT_WEIGHT;
    /// 🔹 Font style
    FFontStyle: DWRITE_FONT_STYLE;
    /// 🔹 Font stretch
    FFontStretch: DWRITE_FONT_STRETCH;
    /// 🔹 Text format in DirectWrite
    FDWriteTextFormat: IDWriteTextFormat;
    /// <summary> 🔒 Method to create the text format with the specified parameters. </summary>
    function CreateTextFormat: Boolean;
  public
    /// <summary> Default constructor. Creates an object with default font parameters. </summary>
    constructor Create; overload;
    /// <summary> Constructor with font parameters (font name and size). </summary>
    constructor Create(_fontName: String; _fontSize: Single); overload;
    /// <summary> Constructor with font parameters (name, size, weight, style, and stretch). </summary>
    constructor Create(_fontName: String; _fontSize: Single; _fontWeight: DWRITE_FONT_WEIGHT;
                       _fontStyle: DWRITE_FONT_STYLE; _fontStretch: DWRITE_FONT_STRETCH); overload;
    destructor Destroy;
    /// <summary> Reloads the font with the specified parameters: name and size. </summary>
    procedure ReloadFont(_fontName: String; _fontSize: Single); overload;
    /// <summary> Reloads the font with the specified parameters: name, size, weight,
    /// style, and stretch. </summary>
    procedure ReloadFont(_fontName: String; _fontSize: Single;
                         _fontWeight: DWRITE_FONT_WEIGHT; _fontStyle: DWRITE_FONT_STYLE;
                         _fontStretch: DWRITE_FONT_STRETCH); overload;
    property DWFont: IDWriteTextFormat read FDWriteTextFormat;
  end;

  /// <summary> Class for working working with text </summary>
  TDWTL = class
  protected
    /// 🔹 Reference to the TDWFont object
    FFont: TDWFont;
    /// 🔹 Text
    FText: String;
    /// 🔹 DirectWrite text layout
    FDWriteTextLayout: IDWriteTextLayout;
    /// <summary> 🔒 Method to create the text layout using the TDWFont. </summary>
    procedure CreateTextLayout(const Text: string);
    function GetTextMetrics: Integer;
  public
    /// <summary> Constructor that creates a default font and text layout. </summary>
    constructor Create;
    destructor Destroy;
    /// <summary> Assigns a new font to the existing text layout by creating it with new parameters (font name and font size). </summary>
    procedure AssignNewFont(const FontName: string; FontSize: Single);
    /// <summary> Changes the text in the text layout. </summary>
    procedure ChangeText(const NewText: string);
    /// <summary> Retrieves the text metrics (width in pixels) of the current text layout. </summary>
    property TextWidth: Integer read GetTextMetrics;
  end;


  ///<summary> Holds references to result display labels and their corresponding limit values </summary>
  TResult_data = record
    /// Label to display calculated text width in pixels
    width_in_pixels: TLabel;
    /// Label to display text length in symbols (characters)
    width_in_symbols: TLabel;
    /// Label to display text length in symbols (characters)
    width_in_symbols_wo_s: TLabel;
    /// Two thresholds for pixel width limits: [0] below is red, [1] upper is yellow
    limit_in_pixels: array [0..1] of Integer;
    /// Two thresholds for symbol count limits: [0] below is red, [1] upper is yellow
    limit_in_symbols: array [0..1] of Integer;
  end;
  /// The manager class, that manages results to user
  TSEO_data = class
    protected
      /// DirectWrite calculations
      dw_field: TDWTL;
      /// Input text field to analyze
      text: TWinControl;
      /// Label that shows a styled preview of the text
      preview: TLabel;
      /// Font selector dropdown
      fontcmb: TComboBox;
      /// Edit box for inputting font size
      fontedit: TEdit;
      /// Struct holding result labels and limits
      res: TResult_data;
      /// <summary> 🔒 Calculates the pixel width of the text based on current font settings </summary>
      function GetTextWidthInPixels(): Integer;
      /// <summary> 🔒 Returns the number of characters in the text </summary>
      function GetTextWidthInSymbols(): Integer; overload;
      /// <summary> 🔒 Returns the number of characters in the text without spaces </summary>
      function GetTextWidthInSymbols(_space:Boolean): Integer; overload;
    public
      constructor Create(const _text: TWinControl; const _preview: TLabel; const
          _fontCombobox: TComboBox; const _fontSizeEdit: TEdit); overload;
      destructor Destroy;
      /// <summary> Assigns labels used for displaying width results (pixels and symbols) </summary>
      procedure assignResLabels(const _widthInPxLabel: TLabel;
                                const _widthInSymbolsLabel: TLabel;
                                const _widthInSbWOSLabel: TLabel);
      /// <summary> Sets the pixel count limits for red and yellow warnings </summary>
      procedure changePixelLimits(_redLimit: Integer; _yellowLimit: Integer);
      /// <summary> Sets the pixel count limits for red and yellow warnings </summary>
      procedure changeSymbolLimits(_redLimit: Integer; _yellowLimit: Integer);
      /// <summary> Update font for directWrite </summary>
      procedure changeFont;
      /// <summary> Update text for directWrite </summary>
      procedure changeText;
      /// <summary> Updates the preview label to reflect the current text and font settings </summary>
      procedure updatePreview;
      /// <summary> Updates the result labels with current width values and applies warning styles </summary>
      procedure updateResultLabels;
  end;


  TMainForm = class(TForm)
    TitleEdit: TEdit;
    TitleFontSizeEdit: TEdit;
    TitleFont_CMB: TComboBox;
    TitlePreview_Label: TLabel;
    TitleResPanel: TPanel;
    TitlePx_Label: TLabel;
    TitleSb_Label: TLabel;
    TitleSbWOS_Label: TLabel;
    DescriptionEdit: TMemo;
    DescriptionFontSizeEdit: TEdit;
    DescriptionFont_CMB: TComboBox;
    DescriptionPreview_Label: TLabel;
    DescResPanel: TPanel;
    DescriptionPx_Label: TLabel;
    DescriptionSb_Label: TLabel;
    DescriptionSbWOS_Label: TLabel;
    PreviewPanel: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure GetAllFonts(const _cbs: array of TComboBox);
    procedure LoadLimitsFromIni();
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure TitleResPanelResize(Sender: TObject);
    procedure TitleFontSizeEditChange(Sender: TObject);
    procedure TitleEditChange(Sender: TObject);
    procedure DescriptionFontSizeEditChange(Sender: TObject);
    procedure DescriptionEditChange(Sender: TObject);
  private
    titleVar:TSEO_data;
    descVar:TSEO_data;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

//---------------------------------------TDWHandler-----------------------------
// Class representing a DirectWrite handler using a singleton pattern.

constructor TDWHandler.Create;
begin
  raise Exception.Create('Use TDWHandler.Instance instead of Create');
end;

destructor TDWHandler.Destroy;
begin
  raise Exception.Create('Use TDWHandler.ReleaseInstance instead of Destroy');
end;

constructor TDWHandler.CreatePrivate;
var
  a: Integer;
begin
  if not getDirectWrite then
    if not assignFactory then
      if not createFactory then
        // Show a message indicating DirectWrite is successfully loaded
        a:=1;//ShowMessage('DirectWrite successfully loaded');
end;

destructor TDWHandler.DestroyPrivate;
begin
  FDWriteFactory := nil;
  DWriteCreateFactory := nil;
  if FDLL <> 0 then
    begin
      FreeLibrary(FDLL);
      FDLL := 0;
    end;
end;


class function TDWHandler.GetInstance: TDWHandler;
begin
  if not Assigned(FInstance) then
    FInstance := TDWHandler.CreatePrivate;
  Inc(FRefCount);
  Result := FInstance;
end;

class procedure TDWHandler.ReleaseInstance;
begin
  if Assigned(FInstance) then
    begin
      Dec(FRefCount);
      if FRefCount <= 0 then
        begin
          FInstance.DestroyPrivate;
          FInstance := nil;
          FRefCount := 0;
        end;
    end;
end;

function TDWHandler.getDirectWrite: Boolean;
var
  ErrorFlag: Boolean;
begin
  ErrorFlag := false;
  Self.FDLL := LoadLibrary('Dwrite.dll');
  if Self.FDLL = 0 then
    begin
      ShowMessage('DirectWrite is not supported on this PC.');
      ErrorFlag := true;
    end;
  Result := ErrorFlag;
end;

function TDWHandler.assignFactory: Boolean;
var
  ErrorFlag: Boolean;
begin
  ErrorFlag := false;
  // Get the address of DWriteCreateFactory function
  @DWriteCreateFactory := GetProcAddress(Self.FDLL, 'DWriteCreateFactory');
  if not Assigned(DWriteCreateFactory) then
    begin
      ShowMessage('Error loading DWriteCreateFactory.');
      ErrorFlag := true;
    end;
  Result := ErrorFlag;
end;

function TDWHandler.createFactory: Boolean;
var
  ErrorFlag: Boolean;
begin
  ErrorFlag := false;
  // Create the DirectWrite factory
  if Failed(DWriteCreateFactory(0, IUnknown, Self.FDWriteFactory)) then
    begin
      ShowMessage('Error creating DirectWrite factory.');
      ErrorFlag := true;
    end;
  Result := ErrorFlag;
end;

function TDWHandler.getFactory: IDWriteFactory;
begin
  if not Assigned(FDWriteFactory) then
    raise Exception.Create('DirectWrite factory is not initialized.');
  Result := FDWriteFactory as IDWriteFactory;
end;

//---------------------------------------TDWFont--------------------------------
// Class for working with text formats in DirectWrite, representing a font.

function TDWFont.CreateTextFormat: Boolean;
var
  ErrorFlag: Boolean;
  hr: HRESULT;
begin
  ErrorFlag:=false;
  if Assigned(FDWriteTextFormat) then
    begin
      FDWriteTextFormat := nil;
    end;
  if not Assigned(DWHandler.Factory) then
    begin
      ShowMessage('Factory is not assigned.');
      ErrorFlag := true;
    end;
  hr:=DWHandler.Factory.CreateTextFormat(PWideChar(FFontName),
                                         nil,  // Optional: font collection
                                         FFontWeight,
                                         FFontStyle,
                                         FFontStretch,
                                         FFontSize,
                                         PWideChar(''),  // Locale (leave empty)
                                         FDWriteTextFormat);
  if Failed(hr) then
    begin
      ShowMessage('Error creating text format.');
      ErrorFlag:=true;
    end;
  Result:=ErrorFlag;
end;

constructor TDWFont.Create;
begin
  Create('Arial',18,DWRITE_FONT_WEIGHT_REGULAR,DWRITE_FONT_STYLE_NORMAL,
         DWRITE_FONT_STRETCH_NORMAL);
end;

constructor TDWFont.Create(_fontName: String; _fontSize: Single);
begin
  Create(_fontName,_fontSize,DWRITE_FONT_WEIGHT_REGULAR,DWRITE_FONT_STYLE_NORMAL,
         DWRITE_FONT_STRETCH_NORMAL);
end;

constructor TDWFont.Create(_fontName: String; _fontSize: Single;
                           _fontWeight: DWRITE_FONT_WEIGHT; _fontStyle: DWRITE_FONT_STYLE;
                           _fontStretch: DWRITE_FONT_STRETCH);
begin
  DWHandler := TDWHandler.Instance;
  FFontName := _fontName;
  FFontSize := _fontSize;
  FFontWeight := _fontWeight;
  FFontStyle := _fontStyle;
  FFontStretch := _fontStretch;
  CreateTextFormat;
end;

destructor TDWFont.Destroy;
begin
  FDWriteTextFormat := nil;
  DWHandler.ReleaseInstance;
end;

procedure TDWFont.ReloadFont(_fontName: String; _fontSize: Single);
begin
  FFontName := _fontName;
  FFontSize := _fontSize;
  CreateTextFormat;
end;

procedure TDWFont.ReloadFont(_fontName: String; _fontSize: Single;
                             _fontWeight: DWRITE_FONT_WEIGHT; _fontStyle: DWRITE_FONT_STYLE;
                             _fontStretch: DWRITE_FONT_STRETCH);
begin
  FFontName := _fontName;
  FFontSize := _fontSize;
  FFontWeight := _fontWeight;
  FFontStyle := _fontStyle;
  FFontStretch := _fontStretch;
  CreateTextFormat;
end;

//---------------------------------------TDWTextLayout--------------------------
// Class for working working with text.

constructor TDWTL.Create;
begin
  // Create default font and text layout with default values
  FFont := TDWFont.Create;
  FText:=' ';
  CreateTextLayout(FText); // Default text is a single space
end;

destructor TDWTL.Destroy;
begin
  FDWriteTextLayout := nil; // Release DirectWrite interface
  if Assigned(FFont) then
    FFont.Destroy;
end;

procedure TDWTL.CreateTextLayout(const Text: string);
begin
  FText:=Text;
  // Create the DirectWrite text layout using the font and text
  if Assigned(FFont.DWFont) then
    begin
      if Failed(FFont.DWHandler.Factory.CreateTextLayout(PWideChar(Text),
                                                         Length(Text),
                                                         FFont.DWFont,
                                                         2000, // Max width of the layout
                                                         2000, // Max height of the layout
                                                         FDWriteTextLayout)) then
        begin
          ShowMessage('Error creating text layout.');
          Exit;
        end;
    end
  else
    begin
      ShowMessage('Font is not initialized.');
    end;
end;

procedure TDWTL.AssignNewFont(const FontName: string; FontSize: Single);
begin
  // Reload the font with new parameters (font name and font size)
  FFont.ReloadFont(FontName, FontSize);
  // Release the current text layout if it exists
  if Assigned(FDWriteTextLayout) then
    begin
      FDWriteTextLayout := nil;
    end;
  // Recreate the text layout with the new font and the existing text
  CreateTextLayout(FText);  // Default text is a single space (or you can pass your current text here)
end;

procedure TDWTL.ChangeText(const NewText: string);
begin
  // Release the current text layout if it exists
  if Assigned(FDWriteTextLayout) then
    begin
      FDWriteTextLayout := nil;
    end;
  // Recreate the text layout with the new text and the existing font
  CreateTextLayout(NewText);
end;

function TDWTL.GetTextMetrics: Integer;
var
  TextMetrics: DWRITE_TEXT_METRICS;
begin
  Result := 0;
  if Assigned(FDWriteTextLayout) then
    begin
      // Get the text metrics for the current layout
      if Succeeded(FDWriteTextLayout.GetMetrics(TextMetrics)) then
        begin
          Result := round(TextMetrics.width); // This will give you the width in pixels
        end
      else
        begin
          ShowMessage('Error retrieving text metrics.');
        end;
    end
  else
    begin
      ShowMessage('Text layout is not initialized.');
    end;
end;

//---------------------------------------TSEO_data------------------------------
// The manager class, that manages results to user

constructor TSEO_data.Create(const _text: TWinControl;
                             const _preview: TLabel;
                             const _fontCombobox: TComboBox;
                             const _fontSizeEdit: TEdit);
var
  s: string;
begin
  Self.fontcmb:=_fontCombobox;
  Self.fontedit:=_fontSizeEdit;
  Self.text:=_text;
  Self.preview:=_preview;
  Self.dw_field:=TDWTL.Create;
  dw_field.AssignNewFont(fontcmb.Items[fontcmb.ItemIndex],strtoint(fontedit.Text));
  s:='';
  if text is TEdit then
    s := TEdit(text).Text
  else if text is TMemo then
    s := TMemo(text).Text;
  dw_field.ChangeText(s);
end;

destructor TSEO_data.Destroy;
begin
  if Assigned(dw_field) then
    dw_field.Destroy;
end;

procedure TSEO_data.assignResLabels(const _widthInPxLabel: TLabel;
                                    const _widthInSymbolsLabel: TLabel;
                                    const _widthInSbWOSLabel: TLabel);
begin
  Self.res.width_in_pixels:=_widthInPxLabel;
  Self.res.width_in_symbols:=_widthInSymbolsLabel;
  Self.res.width_in_symbols_wo_s:=_widthInSbWOSLabel;
end;

procedure TSEO_data.changePixelLimits(_redLimit: Integer; _yellowLimit: Integer);
begin
  Self.res.limit_in_pixels[0]:=_redLimit;
  Self.res.limit_in_pixels[1]:=_yellowLimit;
end;

procedure TSEO_data.changeSymbolLimits(_redLimit: Integer; _yellowLimit: Integer);
begin
  Self.res.limit_in_symbols[0]:=_redLimit;
  Self.res.limit_in_symbols[1]:=_yellowLimit;
end;

function TSEO_data.GetTextWidthInPixels: Integer;
begin
  Result:=Self.dw_field.TextWidth;
end;

function TSEO_data.GetTextWidthInSymbols: Integer;
begin
  if text is TEdit then
    Result := Length(TEdit(text).Text)
  else if text is TMemo then
    Result := Length(TMemo(text).Text)
  else
    Result := 0; // Unknown control type or not assigned
end;

function TSEO_data.GetTextWidthInSymbols(_space: Boolean): Integer;
var
  s: String;
begin
  s:='';
  // Safely extract text depending on control type
  if text is TEdit then
    s := TEdit(text).Text
  else if text is TMemo then
    s := TMemo(text).Text;
  s := StringReplace(s, ' ', '', [rfReplaceAll]);
  Result := Length(s);
end;

procedure TSEO_data.changeFont;
begin
  Self.dw_field.AssignNewFont(fontcmb.Items[fontcmb.ItemIndex],strtoint(fontedit.Text));
end;

procedure TSEO_data.changeText;
var
  s: String;
begin
  s:='';
  if text is TEdit then
    s := TEdit(text).Text
  else if text is TMemo then
    s := TMemo(text).Text;
  Self.dw_field.ChangeText(s);
end;

procedure TSEO_data.updatePreview;
var
  s: String;
begin
  s:='';
  if text is TEdit then
    s := TEdit(text).Text
  else if text is TMemo then
    s := TMemo(text).Text;
  preview.Caption := s;
  // Protect against invalid index or conversion errors
  if (fontcmb.ItemIndex >= 0) and (fontcmb.ItemIndex < fontcmb.Items.Count) then
    preview.Font.Name := fontcmb.Items[fontcmb.ItemIndex];
  try
    preview.Font.Height := -StrToInt(fontedit.Text);
  except
    on E: EConvertError do
      preview.Font.Height := -12; // default fallback value
  end;
end;


procedure TSEO_data.updateResultLabels;
var
  w: Integer;
begin
  w:=GetTextWidthInPixels;
  res.width_in_pixels.Caption:=inttostr(w);
  if w<=res.limit_in_pixels[0] then
    res.width_in_pixels.Color:=clYellow
  else if w<=res.limit_in_pixels[1] then
    res.width_in_pixels.Color:=clGreen
  else
    res.width_in_pixels.Color:=clRed;
  w:=GetTextWidthInSymbols;
  res.width_in_symbols.Caption:=inttostr(w);
  if w<=res.limit_in_symbols[0] then
    res.width_in_symbols.Color:=clYellow
  else if w<=res.limit_in_symbols[1] then
    res.width_in_symbols.Color:=clGreen
  else
    res.width_in_symbols.Color:=clRed;
  res.width_in_symbols_wo_s.Caption:=inttostr(GetTextWidthInSymbols(true));
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  titleVar.Destroy;
  descVar.Destroy;
end;

//---------------------------------------TDWTextLayout--------------------------
// Class for working working with text.

procedure TMainForm.GetAllFonts(const _cbs: array of TComboBox);
var
  FontList: TStringList;
  hdc: Winapi.Windows.HDC;
  i: Integer;
  // Callback function for EnumFonts
  function EnumFontFamExProc(var lpelfe: LOGFONT; var lpntme: TNewTextMetric;
                             dwFontType: DWORD; lParam: LPARAM): Integer; stdcall;
  var List: TStringList;
  begin
    List := TStringList(lParam);  // Retrieve the list passed via LPARAM
    // Add the font name to the list
    List.Add(lpelfe.lfFaceName);
    Result := 1; // Continue enumeration
  end;
begin
  FontList := TStringList.Create;
  try
    hdc := GetDC(0);  // Get the device context for the screen
    try
      EnumFonts(hdc, nil, @EnumFontFamExProc, LPARAM(FontList));
    finally
      ReleaseDC(0, hdc);  // Release the device context
    end;
    FontList.Sort;
    // Assign font list to each combobox
    for i := Low(_cbs) to High(_cbs) do
      if Assigned(_cbs[i]) then
        begin
          _cbs[i].Items.Assign(FontList);
          _cbs[i].ItemIndex := _cbs[i].Items.IndexOf('Arial');
        end;
  finally
    FontList.Free;
  end;
end;




procedure TMainForm.TitleEditChange(Sender: TObject);
begin
  titleVar.changeText;
  titleVar.updatePreview;
  titleVar.updateResultLabels;
end;

procedure TMainForm.TitleFontSizeEditChange(Sender: TObject);
begin
  if Length(TitleFontSizeEdit.Text)<>0 then
    begin
      titleVar.changeFont;
      titleVar.updatePreview;
      titleVar.updateResultLabels;
    end
  else
    begin
      TitlePreview_Label.Caption:='';
      TitlePx_Label.Caption:='';
      TitleSb_Label.Caption:='';
      TitleSbWOS_Label.Caption:='';
    end;
end;

procedure TMainForm.DescriptionEditChange(Sender: TObject);
begin
  descVar.changeText;
  descVar.updatePreview;
  descVar.updateResultLabels;
end;

procedure TMainForm.DescriptionFontSizeEditChange(Sender: TObject);
begin
  if Length(DescriptionFontSizeEdit.Text)<>0 then
    begin
      descVar.changeFont;
      descVar.updatePreview;
      descVar.updateResultLabels;
    end
  else
    begin
      DescriptionPreview_Label.Caption:='';
      DescriptionPx_Label.Caption:='';
      DescriptionSb_Label.Caption:='';
      DescriptionSbWOS_Label.Caption:='';
    end;
end;

procedure TMainForm.EditKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key:=#0;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  titleVar.updatePreview;
  titleVar.updateResultLabels;
  descVar.updatePreview;
  descVar.updateResultLabels;
  TitleResPanelResize(TitleResPanel);
  TitleResPanelResize(DescResPanel);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Call GetAllFonts when the form is created
  GetAllFonts([TitleFont_CMB,DescriptionFont_CMB]);
  titleVar:=TSEO_data.Create(TitleEdit,TitlePreview_Label,TitleFont_CMB,TitleFontSizeEdit);
  titleVar.assignResLabels(TitlePx_Label,TitleSb_Label,TitleSbWOS_Label);
  descVar:=TSEO_data.Create(DescriptionEdit,DescriptionPreview_Label,DescriptionFont_CMB,DescriptionFontSizeEdit);
  descVar.assignResLabels(DescriptionPx_Label,DescriptionSb_Label,DescriptionSbWOS_Label);
  LoadLimitsFromIni;
end;

procedure TMainForm.TitleResPanelResize(Sender: TObject);
var
  pnl: TPanel;
  w: Integer;
begin
  pnl:=(Sender as TPanel);
  w:=Round(pnl.Width/2);
  if pnl.Tag=1 then
    titleVar.res.width_in_pixels.Width:=w;
  if pnl.Tag=2 then
    descVar.res.width_in_pixels.Width:=w;
  w:=Round(w/2);
  if pnl.Tag=1 then
    titleVar.res.width_in_symbols_wo_s.Width:=w;
  if pnl.Tag=2 then
    descVar.res.width_in_symbols_wo_s.Width:=w;
end;

procedure TMainForm.LoadLimitsFromIni;
var
  filePath: string;
  ini: TIniFile;
begin
  // Set the path to your INI file (adjust as needed)
  filePath := ExtractFilePath(ParamStr(0)) + 'config.ini';
  ini := TIniFile.Create(filePath);
  try
    titleVar.changePixelLimits(ini.ReadInteger('Limits', 'title_pixel_limit_yellow', 440),
                               ini.ReadInteger('Limits', 'title_pixel_limit_red', 520));
    titleVar.changeSymbolLimits(ini.ReadInteger('Limits', 'title_symbol_limit_yellow', 50),
                               ini.ReadInteger('Limits', 'title_symbol_limit_red', 60));
    descVar.changePixelLimits(ini.ReadInteger('Limits', 'description_pixel_limit_yellow', 1100),
                               ini.ReadInteger('Limits', 'description_pixel_limit_red', 1200));
    descVar.changeSymbolLimits(ini.ReadInteger('Limits', 'description_symbol_limit_yellow', 160),
                               ini.ReadInteger('Limits', 'description_symbol_limit_red', 180));
    TitleFontSizeEdit.Text:=ini.ReadString('Defaults','title_default_size','18');
    TitleFont_CMB.ItemIndex := TitleFont_CMB.Items.IndexOf(ini.ReadString('Defaults','title_default_font','Arial'));
    DescriptionFontSizeEdit.Text:=ini.ReadString('Defaults','description_default_size','14');
    DescriptionFont_CMB.ItemIndex := DescriptionFont_CMB.Items.IndexOf(ini.ReadString('Defaults','description_default_font','Arial'));
  finally
    ini.Free;
  end;
end;

end.
