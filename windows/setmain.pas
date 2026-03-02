//Objetivo construir os parametros de setup da classe principal
//Criado por Marcelo Maurin Martins
//Data:07/02/2021

unit setmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, funcoes, graphics;

const
  filename = 'dinamometro.cfg';

type
  { TSetMain }
  TSetMain = class(TObject)
  private
    arquivo: TStringList;
    ckdevice: boolean;
    FPosX: integer;
    FPosY: integer;
    FFixar: boolean;
    FStay: boolean;
    FLastFiles: String;
    FPATH: string;
    FHeight: integer;
    FWidth: integer;
    FFONT: TFont;
    FCHATGPT: string;
    FDllPath: string;
    FDllMyPath: string;
    FDllPostPath: string;

    FRunScript: string;
    FDebugScript: string;
    FCleanScript: string;
    FInstall: string;
    FCompile: string;

    FComport: string;

    // ====== valores (string) ======
    FTara: String;
    FCalibracao: String;
    FPesoCal: String; // <-- NOVO

    // ====== propriedades *Str (para o main) ======




    FHostnameMy: String;
    FBancoMy: String;
    FUsernameMy: String;
    FPasswordMy: String;

    FHostnamePost: String;
    FBancoPOST: String;
    FUsernamePost: String;
    FPasswordPost: String;
    FSchemaPost: String;
    FToolsFalar: Boolean;

    function GetTaraStr: string;
    function GetCalibracaoStr: string;
    function GetPesoCalStr: string;

    procedure SetTaraStr(const AValue: string);
    procedure SetCalibracaoStr(const AValue: string);
    procedure SetPesoCalStr(const AValue: string);

    procedure SetDevice(const Value: Boolean);
    procedure SetPOSX(value: integer);
    procedure SetPOSY(value: integer);
    procedure SetFixar(value: boolean);
    procedure SetStay(value: boolean);
    procedure SetLastFiles(value: string);
    procedure SetFont(value: TFont);
    procedure SetCHATGPT(value: String);
    procedure SetDllPath(value: string);
    procedure SetDllMyPath(value: string);
    procedure SetDllPostPath(value: string);
    procedure SetToolsFalar(value: boolean);
    procedure Default;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SalvaContexto(flag: boolean);
    procedure CarregaContexto;
    procedure IdentificaArquivo(flag: boolean);

    property device: boolean read ckdevice write SetDevice;
    property posx: integer read FPosX write SetPOSX;
    property posy: integer read FPosY write SetPOSY;
    property fixar: boolean read FFixar write SetFixar;
    property stay: boolean read FStay write SetStay;
    property lastfiles: string read FLastFiles write SetLastFiles;
    property Height: integer read FHeight write FHeight;
    property Width: integer read FWidth write FWidth;

    property RunScript: string read FRunScript write FRunScript;
    property DebugScript: string read FDebugScript write FDebugScript;
    property CleanScript: string read FCleanScript write FCleanScript;
    property Install: string read FInstall write FInstall;
    property Compile: string read FCompile write FCompile;

    property Comport: string read FComport write FComport;

    // ====== Mantém as antigas (se alguém usa) ======
    property Tara: string read FTara write FTara;
    property Calibracao: string read FCalibracao write FCalibracao;
    property PesoCal: string read FPesoCal write FPesoCal; // <-- NOVO

    // ====== As *Str que o main vai usar ======
    property TaraStr: string read GetTaraStr write SetTaraStr;
    property CalibracaoStr: string read GetCalibracaoStr write SetCalibracaoStr;
    property PesoCalStr: string read GetPesoCalStr write SetPesoCalStr; // <-- NOVO

    property Font: TFont read FFont write SetFont;
    property CHATGPT: String read FCHATGPT write SetCHATGPT;

    property DLLPath: String read FDllPath write SetDllPath;
    property DLLMyPath: String read FDllMyPath write SetDllMyPath;
    property DLLPostPath: String read FDllPostPath write SetDllPostPath;

    property HostnameMy: string read FHostnameMy write FHostnameMy;
    property BancoMy: String read FBancoMy write FBancoMy;
    property UsernameMy: String read FUsernameMy write FUsernameMy;
    property PasswordMy: String read FPasswordMy write FPasswordMy;

    property HostnamePost: String read FHostnamePost write FHostnamePost;
    property BancoPOST: String read FBancoPOST write FBancoPOST;
    property UsernamePost: String read FUsernamePOST write FUsernamePost;
    property PasswordPost: String read FPasswordPost write FPasswordPost;
    property SchemaPost: String read FSchemaPost write FSchemaPost;

    property ToolsFalar: Boolean read FToolsFalar write SetToolsFalar;
  end;

