//Objetivo: Construir os parametros de setup da classe principal
//Criado por Marcelo Maurin Martins
//Data: 07/02/2021
//Refatorado para limpeza de parametros legados nao utilizados

unit setmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, funcoes;

const
  filename = 'dinamometro.cfg';

type
  { TSetMain }
  TSetMain = class(TObject)
  private
    arquivo: TStringList;
    Fpath: string;

    FComport: string;
    FTara: string;
    FCalibracao: string;
    FPesoCal: string;

    function GetTaraStr: string;
    function GetCalibracaoStr: string;
    function GetPesoCalStr: string;

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

    property Comport: string read FComport write FComport;
    property Tara: string read FTara write FTara;
    property Calibracao: string read FCalibracao write FCalibracao;
    property PesoCal: string read FPesoCal write FPesoCal;

    property TaraStr: string read GetTaraStr write SetTaraStr;
    property CalibracaoStr: string read GetCalibracaoStr write SetCalibracaoStr;
    property PesoCalStr: string read GetPesoCalStr write SetPesoCalStr;
  end;

var
  FSetMain: TSetMain;

implementation

{ TSetMain }

function TSetMain.GetTaraStr: string;
begin
  Result := FTara;
end;

function TSetMain.GetCalibracaoStr: string;
begin
  Result := FCalibracao;
end;

function TSetMain.GetPesoCalStr: string;
begin
  Result := FPesoCal;
end;

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
  FComport := 'COM5';
  FTara := '24594';
  FCalibracao := '4568';
  FPesoCal := '1000';
end;

procedure TSetMain.CarregaContexto;
var
  posicao: integer;
begin
  if BuscaChave(arquivo, 'COMPORT:', posicao) then
    FComport := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'TARA:', posicao) then
    FTara := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'CALIBRACAO:', posicao) then
    FCalibracao := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'PESOCAL:', posicao) then
    FPesoCal := RetiraInfo(arquivo.Strings[posicao]);
end;

procedure TSetMain.IdentificaArquivo(flag: boolean);
var
  caminhoCompleto: string;
begin
  Fpath := GetAppConfigDir(False);
  if not DirectoryExists(Fpath) then
    ForceDirectories(Fpath);

  caminhoCompleto := IncludeTrailingPathDelimiter(Fpath) + filename;

  if FileExists(caminhoCompleto) then
  begin
    arquivo.LoadFromFile(caminhoCompleto);
    CarregaContexto;
  end
  else
  begin
    Default;
  end;
end;

constructor TSetMain.Create;
begin
  inherited Create;
  arquivo := TStringList.Create;
  IdentificaArquivo(True);
end;

procedure TSetMain.SalvaContexto(flag: boolean);
var
  caminhoCompleto: string;
begin
  if flag then
    IdentificaArquivo(False);

  arquivo.Clear;
  arquivo.Append('COMPORT:' + FComport);
  arquivo.Append('TARA:' + FTara);
  arquivo.Append('CALIBRACAO:' + FCalibracao);
  arquivo.Append('PESOCAL:' + FPesoCal);

  caminhoCompleto := IncludeTrailingPathDelimiter(Fpath) + filename;
  arquivo.SaveToFile(caminhoCompleto);
end;

destructor TSetMain.Destroy;
begin
  if Assigned(arquivo) then
  begin
    arquivo.Free;
    arquivo := nil;
  end;
  inherited Destroy;
end;

end.
