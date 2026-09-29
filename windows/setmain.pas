//Objetivo: parametros de configuracao do Dinamometro (arquivo dinamometro.cfg)
//Criado por Marcelo Maurin Martins
//Data: 07/02/2021 - revisado em 2026 (enxugado, sem dependencia de funcoes.pas)
//
// Formato do arquivo: uma linha por chave, "CHAVE:valor".
// E compativel com os arquivos gravados pelas versoes anteriores
// (chaves desconhecidas sao simplesmente ignoradas).

unit setmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  filename = 'dinamometro.cfg';

type
  { TSetMain }
  TSetMain = class(TObject)
  private
    FArquivo: TStringList;
    FPath: string;

    FComport: string;
    FTara: string;
    FCalibracao: string;
    FPesoCal: string;

    FPosX: integer;
    FPosY: integer;
    FHeight: integer;
    FWidth: integer;

    function LeChave(const Chave: string; out Valor: string): boolean;
    function LeInt(const Chave: string; Padrao: integer): integer;
    procedure SetTaraStr(const AValue: string);
    procedure SetCalibracaoStr(const AValue: string);
    procedure SetPesoCalStr(const AValue: string);
    procedure Default;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SalvaContexto(flag: boolean);
    procedure CarregaContexto;
    procedure IdentificaArquivo(flag: boolean);

    function ArquivoConfig: string;

    property Comport: string read FComport write FComport;

    // Valores guardados como texto, exatamente como digitados na tela
    property TaraStr: string read FTara write SetTaraStr;
    property CalibracaoStr: string read FCalibracao write SetCalibracaoStr;
    property PesoCalStr: string read FPesoCal write SetPesoCalStr;

    // Nomes antigos mantidos por compatibilidade
    property Tara: string read FTara write SetTaraStr;
    property Calibracao: string read FCalibracao write SetCalibracaoStr;
    property PesoCal: string read FPesoCal write SetPesoCalStr;

    property posx: integer read FPosX write FPosX;
    property posy: integer read FPosY write FPosY;
    property Height: integer read FHeight write FHeight;
    property Width: integer read FWidth write FWidth;
  end;

implementation

{ TSetMain }

procedure TSetMain.SetTaraStr(const AValue: string);
begin
  FTara := Trim(AValue);
end;

procedure TSetMain.SetCalibracaoStr(const AValue: string);
begin
  FCalibracao := Trim(AValue);
end;

procedure TSetMain.SetPesoCalStr(const AValue: string);
begin
  FPesoCal := Trim(AValue);
end;

procedure TSetMain.Default;
begin
  {$IFDEF WINDOWS}
  FComport := 'COM5';
  {$ELSE}
  FComport := '/dev/rfcomm0';
  {$ENDIF}

  // Tara = 0 porque o firmware ja desconta o zero medido no boot.
  // Calibracao = contagens do HX711 por grama (use o botao "Calibra").
  FTara := '0';
  FCalibracao := '0';
  FPesoCal := '1000'; // 1000 g = 1 kg

  FPosX := 100;
  FPosY := 100;
  FHeight := 400;
  FWidth := 400;
end;

// Procura "CHAVE:" no inicio de uma linha (sem diferenciar maiusculas).
function TSetMain.LeChave(const Chave: string; out Valor: string): boolean;
var
  i: integer;
  prefixo, linha: string;
begin
  Result := False;
  Valor := '';
  prefixo := UpperCase(Chave) + ':';
  for i := 0 to FArquivo.Count - 1 do
  begin
    linha := TrimLeft(FArquivo[i]);
    if UpperCase(Copy(linha, 1, Length(prefixo))) = prefixo then
    begin
      Valor := Trim(Copy(linha, Length(prefixo) + 1, MaxInt));
      Exit(True);
    end;
  end;
end;

function TSetMain.LeInt(const Chave: string; Padrao: integer): integer;
var
  v: string;
begin
  if LeChave(Chave, v) then
    Result := StrToIntDef(v, Padrao)
  else
    Result := Padrao;
end;

procedure TSetMain.CarregaContexto;
var
  v: string;
begin
  if LeChave('COMPORT', v) and (v <> '') then
    FComport := v;
  if LeChave('TARA', v) and (v <> '') then
    FTara := v;
  if LeChave('CALIBRACAO', v) and (v <> '') then
    FCalibracao := v;
  if LeChave('PESOCAL', v) and (v <> '') then
    FPesoCal := v;

  FPosX := LeInt('POSX', FPosX);
  FPosY := LeInt('POSY', FPosY);
  FHeight := LeInt('HEIGHT', FHeight);
  FWidth := LeInt('WIDTH', FWidth);
end;

function TSetMain.ArquivoConfig: string;
begin
  Result := IncludeTrailingPathDelimiter(FPath) + filename;
end;

procedure TSetMain.IdentificaArquivo(flag: boolean);
begin
  FPath := GetAppConfigDir(False);
  if not DirectoryExists(FPath) then
    ForceDirectories(FPath);

  // Sempre parte dos padroes; o arquivo sobrescreve o que tiver.
  Default;
  FArquivo.Clear;

  if flag and FileExists(ArquivoConfig) then
  begin
    try
      FArquivo.LoadFromFile(ArquivoConfig);
      CarregaContexto;
    except
      // arquivo corrompido/inacessivel: segue com os padroes
      FArquivo.Clear;
    end;
  end;
end;

constructor TSetMain.Create;
begin
  inherited Create;
  FArquivo := TStringList.Create;
  IdentificaArquivo(True);
end;

procedure TSetMain.SalvaContexto(flag: boolean);
begin
  // flag mantido por compatibilidade de assinatura; nao recarrega o arquivo
  // (isso descartaria os valores alterados em memoria).
  FArquivo.Clear;
  FArquivo.Add('COMPORT:' + FComport);
  FArquivo.Add('TARA:' + FTara);
  FArquivo.Add('CALIBRACAO:' + FCalibracao);
  FArquivo.Add('PESOCAL:' + FPesoCal);
  FArquivo.Add('POSX:' + IntToStr(FPosX));
  FArquivo.Add('POSY:' + IntToStr(FPosY));
  FArquivo.Add('HEIGHT:' + IntToStr(FHeight));
  FArquivo.Add('WIDTH:' + IntToStr(FWidth));

  try
    if not DirectoryExists(FPath) then
      ForceDirectories(FPath);
    FArquivo.SaveToFile(ArquivoConfig);
  except
    on E: Exception do
      raise Exception.Create('Nao foi possivel gravar ' + ArquivoConfig + ': ' + E.Message);
  end;
end;

destructor TSetMain.Destroy;
begin
  FreeAndNil(FArquivo);
  inherited Destroy;
end;

end.