var
  FSetMain: TSetMain;

implementation

procedure TSetMain.SetDevice(const Value: Boolean);
begin
  ckdevice := Value;
end;

// ====== getters/setters *Str ======
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

//Valores default do codigo
procedure TSetMain.Default;
begin
  ckdevice := False;
  fixar := False;
  stay := False;
  FPosX := 100;
  FPosY := 100;
  FFixar := False;
  FStay := False;

  FDllPath := ExtractFilePath(ApplicationName);
  FDllMyPath := ExtractFilePath(ApplicationName);
  FDllPostPath := ExtractFilePath(ApplicationName);

  FHeight := 400;
  FWidth := 400;

  FRunScript := '';
  FDebugScript := '';
  FCleanScript := '';
  FInstall := '';
  FCompile := '';

  FComport := 'COM5';

  // defaults como string
  FTara := '24594';
  FCalibracao := '4568';
  FPesoCal := '1000'; // <-- NOVO (ex: 1000g = 1kg)

  if FFont = nil then
    FFONT := TFont.Create;

  FCHATGPT := '';
  FToolsFalar := False;
end;

procedure TSetMain.SetPOSX(value: integer);
begin
  Fposx := value;
end;

procedure TSetMain.SetPOSY(value: integer);
begin
  FposY := value;
end;

procedure TSetMain.SetFixar(value: boolean);
begin
  FFixar := value;
end;

procedure TSetMain.SetStay(value: boolean);
begin
  FStay := value;
end;

procedure TSetMain.SetLastFiles(value: string);
begin
  FLastFiles := value;
end;

procedure TSetMain.SetFont(value: TFont);
begin
  FFont := value;
end;

procedure TSetMain.SetCHATGPT(value: String);
begin
  FCHATGPT := value;
end;

procedure TSetMain.SetDllPath(value: string);
begin
  FDllPath := value;
end;

procedure TSetMain.SetDllMyPath(value: string);
begin
  FDllMyPath := value;
end;

procedure TSetMain.SetDllPostPath(value: string);
begin
  FDllPostPath := value;
end;

procedure TSetMain.SetToolsFalar(value: boolean);
begin
  FToolsFalar := value;
end;

procedure TSetMain.CarregaContexto;
var
  posicao: integer;
begin
  if BuscaChave(arquivo, 'DEVICE:', posicao) then
    ckdevice := (RetiraInfo(arquivo.Strings[posicao]) = '1');

  if BuscaChave(arquivo, 'POSX:', posicao) then
    FPOSX := StrToInt(RetiraInfo(arquivo.Strings[posicao]));

  if BuscaChave(arquivo, 'POSY:', posicao) then
    FPOSY := StrToInt(RetiraInfo(arquivo.Strings[posicao]));

  if BuscaChave(arquivo, 'FIXAR:', posicao) then
    FFixar := StrToBool(RetiraInfo(arquivo.Strings[posicao]));

  if BuscaChave(arquivo, 'STAY:', posicao) then
    FStay := StrToBool(RetiraInfo(arquivo.Strings[posicao]));

  if BuscaChave(arquivo, 'LASTFILES:', posicao) then
    FLastFiles := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'HEIGHT:', posicao) then
    FHEIGHT := StrToInt(RetiraInfo(arquivo.Strings[posicao]));

  if BuscaChave(arquivo, 'WIDTH:', posicao) then
    FWidth := StrToInt(RetiraInfo(arquivo.Strings[posicao]));

  if BuscaChave(arquivo, 'RUNSCRIPT:', posicao) then
    FRunScript := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'DEBUGSCRIPT:', posicao) then
    FDebugScript := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'CLEANSCRIPT:', posicao) then
    FCleanScript := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'INSTALLSCRIPT:', posicao) then
    FInstall := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'COMPILESCRIPT:', posicao) then
    FCompile := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'COMPORT:', posicao) then
    FCOMPORT := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'TARA:', posicao) then
    FTARA := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'CALIBRACAO:', posicao) then
    FCalibracao := RetiraInfo(arquivo.Strings[posicao]);

  // ====== NOVO ======
  if BuscaChave(arquivo, 'PESOCAL:', posicao) then
    FPesoCal := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'FONT:', posicao) then
    StringToFont(RetiraInfo(arquivo.Strings[posicao]), FFONT);

  if BuscaChave(arquivo, 'CHATGPT:', posicao) then
    FCHATGPT := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'DLLPATH:', posicao) then
    FDLLPATH := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'DLLMYPATH:', posicao) then
    FDLLMyPATH := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'DLLPOSTPATH:', posicao) then
    FDLLPOSTPATH := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'HOSTNAMEMY:', posicao) then
    FHostnameMy := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'BANCOMY:', posicao) then
    FBancoMy := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'USERNAMEMY:', posicao) then
    FUsernameMy := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'PASSWORDMY:', posicao) then
    FPasswordMy := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'HOSTNAMEPOST:', posicao) then
    FHostnamePost := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'BANCOPOST:', posicao) then
    FBancoPost := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'USERNAMEPOST:', posicao) then
    FUsernamePost := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'PASSWORDPOST:', posicao) then
    FPasswordPost := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'SCHEMAPOST:', posicao) then
    FSchemaPost := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'TOOLSFALAR:', posicao) then
    FTOOLSFALAR := iif(RetiraInfo(arquivo.Strings[posicao]) = '0', False, True);
