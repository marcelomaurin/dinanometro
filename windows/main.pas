unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, Menus, TAGraph, indSliders, LedNumber, indGnouMeter, indLCDDisplay,
  A3nalogGauge, IndLed, LazSerial, LazSynaSer, TATypes, TASeries, TACustomSeries,
  TADrawUtils, TAChartUtils, setmain;

type

  { Uma amostra recebida do dinamometro }
  TAmostra = record
    Tempo: Double;     // segundos desde a conexao
    Contagem: Int64;   // valor bruto recebido do firmware (Peso:<n>)
    Gramas: Double;    // massa equivalente (gf)
    Newtons: Double;   // forca em N
  end;

  { Tfrmmain }

  Tfrmmain = class(TForm)
    A3nalogGauge1: TA3nalogGauge;
    btTara: TButton;
    btCalibra: TButton;
    btsalvar: TButton;
    Chart1: TChart;
    edPesoCal: TEdit;
    edPorta: TEdit;
    edTara: TEdit;
    edCalibracao: TEdit;
    Image1: TImage;
    indGnouMeter1: TindGnouMeter;
    indLed1: TindLed;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    lbversao: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LazSerial1: TLazSerial;
    LedForca: TLEDNumber;
    ledPeso: TLEDNumber;
    Memo1: TMemo;
    milimpar: TMenuItem;
    PageControl1: TPageControl;
    PopupMenu1: TPopupMenu;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    tsSobre: TTabSheet;
    procedure btCalibraClick(Sender: TObject);
    procedure btsalvarClick(Sender: TObject);
    procedure btTaraClick(Sender: TObject);
    procedure edCalibracaoChange(Sender: TObject);
    procedure edPortaChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure indLed1Click(Sender: TObject);
    procedure LazSerial1RxData(Sender: TObject);
    procedure LazSerial1Status(Sender: TObject; Reason: THookSerialReason;
      const Value: string);
    procedure milimparClick(Sender: TObject);
    procedure misalvarClick(Sender: TObject);
  private
    FSerialBuffer: string;
    FSetMain: TSetMain;

    // valores numericos em uso (espelham os edits)
    FTara: Double;
    FCalibracao: Double;  // contagens por grama
    FPesoCal: Double;     // gramas do peso de referencia

    FInicioTick: QWord;
    FAmostras: array of TAmostra;
    FNumAmostras: Integer;
    FMiSalvar: TMenuItem;

    procedure AtualizaParametros;
    procedure GravaConfig;
    procedure ProcessaLinha(const ALinha: string);
    procedure RegistraAmostra(AContagem: Int64);
    procedure CriaLinha;
    procedure LimpaMedidas;
    procedure LimpaBufferSerial;
  public
    peso: Double;        // gf
    forca: Double;       // N
    referencia: Int64;   // ultima contagem recebida
    LineSeries: TLineSeries;
  end;

var
  frmmain: Tfrmmain;

const
  Versao = '1.5';
  GRAVIDADE = 9.80665;        // m/s^2 (gravidade padrao)
  MAX_PONTOS_GRAFICO = 6000;  // ~10 min a 10 leituras/s
  MAX_BUFFER_SERIAL = 4096;

// Converte texto em numero aceitando "," ou "." como separador decimal.
function TextoParaFloat(const S: string; Padrao: Double): Double;
// Formata sempre com "." (independente do idioma do Windows).
function FloatParaTexto(V: Double; const Formato: string = '0.####'): string;

implementation

{$R *.lfm}

var
  FmtPonto: TFormatSettings;

function TextoParaFloat(const S: string; Padrao: Double): Double;
var
  t: string;
begin
  t := StringReplace(Trim(S), ',', '.', [rfReplaceAll]);
  if not TryStrToFloat(t, Result, FmtPonto) then
    Result := Padrao;
end;

function FloatParaTexto(V: Double; const Formato: string): string;
begin
  Result := FormatFloat(Formato, V, FmtPonto);
end;

{ Tfrmmain }

procedure Tfrmmain.LimpaBufferSerial;
begin
  FSerialBuffer := '';
