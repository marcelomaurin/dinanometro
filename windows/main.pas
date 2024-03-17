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
    Chart1: TChart;
    edPorta: TEdit;
    indGnouMeter1: TindGnouMeter;
    indLed1: TindLed;
    Label1: TLabel;
    Label2: TLabel;
    LazSerial1: TLazSerial;
    LCDDisplay1: TLCDDisplay;
    LEDNumber1: TLEDNumber;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure indLed1Click(Sender: TObject);
    procedure LazSerial1RxData(Sender: TObject);
    procedure LazSerial1Status(Sender: TObject; Reason: THookSerialReason;
      const Value: string);
  private

  public

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

procedure Tfrmmain.LazSerial1RxData(Sender: TObject);
var
  lista : TStringList;
begin
   lista := TStringlist.create();
   lista.Text :=   LazSerial1.ReadData;
   if (lista.Count>0) then
   begin
     if(lista.Strings[0]<>'') then
     begin
       LEDNumber1.Caption:=  lista.Strings[0];
       LCDDisplay1.Caption :=  lista.Strings[0];
       indGnouMeter1.Value:= strtoint(lista.Strings[0]);
       A3nalogGauge1.Position:=strtoint(lista.Strings[0]);
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

