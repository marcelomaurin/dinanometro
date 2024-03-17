unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  TAGraph, indSliders, LedNumber, indGnouMeter, indLCDDisplay, A3nalogGauge,
  IndLed, LazSerial, LazSynaSer;

type

  { Tfrmmain }

  Tfrmmain = class(TForm)
    A3nalogGauge1: TA3nalogGauge;
    Button1: TButton;
    Chart1: TChart;
    edFator1: TEdit;
    edPorta: TEdit;
    edFator: TEdit;
    indGnouMeter1: TindGnouMeter;
    indLed1: TindLed;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LazSerial1: TLazSerial;
    LEDNumber1: TLEDNumber;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure indLed1Click(Sender: TObject);
    procedure LazSerial1RxData(Sender: TObject);
    procedure LazSerial1Status(Sender: TObject; Reason: THookSerialReason;
      const Value: string);
  private

  public
    valor : LongInt;
    escala : LongInt;
    newton : longint;
    tara : longint;

  end;

var
  frmmain: Tfrmmain;

implementation

{$R *.lfm}

{ Tfrmmain }

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
  end;

end;

procedure Tfrmmain.Button1Click(Sender: TObject);
begin
  tara := valor;
end;

procedure Tfrmmain.LazSerial1RxData(Sender: TObject);
var
  lista : TStringList;
  linha :string;
  posicao : integer;
begin
   lista := TStringlist.create();
   lista.Text :=   LazSerial1.ReadData;
   if (lista.Count>0) then
   begin
     linha := lista.Strings[0];
     posicao := pos('Peso:',linha);
     if(posicao>0) then
     begin
       linha := copy(linha,posicao+5,Length(linha));
     end;
     if(linha<>'') then
     begin
       valor := strtoint(linha);
       newton := round((valor- tara) / strtoint(edFator.text));
       LEDNumber1.Caption:= inttostr(newton);
       indGnouMeter1.Value:= newton;
       A3nalogGauge1.Position:=newton;
     end;

   end;
   Application.ProcessMessages;
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

