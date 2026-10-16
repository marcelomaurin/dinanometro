unit main;

{ objfpc}{+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, Menus, TAGraph, indSliders, LedNumber, indGnouMeter, indLCDDisplay,
  A3nalogGauge, IndLed, LazSerial, LazSynaSer, TATypes, TASeries, TACustomSeries,
  TADrawUtils, TAChartUtils, setmain;

type

  { Tfrmmain }

  Tfrmmain = class(TForm)
    // Cabecalho e Navegacao Superior (Padrao Maurinsoft)
    pnHeader: TPanel;
    lblAppTitle: TLabel;
    lblAppSubtitle: TLabel;
    pnlNavButtons: TPanel;
    btnNavStep1: TButton;
    btnNavStep2: TButton;
    btnNavStep3: TButton;
    btnNavStep4: TButton;

    // Componentes de Medicao
    A3nalogGauge1: TA3nalogGauge;
    indGnouMeter1: TindGnouMeter;
    LedForca: TLEDNumber;
    ledPeso: TLEDNumber;
    Label2: TLabel;
    Label11: TLabel;
    pnlControlCard: TPanel;
    lblCtrlTitle: TLabel;
    Label10: TLabel;
    lblDicaMed: TLabel;
    indLed1: TindLed;
    btTara: TButton;
    btCalibra: TButton;

    // Componentes de Grafico
    Chart1: TChart;
    PopupMenu1: TPopupMenu;
    milimpar: TMenuItem;

    // Componentes de Configuracao
    pnlConfigLeft: TPanel;
    lblParamTitle: TLabel;
    Label1: TLabel;
    edPorta: TEdit;
    Label3: TLabel;
    edTara: TEdit;
    Label4: TLabel;
    edCalibracao: TEdit;
    Label5: TLabel;
    edPesoCal: TEdit;
    btsalvar: TButton;
    pnlConfigRight: TPanel;
    lblInstTitle: TLabel;
    Memo1: TMemo;

    // Componentes Sobre
    pnlAboutCard: TPanel;
    Image1: TImage;
    Label7: TLabel;
    Label6: TLabel;
    lblFatInst: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    pnlVersaoBox: TPanel;
    Label12: TLabel;
    lbversao: TLabel;

    // Controle de Abas e Comunicacao
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    tsSobre: TTabSheet;
    LazSerial1: TLazSerial;

    procedure btnNavStepClick(Sender: TObject);
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
    // ====== BUFFER SERIAL ======
    FSerialBuffer: string;

    // ====== CONFIG/SETTINGS ======
    FSetMain: TSetMain;

    function GramasParaNewtons(pesoGramas: longint): longint;
    function GramasParaKgf(pesoGramas: Int64): Double;

    procedure GeraLinhaKgf(valorKgf: Double);
    procedure CriaLinha();
    procedure ResetPeso();
    procedure LimpaBufferSerial;
  public
    peso: longint;
    forca: longint;
    referencia: LongInt;
    LineSeries: TLineSeries;
  end;

var
  frmmain: Tfrmmain;

Const
  Versao = '2.0';

implementation

{ *.lfm}

{ Tfrmmain }

procedure Tfrmmain.btnNavStepClick(Sender: TObject);
begin
  if Sender = btnNavStep1 then
    PageControl1.ActivePage := TabSheet1
  else if Sender = btnNavStep2 then
    PageControl1.ActivePage := TabSheet3
  else if Sender = btnNavStep3 then
    PageControl1.ActivePage := TabSheet2
  else if Sender = btnNavStep4 then
    PageControl1.ActivePage := tsSobre;
end;

procedure Tfrmmain.LimpaBufferSerial;
begin
  FSerialBuffer := '';
end;

function Tfrmmain.GramasParaKgf(pesoGramas: Int64): Double;
begin
  // 1 kgf = 1 kg sob gravidade padrao -> em kgf numericamente e kg
  // gramas -> kg = /1000
  Result := pesoGramas / 1000.0;
end;

procedure Tfrmmain.GeraLinhaKgf(valorKgf: Double);
var
  rotuloX: string;
begin
  if not Assigned(LineSeries) then Exit;

  // X = leitura (1,2,3...) como rotulo
  rotuloX := IntToStr(LineSeries.Count + 1);

  // Adiciona ponto: Y = kgf, rotulo = numero da leitura
  LineSeries.Add(valorKgf, rotuloX);
end;

procedure Tfrmmain.CriaLinha;
begin
  Chart1.ClearSeries;

  LineSeries := TLineSeries.Create(Chart1);
  Chart1.AddSeries(LineSeries);

  LineSeries.Title := 'Forca aplicada (kgf)';
  LineSeries.ShowPoints := True;
  LineSeries.LinePen.Width := 2;

  Chart1.Legend.Visible := True;

  // ======= EIXOS =======
  Chart1.BottomAxis.Title.Caption := 'Amostra / Leitura';
  Chart1.LeftAxis.Title.Caption := 'Forca (kgf)';

  Chart1.BottomAxis.Title.Alignment := taCenter;
  Chart1.LeftAxis.Title.Alignment := taCenter;
end;

procedure Tfrmmain.ResetPeso();
begin
  edTara.Text := '0';
  edCalibracao.Text := '0';
end;

function Tfrmmain.GramasParaNewtons(pesoGramas: longint): longint;
const
  g = 9.81;
begin
  // F = (m_g / 1000) * g
  Result := Trunc(((pesoGramas) / 1000.0) * g);
end;

procedure Tfrmmain.indLed1Click(Sender: TObject);
begin
  LazSerial1.Device := edPorta.Text;

  if LazSerial1.Active then
  begin
    LazSerial1.Close;
    LimpaBufferSerial;
  end
  else
  begin
    LazSerial1.Open;
    LimpaBufferSerial;
    CriaLinha;
  end;
end;

procedure Tfrmmain.btTaraClick(Sender: TObject);
begin
  ResetPeso();
  edTara.Text := IntToStr(referencia);
end;

procedure Tfrmmain.btCalibraClick(Sender: TObject);
var
  fator: longint;
begin
  if StrToIntDef(edPesoCal.Text, 0) = 0 then Exit;

  fator := Trunc((referencia - StrToIntDef(edTara.Text, 0)) / StrToIntDef(edPesoCal.Text, 1));
  edCalibracao.Text := IntToStr(fator);
end;

procedure Tfrmmain.btsalvarClick(Sender: TObject);
begin
  if Assigned(FSetMain) then
  begin
    FSetMain.Comport := edPorta.Text;
    FSetMain.TaraStr := Trim(edTara.Text);
    FSetMain.CalibracaoStr := Trim(edCalibracao.Text);
    FSetMain.PesoCalStr := Trim(edPesoCal.Text);
    FSetMain.SalvaContexto(False);
    ShowMessage('Configuracoes gravadas com sucesso!');
  end;
end;

procedure Tfrmmain.edCalibracaoChange(Sender: TObject);
begin
  // (vazio)
end;

procedure Tfrmmain.edPortaChange(Sender: TObject);
begin
  // (vazio)
end;

procedure Tfrmmain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if (LazSerial1.Active) then
  begin
    LazSerial1.Close;
  end;
end;

procedure Tfrmmain.FormCreate(Sender: TObject);
begin
  FSerialBuffer := '';
  lbversao.Caption := Versao;

  FSetMain := TSetMain.Create;
  FSetMain.CarregaContexto;

  edPorta.Text := FSetMain.Comport;
  edTara.Text := FSetMain.TaraStr;
  edCalibracao.Text := FSetMain.CalibracaoStr;
  edPesoCal.Text := FSetMain.PesoCalStr;
end;

procedure Tfrmmain.FormDestroy(Sender: TObject);
begin
  try
    ActiveControl := nil;
  except
  end;
  Application.ProcessMessages;

  if Assigned(FSetMain) then
  begin
    FSetMain.Comport := edPorta.Text;
    FSetMain.TaraStr := Trim(edTara.Text);
    FSetMain.CalibracaoStr := Trim(edCalibracao.Text);
    FSetMain.PesoCalStr := Trim(edPesoCal.Text);
    FSetMain.SalvaContexto(False);
    FreeAndNil(FSetMain);
  end;

  if LazSerial1.Active then
    LazSerial1.Close;

  LimpaBufferSerial;
end;

procedure Tfrmmain.FormShow(Sender: TObject);
begin
  PageControl1.ActivePage := TabSheet1;
end;

procedure Tfrmmain.LazSerial1RxData(Sender: TObject);
var
  s, linha, numStr: string;
  p, posPeso: Integer;
  vPesoLido: Integer;
  kgf: Double;
begin
  if not LazSerial1.DataAvailable then
    Exit;

  s := LazSerial1.ReadData;
  if s = '' then
    Exit;

  FSerialBuffer := FSerialBuffer + s;

  // so processa quando tiver LF (#10)
  p := Pos(#10, FSerialBuffer);
  if p = 0 then
    Exit;

  linha := Copy(FSerialBuffer, 1, p - 1);

  // remove CR se vier CRLF
  if (linha <> '') and (linha[Length(linha)] = #13) then
    Delete(linha, Length(linha), 1);

  // remove do buffer ate o LF (inclusive)
  Delete(FSerialBuffer, 1, p);

  linha := Trim(linha);
  if linha = '' then
    Exit;

  posPeso := Pos('Peso:', linha);
  if posPeso <= 0 then
    Exit;

  numStr := Trim(Copy(linha, posPeso + 5, MaxInt));
  if numStr = '' then
    Exit;

  if not TryStrToInt(numStr, vPesoLido) then
    Exit;

  referencia := vPesoLido;

  if StrToIntDef(edCalibracao.Text, 0) <> 0 then
    peso := Trunc((referencia - StrToIntDef(edTara.Text, 0)) / StrToIntDef(edCalibracao.Text, 1))
  else
    peso := (referencia - StrToIntDef(edTara.Text, 0));

  // ======= EXIBICAO =======
  kgf := GramasParaKgf(peso);

  LedForca.Caption := FormatFloat('0.###', kgf); // kgf
  ledPeso.Caption := IntToStr(peso div 1000);   // kg (inteiro)

  indGnouMeter1.Value := peso;
  A3nalogGauge1.Position := peso;

  // ======= GRAFICO: Y em kgf, X em leitura =======
  GeraLinhaKgf(kgf);

  Application.ProcessMessages;
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
  if Assigned(LineSeries) then
    LineSeries.Clear;
end;

procedure Tfrmmain.misalvarClick(Sender: TObject);
begin
  // (vazio)
end;

end.
