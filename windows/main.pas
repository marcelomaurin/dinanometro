unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, Menus, TAGraph, indSliders, LedNumber, indGnouMeter, indLCDDisplay,
  A3nalogGauge, IndLed, LazSerial, LazSynaSer, TATypes, TASeries, TACustomSeries,
  TADrawUtils, TAChartUtils, setmain;

type

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
  Versao = '1.4';

implementation

{$R *.lfm}

{ Tfrmmain }

procedure Tfrmmain.LimpaBufferSerial;
begin
  FSerialBuffer := '';
end;

function Tfrmmain.GramasParaKgf(pesoGramas: Int64): Double;
begin
  // 1 kgf = 1 kg sob gravidade padrão -> em "kgf" numericamente é kg
  // gramas -> kg = /1000
  Result := pesoGramas / 1000.0;
end;

procedure Tfrmmain.GeraLinhaKgf(valorKgf: Double);
var
  rotuloX: string;
begin
  if not Assigned(LineSeries) then Exit;

  // X = leitura (1,2,3...) como rótulo
  rotuloX := IntToStr(LineSeries.Count + 1);

  // Adiciona ponto: Y = kgf, rótulo = número da leitura
  LineSeries.Add(valorKgf, rotuloX);
end;

procedure Tfrmmain.CriaLinha;
begin
  Chart1.ClearSeries;

  LineSeries := TLineSeries.Create(Chart1);
  Chart1.AddSeries(LineSeries);

  LineSeries.Title := 'Força aplicada';
  LineSeries.ShowPoints := True;
  LineSeries.LinePen.Width := 2;

  Chart1.Legend.Visible := True;

  // ======= EIXOS =======
  Chart1.BottomAxis.Title.Caption := 'Leitura';
  Chart1.LeftAxis.Title.Caption := 'Força (kgf)';

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
  Result := Trunc((pesoGramas) * g);
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

    // GRAVA EXATAMENTE o que está nos edits (STRING)
    FSetMain.TaraStr := Trim(edTara.Text);
    FSetMain.CalibracaoStr := Trim(edCalibracao.Text);
    FSetMain.PesoCalStr := Trim(edPesoCal.Text); // <-- NOVO

    FSetMain.SalvaContexto(False);

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
  if(LazSerial1.Active)   then
  begin
    LazSerial1.close;
  end;
end;

procedure Tfrmmain.FormCreate(Sender: TObject);
begin
  FSerialBuffer := '';
  lbversao.Caption:= versao;

  FSetMain := TSetMain.Create;
  FSetMain.CarregaContexto;

  edPorta.Text := FSetMain.Comport;

  // LÊ COMO STRING (CFG)
  edTara.Text := FSetMain.TaraStr;
  edCalibracao.Text := FSetMain.CalibracaoStr;
  edPesoCal.Text := FSetMain.PesoCalStr; // <-- NOVO
end;

procedure Tfrmmain.FormDestroy(Sender: TObject);
begin
  // garante que o valor atual digitado no Edit seja gravado
  try
    ActiveControl := nil;
  except
  end;
  Application.ProcessMessages;

  if Assigned(FSetMain) then
  begin
    FSetMain.Comport := edPorta.Text;

    // GRAVA EXATAMENTE o que está nos edits (STRING)
    FSetMain.TaraStr := Trim(edTara.Text);
    FSetMain.CalibracaoStr := Trim(edCalibracao.Text);
    FSetMain.PesoCalStr := Trim(edPesoCal.Text); // <-- NOVO

    FSetMain.SalvaContexto(False);
    FreeAndNil(FSetMain);
  end;

  if LazSerial1.Active then
    LazSerial1.Close;

  LimpaBufferSerial;
end;

procedure Tfrmmain.FormShow(Sender: TObject);
begin
  PageControl1.ActivePage := tsSobre;
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

  // só processa quando tiver LF (#10)
  p := Pos(#10, FSerialBuffer);
  if p = 0 then
    Exit;

  linha := Copy(FSerialBuffer, 1, p - 1);

  // remove CR se vier CRLF
  if (linha <> '') and (linha[Length(linha)] = #13) then
    Delete(linha, Length(linha), 1);

  // remove do buffer até o LF (inclusive)
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

  // ======= EXIBIÇÃO =======
  kgf := GramasParaKgf(peso);

  LedForca.Caption := FormatFloat('0.###', kgf); // kgf
  ledPeso.Caption := IntToStr(peso div 1000);   // kg (inteiro)

  indGnouMeter1.Value := peso;
  A3nalogGauge1.Position := peso;

  // ======= GRÁFICO: Y em kgf, X em leitura =======
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
