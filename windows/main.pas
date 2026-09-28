unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, Menus, TAGraph, indSliders, LedNumber, indGnouMeter, indLCDDisplay,
  A3nalogGauge, IndLed, LazSerial, LazSynaSer, TATypes, TASeries, TACustomSeries,
  TADrawUtils, TAChartUtils, setmain, protocolo;

type

  TAmostra = record
    TempoS: Double;
    Bruto: Int64;
    ForcaN: Double;
  end;

  { Tfrmmain }

  Tfrmmain = class(TForm)
    A3nalogGauge1: TA3nalogGauge;
    btTara: TButton;
    btCalibra: TButton;
    btsalvar: TButton;
    Chart1: TChart;
    edMedia: TEdit;
    edPesoCal: TEdit;
    edPorta: TComboBox;
    edTara: TEdit;
    edCalibracao: TEdit;
    Image1: TImage;
    indGnouMeter1: TindGnouMeter;
    indLed1: TindLed;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    lbPico: TLabel;
    lbStatus: TLabel;
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
    misalvar: TMenuItem;
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
    procedure edPortaDropDown(Sender: TObject);
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

    // Calibracao: gramas = (bruto - FTara) / FFator
    FTara: Double;           // contagens do ADC sem carga
    FFator: Double;          // contagens por grama (0 = nao calibrado)
    FPesoCal: Double;        // gramas
    FAtualizandoEdits: Boolean;
    FPrecisaTara: Boolean;   // cfg da versao 1: tara antiga nao vale mais

    FJanelaBruto: TJanelaMedia;   // ultimas leituras brutas (tara/calibracao)
    FSuavizacao: TJanelaMedia;    // media movel da forca exibida

    // Base de tempo do grafico
    FT0Ms: Int64;            // tempo do firmware da primeira amostra
    FUltimoMs: Int64;
    FUltimoTempoS: Double;
    FT0Tick: QWord;          // para firmware 1.x (sem tempo)

    FDados: array of TAmostra;
    FNumDados: Integer;
    FPicoN: Double;
    FUltimaForcaN: Double;

    procedure CriaLinha;
    procedure ReiniciaMedicao;
    procedure LimpaBufferSerial;
    procedure AtualizaListaPortas;
    procedure LeParametrosDosEdits;
    procedure EscreveParametrosNosEdits;
    procedure SalvaConfiguracao;
    procedure ProcessaAmostra(ATempoS: Double; ABruto: Int64);
    procedure AtualizaMostradores;
    procedure MostraStatus(const ATexto: string; AAlerta: Boolean);
    function ExigeLeituras: Boolean;
  public
    LineSeries: TLineSeries;
    procedure ExportaCSV(const AArquivo: string);
  end;

var
  frmmain: Tfrmmain;

Const
  Versao = '2.0';

  // Amostras usadas na media da tara e da calibracao
  // (2 s a 10 SPS, 0,25 s a 80 SPS)
  AMOSTRAS_TARA = 20;

implementation

{$R *.lfm}

{ Tfrmmain }

procedure Tfrmmain.LimpaBufferSerial;
begin
  FSerialBuffer := '';
end;

procedure Tfrmmain.MostraStatus(const ATexto: string; AAlerta: Boolean);
begin
  lbStatus.Caption := ATexto;
  if AAlerta then
    lbStatus.Font.Color := clRed
  else
    lbStatus.Font.Color := clDefault;
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

procedure Tfrmmain.ReiniciaMedicao;
begin
  FT0Ms := -1;
  FUltimoMs := -1;
  FUltimoTempoS := 0;
  FT0Tick := 0;
  FNumDados := 0;
  SetLength(FDados, 0);
  FPicoN := 0;
  FSuavizacao.Limpa;
  if Assigned(LineSeries) then
    LineSeries.Clear;
  lbPico.Caption := 'Pico: ' + FormatFloat('0.00', 0) + ' N';
end;

procedure Tfrmmain.AtualizaListaPortas;
var
  portas: TStringList;
  atual: string;
begin
  atual := edPorta.Text;
  portas := TStringList.Create;
  try
    portas.CommaText := GetSerialPortNames;
    portas.Sort;
    edPorta.Items.Assign(portas);
  finally
    portas.Free;
  end;
  edPorta.Text := atual;
end;

procedure Tfrmmain.LeParametrosDosEdits;
var
  n: Integer;
