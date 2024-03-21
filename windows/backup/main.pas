unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, TAGraph, indSliders, LedNumber, indGnouMeter, indLCDDisplay,
  A3nalogGauge, IndLed, LazSerial, LazSynaSer,TATypes, TASeries, TACustomSeries,  TADrawUtils,
  TAChartUtils;

type

  { Tfrmmain }

  Tfrmmain = class(TForm)
    A3nalogGauge1: TA3nalogGauge;
    btTara: TButton;
    btCalibra: TButton;
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
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LazSerial1: TLazSerial;
    LEDNumber1: TLEDNumber;
    Memo1: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    tsSobre: TTabSheet;
    procedure btTaraClick(Sender: TObject);
    procedure edCalibracaoChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure indLed1Click(Sender: TObject);
    procedure LazSerial1RxData(Sender: TObject);
    procedure LazSerial1Status(Sender: TObject; Reason: THookSerialReason;
      const Value: string);
  private
    function GramasParaNewtons(pesoGramas: longint): longint;
    procedure GeraLinha(values: longint);
    procedure CriaLinha();
  public
    peso : longint;
    forca : longint;
    LineSeries: TLineSeries;
  end;

var
  frmmain: Tfrmmain;

implementation

{$R *.lfm}

{ Tfrmmain }

procedure Tfrmmain.GeraLinha(values: longint);
begin
   LineSeries.Add(values, 'Newton');  // Adiciona o valor e o rótulo (nome do grupo)

end;

procedure Tfrmmain.CriaLinha;
var
    valor: Variant;

begin

    Chart1.ClearSeries;  // Limpa as séries existentes
    LineSeries := TLineSeries.Create(Chart1);
    Chart1.AddSeries(LineSeries);

    // Configurações da série de linha
    LineSeries.ShowPoints := True; // Mostra pontos para cada valor
    LineSeries.LinePen.Width := 2; // Configura a espessura da linha

    // Configurações da legenda
    Chart1.Legend.Visible := True;
    Chart1.Legend.Alignment := laBottomLeft;  // Posição da legenda

end;

function Tfrmmain.GramasParaNewtons(pesoGramas: longint): longint;
const
  g = 9.81; // Aceleração devido à gravidade em m/s^2
begin
  // Converte gramas para quilogramas e calcula a força em newtons
  Result := trunc((pesoGramas / 1000) * g);
end;


procedure Tfrmmain.indLed1Click(Sender: TObject);
begin
  LazSerial1.device := edPorta.text;
  if(LazSerial1.Active) then
  begin
    LazSerial1.close;
  end
  else
  begin
    LazSerial1.Open;
    CriaLinha;
  end;

end;

procedure Tfrmmain.btTaraClick(Sender: TObject);
begin
  edTara.Text := inttostr(peso);
end;

procedure Tfrmmain.edCalibracaoChange(Sender: TObject);
var
  fator : longint;
  pesoaval : longint;
begin
   pesoaval :=   trunc(strtoint(edPesoCal.text) / peso);
   edPesoCal.text := inttostr(pesoaval);

end;

procedure Tfrmmain.FormShow(Sender: TObject);
begin
  PageControl1.ActivePage := tsSobre;
end;

procedure Tfrmmain.LazSerial1RxData(Sender: TObject);
var
  lista : TStringList;
  valor : string;
  valor1: string;
  posicao : integer;
  valor2: longint;
begin
   lista := TStringlist.create();
   valor :=    LazSerial1.ReadData;
   lista.Text :=  valor;

   if (lista.Count>0) then
   begin
     if(lista.Strings[0]<>'') then
     begin
       try
         valor1 := trim(lista.Strings[0]);
         if(valor1<>'') then
         begin
           posicao := pos('peso:', valor1);
           if(posicao>-1) then
           begin
             valor := copy(valor1,posicao+6,Length(valor1));


             peso := strtoint(valor) - strtoint(edTara.Text);
             forca := GramasParaNewtons(peso);
             LEDNumber1.Caption:=  inttostr(peso);
             indGnouMeter1.Value:= peso;
             A3nalogGauge1.Position:=peso;
             GeraLinha(forca);
             sleep(2000);
             //application.ProcessMessages;


           end;
         end;
       finally
       end;
     end;

   end;
end;

procedure Tfrmmain.LazSerial1Status(Sender: TObject; Reason: THookSerialReason;
  const Value: string);
begin
  if (Reason= HR_Connect) then
  begin
    indLed1.LedValue:=true;
  end;
  if (Reason= HR_SerialClose) then
  begin
    indLed1.LedValue:=false;
  end;
end;

end.

