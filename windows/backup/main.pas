unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, Menus, TAGraph, indSliders, LedNumber, indGnouMeter, indLCDDisplay,
  A3nalogGauge, IndLed, LazSerial, LazSynaSer,TATypes, TASeries, TACustomSeries,  TADrawUtils,
  TAChartUtils, setmain;

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
    Label11: TLabel;
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
    procedure btTaraClick(Sender: TObject);
    procedure edCalibracaoChange(Sender: TObject);
    procedure edPortaChange(Sender: TObject);
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
    function GramasParaNewtons(pesoGramas: longint): longint;
    procedure GeraLinha(values: longint);
    procedure CriaLinha();
    procedure ResetPeso();
  public
    peso : longint;
    forca : longint;
    referencia : LongInt;
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
begin
    Chart1.ClearSeries;  // Limpa as séries existentes no gráfico

    // Cria uma nova série de linha e a adiciona ao gráfico
    LineSeries := TLineSeries.Create(Chart1);
    Chart1.AddSeries(LineSeries);

    // Configurações do título e aparência da série de linha
    LineSeries.Title := 'Força aplicada';
    LineSeries.ShowPoints := True;
    LineSeries.LinePen.Width := 2;

    // Configurações da legenda
    Chart1.Legend.Visible := True;

    // Configurando os títulos dos eixos
    Chart1.BottomAxis.Title.Caption := 'Tempo (s)'; // Define o título do eixo X
    Chart1.LeftAxis.Title.Caption := 'Força (mN)';   // Define o título do eixo Y

    // A propriedade Alignment pode ser usada para ajustar a posição do título do eixo, se necessário
    // Por exemplo, para centralizar o título do eixo X abaixo do eixo:
    Chart1.BottomAxis.Title.Alignment := taCenter;

    // E para alinhar o título do eixo Y no meio da lateral esquerda:
    Chart1.LeftAxis.Title.Alignment := taCenter;

    // Outras configurações podem ser adicionadas aqui, conforme necessário
end;

procedure Tfrmmain.ResetPeso();
begin
  edTara.text := '0';
  edCalibracao.text := '0';
end;


function Tfrmmain.GramasParaNewtons(pesoGramas: longint): longint;
const
  g = 9.81; // Aceleração devido à gravidade em m/s^2
begin
  // Converte gramas para quilogramas e calcula a força em newtons
  Result := trunc((pesoGramas ) * g);
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
  ResetPeso();
  edTara.Text := Inttostr(referencia);
end;

procedure Tfrmmain.btCalibraClick(Sender: TObject);
var
  fator : longint;

begin
  fator := trunc((referencia-strtoint(edtara.text)) / strtoint(edPesoCal.text );
  edCalibracao.text := inttostr(fator);

end;

procedure Tfrmmain.edCalibracaoChange(Sender: TObject);
begin


end;

procedure Tfrmmain.edPortaChange(Sender: TObject);
begin

end;

procedure Tfrmmain.FormCreate(Sender: TObject);
begin
  FSetMain := TSetMain.create();
  FSetMain.CarregaContexto();
  edPorta.text := FSetMain.Comport;
  edTara.text := FSetMain.Tara;
  edCalibracao.text := FSetMain.Calibracao;

end;

procedure Tfrmmain.FormDestroy(Sender: TObject);
begin

  FSetMain.Comport := edPorta.text;
  FSetMain.Tara:= edTara.text;
  FSETMain.Calibracao:= edCalibracao.text;
  FSetMain.SalvaContexto(false);
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
  if(LazSerial1.DataAvailable) then
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
             if(TryStrToInt(valor, peso) ) then
             begin
               if(strtoint(edCalibracao.text)<>0) then
               begin
                 referencia := peso;
                 peso := trunc(( (referencia - strtoint(edTara.Text)) / strtoint(edCalibracao.text))  ) ;

               end
               else
               begin
                 referencia := peso;
                 peso := (referencia - strtoint(edTara.Text) )  ;
               end;
               forca := GramasParaNewtons(peso);
               LedForca.Caption:=  inttostr(forca);
               ledPeso.Caption := inttostr(peso);
               indGnouMeter1.Value:= forca;
               A3nalogGauge1.Position:=forca;
               indGnouMeter1.Value:=forca;
               GeraLinha(forca);
               //sleep(2000);
               //application.ProcessMessages;
             end;

           end;
         end;
       finally
       end;
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

procedure Tfrmmain.milimparClick(Sender: TObject);
begin
      LineSeries.Clear;
end;

procedure Tfrmmain.misalvarClick(Sender: TObject);
begin

end;

end.

