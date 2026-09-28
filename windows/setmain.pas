//Objetivo: parametros de configuracao do Dinamometro
//Criado por Marcelo Maurin Martins
//Data:07/02/2021 - revisado na versao 2.0

unit setmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  filename = 'dinamometro.cfg';

  // Versao do formato do arquivo. Na versao 1 a tara era relativa ao zero
  // que o firmware 1.x capturava no boot; com o firmware 2.0 (leitura bruta)
  // essa tara nao vale mais e precisa ser refeita.
  CFG_VERSAO = 2;

type
  { TSetMain }
  TSetMain = class(TObject)
  private
    arquivo: TStringList;
    FPath: string;
    FVersaoLida: Integer;

    FPosX: Integer;
    FPosY: Integer;
    FHeight: Integer;
    FWidth: Integer;

    FComport: string;

    // valores guardados como texto, com ponto decimal
    FTara: string;
    FCalibracao: string;
    FPesoCal: string;
    FMedia: string;

    procedure Default;
    function LeChave(const AChave: string; var AValor: string): Boolean;
    function LeInt(const AChave: string; ADefault: Integer): Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SalvaContexto(flag: Boolean);
    procedure CarregaContexto;
    procedure IdentificaArquivo(flag: Boolean);

    { True quando o arquivo lido era de uma versao anterior e a tara foi
      descartada (precisa refazer a tara com o firmware 2.0). }
    function TaraDescartada: Boolean;

    property posx: Integer read FPosX write FPosX;
    property posy: Integer read FPosY write FPosY;
    property Height: Integer read FHeight write FHeight;
    property Width: Integer read FWidth write FWidth;

    property Comport: string read FComport write FComport;

    property TaraStr: string read FTara write FTara;
    property CalibracaoStr: string read FCalibracao write FCalibracao;
    property PesoCalStr: string read FPesoCal write FPesoCal;
    property MediaStr: string read FMedia write FMedia;
  end;

implementation

procedure TSetMain.Default;
begin
  FPosX := 100;
  FPosY := 100;
  FHeight := 374;
  FWidth := 714;

  FComport := 'COM5';

  FTara := '0';
  FCalibracao := '0';     // contagens por grama; 0 = nao calibrado
  FPesoCal := '1000';     // gramas
  FMedia := '1';          // sem suavizacao
end;

function TSetMain.LeChave(const AChave: string; var AValor: string): Boolean;
var
  i: Integer;
  prefixo: string;
begin
  Result := False;
  prefixo := UpperCase(AChave) + ':';
  for i := 0 to arquivo.Count - 1 do
    if Pos(prefixo, UpperCase(arquivo[i])) = 1 then
    begin
      AValor := Trim(Copy(arquivo[i], Length(prefixo) + 1, MaxInt));
      Exit(True);
    end;
end;

function TSetMain.LeInt(const AChave: string; ADefault: Integer): Integer;
var
  s: string;
begin
  s := '';
  if LeChave(AChave, s) then
    Result := StrToIntDef(s, ADefault)
  else
    Result := ADefault;
end;

procedure TSetMain.CarregaContexto;
begin
  // Parte sempre dos valores padrao: chaves ausentes (arquivo de versao
  // anterior) ficam com um valor valido em vez de vazio.
  Default;

  FVersaoLida := LeInt('CFGVER', 1);

  FPosX := LeInt('POSX', FPosX);
  FPosY := LeInt('POSY', FPosY);
  FHeight := LeInt('HEIGHT', FHeight);
  FWidth := LeInt('WIDTH', FWidth);

  LeChave('COMPORT', FComport);
  LeChave('CALIBRACAO', FCalibracao);
  LeChave('PESOCAL', FPesoCal);
  LeChave('MEDIA', FMedia);

  if FVersaoLida >= CFG_VERSAO then
    LeChave('TARA', FTara);
end;

function TSetMain.TaraDescartada: Boolean;
begin
  Result := FVersaoLida < CFG_VERSAO;
end;

procedure TSetMain.IdentificaArquivo(flag: Boolean);
begin
  FPath := GetAppConfigDir(False);
  if not DirectoryExists(FPath) then
    ForceDirectories(FPath);

  if FileExists(FPath + filename) then
  begin
    try
      arquivo.LoadFromFile(FPath + filename);
    except
      arquivo.Clear;
    end;
    CarregaContexto;
  end
  else
  begin
    Default;
    FVersaoLida := CFG_VERSAO;
  end;
end;

constructor TSetMain.Create;
begin
  inherited Create;
  arquivo := TStringList.Create;
  IdentificaArquivo(True);
end;

procedure TSetMain.SalvaContexto(flag: Boolean);
begin
  if flag then
    IdentificaArquivo(False);

  arquivo.Clear;
  arquivo.Append('CFGVER:' + IntToStr(CFG_VERSAO));
  arquivo.Append('POSX:' + IntToStr(FPosX));
  arquivo.Append('POSY:' + IntToStr(FPosY));
  arquivo.Append('HEIGHT:' + IntToStr(FHeight));
  arquivo.Append('WIDTH:' + IntToStr(FWidth));
  arquivo.Append('COMPORT:' + FComport);
  arquivo.Append('TARA:' + FTara);
  arquivo.Append('CALIBRACAO:' + FCalibracao);
  arquivo.Append('PESOCAL:' + FPesoCal);
  arquivo.Append('MEDIA:' + FMedia);

  try
    arquivo.SaveToFile(FPath + filename);
    FVersaoLida := CFG_VERSAO;
  except
    // sem permissao de escrita: segue sem salvar
  end;
end;

destructor TSetMain.Destroy;
begin
  arquivo.Free;
  inherited Destroy;
end;

end.