end;

procedure Tfrmmain.AtualizaParametros;
begin
  FTara := TextoParaFloat(edTara.Text, 0);
  FCalibracao := TextoParaFloat(edCalibracao.Text, 0);
  FPesoCal := TextoParaFloat(edPesoCal.Text, 0);
end;

procedure Tfrmmain.GravaConfig;
begin
  if not Assigned(FSetMain) then Exit;

  FSetMain.Comport := Trim(edPorta.Text);
  FSetMain.TaraStr := edTara.Text;
  FSetMain.CalibracaoStr := edCalibracao.Text;
  FSetMain.PesoCalStr := edPesoCal.Text;
  FSetMain.posx := Left;
  FSetMain.posy := Top;
  FSetMain.Width := Width;
  FSetMain.Height := Height;
  FSetMain.SalvaContexto(False);
end;

procedure Tfrmmain.CriaLinha;
begin
  Chart1.ClearSeries;

  LineSeries := TLineSeries.Create(Chart1);
  Chart1.AddSeries(LineSeries);

  LineSeries.Title := 'Força aplicada';
  LineSeries.ShowPoints := False;
  LineSeries.LinePen.Width := 2;

  Chart1.Legend.Visible := True;

  Chart1.BottomAxis.Title.Caption := 'Tempo (s)';
  Chart1.LeftAxis.Title.Caption := 'Força (N)';
  Chart1.BottomAxis.Title.Visible := True;
  Chart1.LeftAxis.Title.Visible := True;
  Chart1.BottomAxis.Title.Alignment := taCenter;
  Chart1.LeftAxis.Title.Alignment := taCenter;
end;

procedure Tfrmmain.LimpaMedidas;
begin
  FNumAmostras := 0;
  SetLength(FAmostras, 0);
  FInicioTick := GetTickCount64;
  if Assigned(LineSeries) then
    LineSeries.Clear;
end;

procedure Tfrmmain.indLed1Click(Sender: TObject);
begin
  if LazSerial1.Active then
  begin
    LazSerial1.Close;
    LimpaBufferSerial;
    Exit;
  end;

  LazSerial1.Device := Trim(edPorta.Text);
  LimpaBufferSerial;
  try
    LazSerial1.Open;
  except
    on E: Exception do
    begin
      MessageDlg('Não foi possível abrir a porta ' + LazSerial1.Device + '.' +
        LineEnding + E.Message + LineEnding + LineEnding +
        'Verifique se o dinamômetro está pareado via Bluetooth e se a porta está correta ' +
        '(aba Configuração).', mtError, [mbOK], 0);
      Exit;
    end;
  end;

  if not LazSerial1.Active then
  begin
    MessageDlg('Não foi possível abrir a porta ' + LazSerial1.Device + '.',
      mtError, [mbOK], 0);
    Exit;
  end;

  AtualizaParametros;
  if not Assigned(LineSeries) then
    CriaLinha;
  LimpaMedidas;
end;

procedure Tfrmmain.btTaraClick(Sender: TObject);
begin
  // A tara passa a ser a leitura atual (sem carga). A calibração é preservada.
  edTara.Text := IntToStr(referencia);
  AtualizaParametros;
end;

procedure Tfrmmain.btCalibraClick(Sender: TObject);
var
  fator: Double;
begin
  AtualizaParametros;
  if FPesoCal <= 0 then
  begin
    MessageDlg('Informe o peso de calibração (em gramas) na aba Configuração.',
      mtWarning, [mbOK], 0);
    Exit;
  end;

  fator := (referencia - FTara) / FPesoCal;
  if Abs(fator) < 1E-6 then
  begin
    MessageDlg('Leitura igual à tara. Pendure o peso de referência (' +
      FloatParaTexto(FPesoCal, '0.##') + ' g) e clique em Calibra novamente.',
      mtWarning, [mbOK], 0);
    Exit;
  end;

  edCalibracao.Text := FloatParaTexto(fator, '0.######');
  AtualizaParametros;
end;

