{
  Dinamometro Digital - protocolo serial e calculos de forca
  Autor: Marcelo Maurin Martins

  Unidade sem dependencia de interface grafica, para poder ser testada
  isoladamente.

  Protocolo do firmware 2.0 (uma mensagem por linha):
    D,<ms>,<bruto>    amostra: tempo do ESP32 (ms) e contagens do ADC
    E,<ms>,<codigo>   erro (SAT, NOHX711)
    # texto           informativo
  Firmware 1.x (legado):
    Peso:<valor>      valor ja com o zero do firmware subtraido
}
unit protocolo;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

const
  G_PADRAO = 9.80665;          // m/s^2
  BUFFER_MAX = 4096;           // limite do buffer sem fim de linha

type
  TTipoLinha = (tlNenhuma, tlAmostra, tlAmostraLegada, tlErro, tlInfo);

  TLinhaDecodificada = record
    Tipo: TTipoLinha;
    TempoMs: Int64;            // -1 quando a linha nao traz tempo
    Bruto: Int64;
    Texto: string;             // codigo do erro ou texto informativo
  end;

  { Janela circular para media das ultimas N leituras }
  TJanelaMedia = class
  private
    FValores: array of Double;
    FInicio: Integer;
    FCount: Integer;
    FSoma: Double;
    function GetCapacidade: Integer;
    procedure SetCapacidade(AValor: Integer);
  public
    constructor Create(ACapacidade: Integer);
    procedure Adiciona(AValor: Double);
    procedure Limpa;
    function Media: Double;
    property Count: Integer read FCount;
    property Capacidade: Integer read GetCapacidade write SetCapacidade;
  end;

{ Retira do buffer a proxima linha completa (sem CR/LF). Devolve False se
  ainda nao ha linha completa. Descarta lixo se o buffer passar do limite. }
function ExtraiLinha(var ABuffer: string; out ALinha: string): Boolean;

function DecodificaLinha(const ALinha: string): TLinhaDecodificada;

{ Converte texto aceitando virgula ou ponto como separador decimal }
function StrToFloatFlex(const S: string; ADefault: Double): Double;

{ Formata sempre com ponto decimal (para o arquivo de configuracao) }
function FloatToStrPonto(AValor: Double; ADecimais: Integer): string;

{ Contagens do ADC -> gramas-forca, usando tara (contagens) e fator
  (contagens por grama). Com fator zero devolve as contagens sem escala. }
function BrutoParaGramas(ABruto, ATara, AFator: Double): Double;

function GramasParaNewtons(AGramas: Double): Double;
function GramasParaKgf(AGramas: Double): Double;

implementation

var
  FmtPonto: TFormatSettings;

function ExtraiLinha(var ABuffer: string; out ALinha: string): Boolean;
var
  p: Integer;
begin
  ALinha := '';
  p := Pos(#10, ABuffer);
  if p = 0 then
  begin
    if Length(ABuffer) > BUFFER_MAX then
      ABuffer := '';
    Exit(False);
  end;

  ALinha := Copy(ABuffer, 1, p - 1);
  Delete(ABuffer, 1, p);
  ALinha := Trim(ALinha);   // remove CR e espacos
  Result := True;
end;

function DecodificaLinha(const ALinha: string): TLinhaDecodificada;
var
  partes: TStringArray;
  v: Int64;
  p: Integer;
begin
  Result.Tipo := tlNenhuma;
  Result.TempoMs := -1;
  Result.Bruto := 0;
  Result.Texto := '';

  if ALinha = '' then Exit;

  if ALinha[1] = '#' then
  begin
    Result.Tipo := tlInfo;
    Result.Texto := Trim(Copy(ALinha, 2, MaxInt));
    Exit;
  end;

  if (Length(ALinha) > 2) and (ALinha[2] = ',') and (ALinha[1] in ['D', 'E']) then
  begin
    partes := ALinha.Split([',']);
    if Length(partes) <> 3 then Exit;
    if not TryStrToInt64(Trim(partes[1]), v) then Exit;

    if ALinha[1] = 'D' then
    begin
      if not TryStrToInt64(Trim(partes[2]), Result.Bruto) then Exit;
      Result.TempoMs := v;
      Result.Tipo := tlAmostra;
    end
    else
    begin
      Result.TempoMs := v;
      Result.Texto := Trim(partes[2]);
      Result.Tipo := tlErro;
    end;
    Exit;
  end;

  // Firmware 1.x
  p := Pos('Peso:', ALinha);
  if p > 0 then
    if TryStrToInt64(Trim(Copy(ALinha, p + 5, MaxInt)), v) then
    begin
      Result.Bruto := v;
      Result.Tipo := tlAmostraLegada;
    end;
end;

function StrToFloatFlex(const S: string; ADefault: Double): Double;
var
  t: string;
begin
  t := StringReplace(Trim(S), ',', '.', [rfReplaceAll]);
  if not TryStrToFloat(t, Result, FmtPonto) then
    Result := ADefault;
end;

function FloatToStrPonto(AValor: Double; ADecimais: Integer): string;
begin
  Result := FloatToStrF(AValor, ffFixed, 18, ADecimais, FmtPonto);
end;

function BrutoParaGramas(ABruto, ATara, AFator: Double): Double;
begin
  if AFator <> 0 then
    Result := (ABruto - ATara) / AFator
  else
    Result := ABruto - ATara;
end;

function GramasParaNewtons(AGramas: Double): Double;
begin
  Result := AGramas / 1000.0 * G_PADRAO;
end;

function GramasParaKgf(AGramas: Double): Double;
begin
  Result := AGramas / 1000.0;
end;

{ TJanelaMedia }

constructor TJanelaMedia.Create(ACapacidade: Integer);
begin
  inherited Create;
  SetCapacidade(ACapacidade);
end;

function TJanelaMedia.GetCapacidade: Integer;
begin
  Result := Length(FValores);
end;

procedure TJanelaMedia.SetCapacidade(AValor: Integer);
begin
  if AValor < 1 then AValor := 1;
  SetLength(FValores, AValor);
  Limpa;
end;

procedure TJanelaMedia.Limpa;
begin
  FInicio := 0;
  FCount := 0;
  FSoma := 0;
end;

procedure TJanelaMedia.Adiciona(AValor: Double);
var
  idx: Integer;
begin
  if FCount < Length(FValores) then
  begin
    idx := (FInicio + FCount) mod Length(FValores);
    Inc(FCount);
  end
  else
  begin
    idx := FInicio;
    FSoma := FSoma - FValores[idx];
    FInicio := (FInicio + 1) mod Length(FValores);
  end;
  FValores[idx] := AValor;
  FSoma := FSoma + AValor;
end;

function TJanelaMedia.Media: Double;
begin
  if FCount = 0 then
    Result := 0
  else
    Result := FSoma / FCount;
end;

initialization
  FmtPonto := DefaultFormatSettings;
  FmtPonto.DecimalSeparator := '.';
  FmtPonto.ThousandSeparator := #0;

end.