begin
  FTara := StrToFloatFlex(edTara.Text, 0);
  FFator := StrToFloatFlex(edCalibracao.Text, 0);
  FPesoCal := StrToFloatFlex(edPesoCal.Text, 0);

  n := StrToIntDef(Trim(edMedia.Text), 1);
  if n < 1 then n := 1;
  if n > 200 then n := 200;
  if n <> FSuavizacao.Capacidade then
    FSuavizacao.Capacidade := n;
end;

procedure Tfrmmain.EscreveParametrosNosEdits;
begin
  FAtualizandoEdits := True;
  try
    edTara.Text := FloatToStrPonto(FTara, 1);
    edCalibracao.Text := FloatToStrPonto(FFator, 4);
  finally
    FAtualizandoEdits := False;
  end;
end;

procedure Tfrmmain.SalvaConfiguracao;
begin
  if not Assigned(FSetMain) then Exit;

  FSetMain.Comport := Trim(edPorta.Text);
  FSetMain.TaraStr := Trim(edTara.Text);
  FSetMain.CalibracaoStr := Trim(edCalibracao.Text);
  FSetMain.PesoCalStr := Trim(edPesoCal.Text);
  FSetMain.MediaStr := Trim(edMedia.Text);
  FSetMain.SalvaContexto(False);
end;

function Tfrmmain.ExigeLeituras: Boolean;
begin
  Result := FJanelaBruto.Count >= 3;
  if not Result then
    ShowMessage('Sem leituras do equipamento. Conecte o dinamômetro ' +
      'e aguarde alguns segundos antes de fazer a tara ou a calibração.');
end;