procedure Tfrmmain.btsalvarClick(Sender: TObject);
begin
  AtualizaParametros;
  try
    GravaConfig;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure Tfrmmain.edCalibracaoChange(Sender: TObject);
begin
  AtualizaParametros;
end;

procedure Tfrmmain.edPortaChange(Sender: TObject);
begin
  // a porta é aplicada ao conectar
end;

procedure Tfrmmain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if LazSerial1.Active then
    LazSerial1.Close;
end;

procedure Tfrmmain.FormCreate(Sender: TObject);
begin
  FSerialBuffer := '';
  lbversao.Caption := Versao;

  FSetMain := TSetMain.Create;
  edPorta.Text := FSetMain.Comport;
  edTara.Text := FSetMain.TaraStr;
  edCalibracao.Text := FSetMain.CalibracaoStr;
  edPesoCal.Text := FSetMain.PesoCalStr;
  AtualizaParametros;

  // Rótulos coerentes com as unidades exibidas
  Label2.Caption := 'Força (N):';
  Label11.Caption := 'Massa equivalente (kg):';
  indGnouMeter1.Caption := 'Força gf';

  Memo1.Lines.Text :=
    'O sistema lê a porta serial criada pelo Bluetooth (ou pela USB).' + LineEnding +
    '' + LineEnding +
    'Porta - porta serial do dispositivo pareado (ex.: COM5).' + LineEnding +
    'Tara - leitura sem carga (botão Tara, na aba Informação).' + LineEnding +
    'Valor de Calibração - contagens do sensor por grama.' + LineEnding +
    'Peso de Calibração - massa de referência, em gramas.' + LineEnding +
    '' + LineEnding +
    'Como calibrar:' + LineEnding +
    '1) Conecte e deixe o dinamômetro sem carga; clique em Tara.' + LineEnding +
    '2) Pendure o peso de referência e clique em Calibra.' + LineEnding +
    '3) Clique em Salvar.' + LineEnding +
    '' + LineEnding +
    'Força (N) = massa (kg) x 9,80665 m/s².' + LineEnding +
    'No gráfico, clique com o botão direito para limpar ou exportar CSV.';

  // Item "Exportar CSV..." no menu do gráfico
  FMiSalvar := TMenuItem.Create(PopupMenu1);
  FMiSalvar.Caption := 'Exportar CSV...';
  FMiSalvar.OnClick := @misalvarClick;
  PopupMenu1.Items.Add(FMiSalvar);

  CriaLinha;
  LimpaMedidas;
end;

procedure Tfrmmain.FormDestroy(Sender: TObject);
begin
  if LazSerial1.Active then
    LazSerial1.Close;

  if Assigned(FSetMain) then
  begin
    try
      GravaConfig;
    except
      // não impede o fechamento do programa
    end;
    FreeAndNil(FSetMain);
  end;

  LimpaBufferSerial;
end;

procedure Tfrmmain.FormShow(Sender: TObject);
begin
  PageControl1.ActivePage := tsSobre;
end;

procedure Tfrmmain.RegistraAmostra(AContagem: Int64);
var
  a: TAmostra;
begin
  referencia := AContagem;

  if FCalibracao <> 0 then
    peso := (AContagem - FTara) / FCalibracao   // gramas
  else
    peso := AContagem - FTara;                  // sem calibração: contagens brutas

  forca := (peso / 1000.0) * GRAVIDADE;

  a.Tempo := (GetTickCount64 - FInicioTick) / 1000.0;
  a.Contagem := AContagem;
  a.Gramas := peso;
  a.Newtons := forca;

  if FNumAmostras >= Length(FAmostras) then
    SetLength(FAmostras, Max(256, Length(FAmostras) * 2));
  FAmostras[FNumAmostras] := a;
  Inc(FNumAmostras);

  // ======= EXIBIÇÃO =======
  LedForca.Caption := FloatParaTexto(forca, '0.00');
  ledPeso.Caption := FloatParaTexto(peso / 1000.0, '0.000');

  indGnouMeter1.Value := Round(peso);
  A3nalogGauge1.Position := Round(peso);

  // ======= GRÁFICO: força (N) x tempo (s) =======
  if Assigned(LineSeries) then
  begin
    LineSeries.AddXY(a.Tempo, forca);
    while LineSeries.Count > MAX_PONTOS_GRAFICO do
      LineSeries.Delete(0);
  end;