end;

procedure TSetMain.IdentificaArquivo(flag: boolean);
begin
  {$ifdef Darwin}
  Fpath := GetAppConfigDir(False);
  if not (FileExists(FPATH)) then
    CreateDir(fpath);
  {$endif}

  {$ifdef Linux}
  Fpath := GetAppConfigDir(False);
  if not (FileExists(FPATH)) then
    CreateDir(fpath);
  {$endif}

  {$ifdef Windows}
  Fpath := GetAppConfigDir(False);
  if not (FileExists(FPATH)) then
    CreateDir(fpath);
  {$endif}

  if FileExists(fpath + filename) then
  begin
    arquivo.LoadFromFile(fpath + filename);
    CarregaContexto;
  end
  else
  begin
    Default;
  end;
end;

constructor TSetMain.Create;
begin
  arquivo := TStringList.Create;
  FFONT := TFont.Create;
  IdentificaArquivo(True);
end;

procedure TSetMain.SalvaContexto(flag: boolean);
begin
  if flag then
    IdentificaArquivo(False);

  arquivo.Clear;
  arquivo.Append('DEVICE:' + iif(ckdevice, '1', '0'));
  arquivo.Append('POSX:' + IntToStr(FPOSX));
  arquivo.Append('POSY:' + IntToStr(FPOSY));
  arquivo.Append('FIXAR:' + BoolToStr(FFixar));
  arquivo.Append('STAY:' + BoolToStr(FStay));
  arquivo.Append('LASTFILES:' + FLastFiles);
  arquivo.Append('HEIGHT:' + IntToStr(FHEIGHT));
  arquivo.Append('WIDTH:' + IntToStr(FWIDTH));
  arquivo.Append('RUNSCRIPT:' + FRunScript);
  arquivo.Append('DEBUGSCRIPT:' + FDebugScript);
  arquivo.Append('CLEANSCRIPT:' + FCleanScript);
  arquivo.Append('INSTALLSCRIPT:' + FInstall);
  arquivo.Append('COMPILESCRIPT:' + FCompile);
  arquivo.Append('COMPORT:' + FComport);

  arquivo.Append('TARA:' + FTARA);
  arquivo.Append('CALIBRACAO:' + FCALIBRACAO);

  // ====== NOVO ======
  arquivo.Append('PESOCAL:' + FPesoCal);

  arquivo.Append('FONT:' + FontToString(FFONT));
  arquivo.Append('CHATGPT:' + FCHATGPT);
  arquivo.Append('DLLPATH:' + FDLLPATH);
  arquivo.Append('DLLMYPATH:' + FDLLMYPATH);
  arquivo.Append('DLLPOSTPATH:' + FDLLPOSTPATH);

  arquivo.Append('HOSTNAMEMY:' + FHostnameMy);
  arquivo.Append('BANCOMY:' + FBancoMy);
  arquivo.Append('USERNAMEMY:' + FUsernameMy);
  arquivo.Append('PASSWORDMY:' + FPasswordMy);

  arquivo.Append('HOSTNAMEPOST:' + FHostnamePOST);
  arquivo.Append('BANCOPOST:' + FBancoPOST);
  arquivo.Append('USERNAMEPOST:' + FUsernamePOST);
  arquivo.Append('PASSWORDPOST:' + FPasswordPOST);
  arquivo.Append('SCHEMAPOST:' + FSchemaPost);
  arquivo.Append('TOOLSFALAR:' + iif(FToolsFalar, '1', '0'));

  arquivo.SaveToFile(fpath + filename);
end;

destructor TSetMain.Destroy;
begin
  arquivo.Free;
  arquivo := nil;
  FFONT.Free;
  inherited Destroy;
end;

end.