procedure Tfrmmain.indLed1Click(Sender: TObject);
begin
  if LazSerial1.Active then
  begin
    LazSerial1.Close;
    LimpaBufferSerial;
    MostraStatus('Desconectado', False);
    Exit;
  end;

  LazSerial1.Device := Trim(edPorta.Text);
  LimpaBufferSerial;
  try
    LazSerial1.Open;
  except
    on E: Exception do
    begin
      MostraStatus('Falha ao abrir ' + LazSerial1.Device + ': ' + E.Message, True);
      Exit;
    end;
  end;

  if not LazSerial1.Active then
  begin
    MostraStatus('Não foi possível abrir ' + LazSerial1.Device, True);
    Exit;
  end;

  FJanelaBruto.Limpa;
  CriaLinha;
  ReiniciaMedicao;
  MostraStatus('Conectado em ' + LazSerial1.Device, False);
  if FFator = 0 then
    MostraStatus('Conectado - equipamento ainda NÃO calibrado', True);

  // Garante que o firmware 2.0 esteja enviando (1.x ignora)
  LazSerial1.WriteData('START'#10);
end;

procedure Tfrmmain.btTaraClick(Sender: TObject);
begin
  if not ExigeLeituras then Exit;

  FTara := FJanelaBruto.Media;
  EscreveParametrosNosEdits;
  FSuavizacao.Limpa;
  FPicoN := 0;
  FPrecisaTara := False;
  lbPico.Caption := 'Pico: ' + FormatFloat('0.00', 0) + ' N';
  MostraStatus(Format('Tara feita com a média de %d leituras', [FJanelaBruto.Count]), False);
end;

procedure Tfrmmain.btCalibraClick(Sender: TObject);
var
  diferenca: Double;
begin
  LeParametrosDosEdits;

  if FPesoCal <= 0 then
  begin
    ShowMessage('Informe o peso de calibração (em gramas) na aba Configuração.');
    Exit;
  end;
  if not ExigeLeituras then Exit;

  diferenca := FJanelaBruto.Media - FTara;
  if Abs(diferenca) < 10 then
  begin
    ShowMessage('A leitura está praticamente igual à tara. Faça a tara sem ' +
      'carga, pendure o peso de calibração e clique em Calibra de novo.');
    Exit;
  end;

  FFator := diferenca / FPesoCal;
  EscreveParametrosNosEdits;
  FSuavizacao.Limpa;
  MostraStatus(Format('Calibrado: %.4f contagens/g (peso %.0f g)', [FFator, FPesoCal]), False);
  ShowMessage(Format('Calibração concluída.' + LineEnding +
    'Fator: %.4f contagens por grama.' + LineEnding +
    'Clique em Salvar na aba Configuração para guardar.', [FFator]));
end;

procedure Tfrmmain.btsalvarClick(Sender: TObject);
begin
  LeParametrosDosEdits;
  SalvaConfiguracao;
  MostraStatus('Configuração salva', False);
end;

procedure Tfrmmain.edCalibracaoChange(Sender: TObject);
begin
  // Tara, fator, peso de calibração e média digitados à mão
  if FAtualizandoEdits then Exit;
  if Assigned(FSuavizacao) then
    LeParametrosDosEdits;
end;

procedure Tfrmmain.edPortaChange(Sender: TObject);
begin
  // (vazio)
end;

procedure Tfrmmain.edPortaDropDown(Sender: TObject);
begin
  AtualizaListaPortas;
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

  FJanelaBruto := TJanelaMedia.Create(AMOSTRAS_TARA);
  FSuavizacao := TJanelaMedia.Create(1);

  FSetMain := TSetMain.Create;

  FAtualizandoEdits := True;
  try
    edPorta.Text := FSetMain.Comport;
    edTara.Text := FSetMain.TaraStr;
    edCalibracao.Text := FSetMain.CalibracaoStr;
    edPesoCal.Text := FSetMain.PesoCalStr;
    edMedia.Text := FSetMain.MediaStr;
  finally
    FAtualizandoEdits := False;
  end;
  LeParametrosDosEdits;

  AtualizaListaPortas;
  CriaLinha;
  ReiniciaMedicao;

  FPrecisaTara := FSetMain.TaraDescartada;
  if FPrecisaTara then
    MostraStatus('Configuração da versão anterior: faça a tara de novo', True)
  else
    MostraStatus('Desconectado', False);
end;

procedure Tfrmmain.FormDestroy(Sender: TObject);
begin
  if LazSerial1.Active then
    LazSerial1.Close;

  if Assigned(FSetMain) then
  begin
    SalvaConfiguracao;
    FreeAndNil(FSetMain);
  end;

  FreeAndNil(FJanelaBruto);
  FreeAndNil(FSuavizacao);
  LimpaBufferSerial;
end;

procedure Tfrmmain.FormShow(Sender: TObject);
begin
  PageControl1.ActivePage := tsSobre;
end;

procedure Tfrmmain.ProcessaAmostra(ATempoS: Double; ABruto: Int64);
var
  gramas, forcaN: Double;
begin
  FJanelaBruto.Adiciona(ABruto);

  gramas := BrutoParaGramas(ABruto, FTara, FFator);
  FSuavizacao.Adiciona(gramas);
  forcaN := GramasParaNewtons(FSuavizacao.Media);
  FUltimaForcaN := forcaN;

  if Abs(forcaN) > Abs(FPicoN) then
    FPicoN := forcaN;

  if FNumDados >= Length(FDados) then
    SetLength(FDados, Length(FDados) * 2 + 1024);
  FDados[FNumDados].TempoS := ATempoS;
  FDados[FNumDados].Bruto := ABruto;
  FDados[FNumDados].ForcaN := forcaN;
  Inc(FNumDados);

  if Assigned(LineSeries) then
    LineSeries.AddXY(ATempoS, forcaN);
end;

procedure Tfrmmain.AtualizaMostradores;
var
  kgf: Double;
begin
  kgf := FUltimaForcaN / G_PADRAO;

  LedForca.Caption := FormatFloat('0.00', FUltimaForcaN);   // N
  ledPeso.Caption := FormatFloat('0.000', kgf);             // kgf

  indGnouMeter1.Value := FUltimaForcaN;
  A3nalogGauge1.Position := kgf * 1000;                     // gf

  lbPico.Caption := 'Pico: ' + FormatFloat('0.00', FPicoN) + ' N';
end;

procedure Tfrmmain.LazSerial1RxData(Sender: TObject);
var
  s, linha: string;
  d: TLinhaDecodificada;
  tempoS: Double;
  houveAmostra: Boolean;
  tick: QWord;
begin
  s := LazSerial1.ReadData;
  if s = '' then Exit;

  FSerialBuffer := FSerialBuffer + s;
  houveAmostra := False;

  Chart1.DisableRedrawing;
  try
    // Processa TODAS as linhas completas que chegaram, não só a primeira
    while ExtraiLinha(FSerialBuffer, linha) do
    begin
      d := DecodificaLinha(linha);
      case d.Tipo of
        tlAmostra:
          begin
            if FT0Ms < 0 then
              FT0Ms := d.TempoMs
            else if d.TempoMs < FUltimoMs then
              // ESP32 reiniciou: continua a contagem de onde parou
              FT0Ms := d.TempoMs - Round(FUltimoTempoS * 1000);
            FUltimoMs := d.TempoMs;
            tempoS := (d.TempoMs - FT0Ms) / 1000.0;
            FUltimoTempoS := tempoS;
            ProcessaAmostra(tempoS, d.Bruto);
            houveAmostra := True;
          end;

        tlAmostraLegada:
          begin
            tick := GetTickCount64;
            if FT0Tick = 0 then FT0Tick := tick;
            tempoS := (tick - FT0Tick) / 1000.0;
            FUltimoTempoS := tempoS;
            ProcessaAmostra(tempoS, d.Bruto);
            houveAmostra := True;
          end;

        tlErro:
          if d.Texto = 'SAT' then
            MostraStatus('Célula de carga saturada ou desconectada', True)
          else if d.Texto = 'NOHX711' then
            MostraStatus('HX711 não responde - verifique a ligação', True)
          else
            MostraStatus('Erro do equipamento: ' + d.Texto, True);
      end;
    end;
  finally
    Chart1.EnableRedrawing;
  end;

  // Atualiza os mostradores uma vez por lote, não a cada linha
  if houveAmostra then
  begin
    AtualizaMostradores;
    // Um aviso de erro some quando as leituras voltam, mas os avisos de
    // tara/calibração pendentes continuam até serem resolvidos.
    if FPrecisaTara then
      MostraStatus('Faça a tara (sem carga) antes de medir', True)
    else if FFator = 0 then
      MostraStatus('Equipamento ainda NÃO calibrado', True)
    else if lbStatus.Font.Color = clRed then
      MostraStatus('Recebendo leituras', False);
  end;
end;

procedure Tfrmmain.LazSerial1Status(Sender: TObject; Reason: THookSerialReason;
  const Value: string);
begin
  if (Reason = HR_Connect) then
    indLed1.LedValue := True;

  if (Reason = HR_SerialClose) then
  begin
    indLed1.LedValue := False;
    LimpaBufferSerial;
  end;
end;

procedure Tfrmmain.milimparClick(Sender: TObject);
begin
  ReiniciaMedicao;
end;

procedure Tfrmmain.ExportaCSV(const AArquivo: string);
var
  sl: TStringList;
  fmt: TFormatSettings;
  i: Integer;
begin
  // Formato brasileiro: ponto e vírgula entre colunas, vírgula decimal
  // (abre direto no Excel e no LibreOffice em português).
  fmt := DefaultFormatSettings;
  fmt.DecimalSeparator := ',';
  fmt.ThousandSeparator := #0;

  sl := TStringList.Create;
  try
    sl.Add('tempo_s;bruto;forca_N;forca_kgf');
    for i := 0 to FNumDados - 1 do
      sl.Add(FloatToStrF(FDados[i].TempoS, ffFixed, 12, 3, fmt) + ';' +
             IntToStr(FDados[i].Bruto) + ';' +
             FloatToStrF(FDados[i].ForcaN, ffFixed, 12, 4, fmt) + ';' +
             FloatToStrF(FDados[i].ForcaN / G_PADRAO, ffFixed, 12, 5, fmt));
    sl.SaveToFile(AArquivo);
  finally
    sl.Free;
  end;
end;

procedure Tfrmmain.misalvarClick(Sender: TObject);
var
  dlg: TSaveDialog;
begin
  if FNumDados = 0 then
  begin
    ShowMessage('Não há leituras para exportar.');
    Exit;
  end;

  dlg := TSaveDialog.Create(Self);
  try
    dlg.Title := 'Exportar leituras';
    dlg.Filter := 'Planilha CSV (*.csv)|*.csv';
    dlg.DefaultExt := 'csv';
    dlg.FileName := 'dinamometro_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.csv';
    dlg.Options := dlg.Options + [ofOverwritePrompt];
    if not dlg.Execute then Exit;

    try
      ExportaCSV(dlg.FileName);
      MostraStatus(Format('%d leituras exportadas', [FNumDados]), False);
    except
      on E: Exception do
        ShowMessage('Não foi possível salvar o arquivo: ' + E.Message);
    end;
  finally
    dlg.Free;
  end;
end;

end.