end;

procedure Tfrmmain.ProcessaLinha(const ALinha: string);
var
  linha, numStr: string;
  posPeso: Integer;
  valor: Int64;
begin
  linha := Trim(ALinha);
  if (linha = '') or (linha[1] = '#') then
    Exit; // mensagens informativas do firmware

  posPeso := Pos('Peso:', linha);
  if posPeso <= 0 then
    Exit;

  numStr := Trim(Copy(linha, posPeso + 5, MaxInt));
  if TryStrToInt64(numStr, valor) then
    RegistraAmostra(valor);
end;

procedure Tfrmmain.LazSerial1RxData(Sender: TObject);
var
  s, linha: string;
  p: Integer;
begin
  if not LazSerial1.DataAvailable then
    Exit;

  s := LazSerial1.ReadData;
  if s = '' then
    Exit;

  FSerialBuffer := FSerialBuffer + s;

  // Processa TODAS as linhas completas que chegaram (evita atraso acumulado)
  p := Pos(#10, FSerialBuffer);
  while p > 0 do
  begin
    linha := Copy(FSerialBuffer, 1, p - 1);
    Delete(FSerialBuffer, 1, p);
    ProcessaLinha(StringReplace(linha, #13, '', [rfReplaceAll]));
    p := Pos(#10, FSerialBuffer);
  end;

  // Lixo sem quebra de linha (baud errado, porta errada): descarta
  if Length(FSerialBuffer) > MAX_BUFFER_SERIAL then
    LimpaBufferSerial;
end;

procedure Tfrmmain.LazSerial1Status(Sender: TObject; Reason: THookSerialReason;
  const Value: string);
begin
  if Reason = HR_Connect then
    indLed1.LedValue := True;

  if Reason = HR_SerialClose then
  begin
    indLed1.LedValue := False;
    LimpaBufferSerial;
  end;
end;

procedure Tfrmmain.milimparClick(Sender: TObject);
begin
  LimpaMedidas;
end;

procedure Tfrmmain.misalvarClick(Sender: TObject);
var
  dlg: TSaveDialog;
  sl: TStringList;
  i: Integer;
begin
  if FNumAmostras = 0 then
  begin
    MessageDlg('Não há medidas para exportar.', mtInformation, [mbOK], 0);
    Exit;
  end;

  dlg := TSaveDialog.Create(nil);
  sl := TStringList.Create;
  try
    dlg.Title := 'Exportar medidas';
    dlg.Filter := 'CSV (*.csv)|*.csv';
    dlg.DefaultExt := 'csv';
    dlg.FileName := 'dinamometro_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.csv';
    dlg.Options := dlg.Options + [ofOverwritePrompt];
    if not dlg.Execute then
      Exit;

    // separador ";" e vírgula decimal: abre direto no Excel/LibreOffice em pt-BR
    sl.Add('tempo_s;contagem;massa_g;forca_N');
    for i := 0 to FNumAmostras - 1 do
      with FAmostras[i] do
        sl.Add(StringReplace(FloatParaTexto(Tempo, '0.000'), '.', ',', []) + ';' +
               IntToStr(Contagem) + ';' +
               StringReplace(FloatParaTexto(Gramas, '0.00'), '.', ',', []) + ';' +
               StringReplace(FloatParaTexto(Newtons, '0.0000'), '.', ',', []));
    try
      sl.SaveToFile(dlg.FileName);
    except
      on E: Exception do
        MessageDlg('Erro ao salvar: ' + E.Message, mtError, [mbOK], 0);
    end;
  finally
    sl.Free;
    dlg.Free;
  end;
end;

initialization
  FmtPonto := DefaultFormatSettings;
  FmtPonto.DecimalSeparator := '.';
  FmtPonto.ThousandSeparator := #0;

end.
