/*
  Dinamometro Digital - firmware do leitor (ESP32 + HX711)
  Autor: Marcelo Maurin Martins - marcelomaurinmartins@gmail.com
  FATEC Ribeirao Preto - Sistemas Biomedicos

  Versao 2.0
  - Envia a leitura BRUTA do HX711 (contagens do ADC). Tara e calibracao
    ficam no software do PC, num lugar so: o zero nao se perde mais quando
    o ESP32 reinicia, e o fator de calibracao salvo no PC continua valendo.
  - Leitura nao bloqueante: cada amostra do HX711 e enviada assim que fica
    pronta (10 SPS com o pino RATE do HX711 em GND, 80 SPS com RATE em VCC).
  - Cada amostra leva o tempo do ESP32 em milissegundos, para o grafico
    Forca x Tempo nao depender do atraso do Bluetooth.
  - Mesma saida na serial USB e no Bluetooth.
  - Comandos de texto (USB ou Bluetooth), um por linha:
      INFO    versao e identificacao
      STATUS  taxa de amostragem medida, ultima leitura, Bluetooth
      START   liga o envio de amostras (padrao)
      STOP    desliga o envio de amostras
      PING    responde PONG

  Protocolo de saida (uma linha por mensagem, terminada em \n):
      D,<ms>,<bruto>     amostra: tempo desde o boot (ms) e contagens do ADC
      E,<ms>,<codigo>    erro: SAT (ADC saturado / celula desconectada),
                         NOHX711 (HX711 sem responder)
      # texto            mensagem informativa (o PC ignora)

  Biblioteca: "HX711" de Rob Tillaart (Gerenciador de Bibliotecas do Arduino).
*/

#include <Arduino.h>
#include "BluetoothSerial.h"
#include "HX711.h"

#define FW_VERSION  "2.0"
#define BT_NAME     "PESO"

// Ligacoes do HX711
const uint8_t LOADCELL_DOUT_PIN = 18;
const uint8_t LOADCELL_SCK_PIN  = 19;

// Limites do ADC de 24 bits do HX711: valores fixos nesses extremos indicam
// celula saturada, fio solto ou celula desconectada.
const long ADC_MAX = 8388607L;
const long ADC_MIN = -8388608L;

// Sem amostra por esse tempo = HX711 nao responde
const uint32_t HX711_TIMEOUT_MS = 1000;

HX711 scale;
BluetoothSerial SerialBT;

volatile bool btConectado = false;
bool enviando = true;

long     ultimaLeitura   = 0;
uint32_t ultimaAmostraMs = 0;
uint32_t ultimoErroMs    = 0;

// Medida da taxa de amostragem real
uint32_t contAmostras    = 0;
uint32_t janelaInicioMs  = 0;
float    taxaSps         = 0.0f;

// Buffers de comando (um por canal, tamanho limitado)
const size_t CMD_MAX = 32;
char   cmdUsb[CMD_MAX];
size_t cmdUsbLen = 0;
char   cmdBt[CMD_MAX];
size_t cmdBtLen = 0;

// ---------------------------------------------------------------------------
// Saida: tudo que o PC precisa ver vai para os dois canais
// ---------------------------------------------------------------------------
void enviaLinha(const char *linha)
{
  Serial.println(linha);
  if (btConectado) {
    SerialBT.println(linha);
  }
}

void enviaInfo(const char *texto)
{
  char buf[96];
  snprintf(buf, sizeof(buf), "# %s", texto);
  enviaLinha(buf);
}

void enviaErro(uint32_t ms, const char *codigo)
{
  char buf[48];
  snprintf(buf, sizeof(buf), "E,%lu,%s", (unsigned long)ms, codigo);
  enviaLinha(buf);
}

// ---------------------------------------------------------------------------
// Bluetooth
// ---------------------------------------------------------------------------
void btCallback(esp_spp_cb_event_t event, esp_spp_cb_param_t *param)
{
  if (event == ESP_SPP_SRV_OPEN_EVT) {
    btConectado = true;
  } else if (event == ESP_SPP_CLOSE_EVT) {
    btConectado = false;
  }
}

void iniciaBluetooth()
{
  SerialBT.register_callback(btCallback);
  if (SerialBT.begin(BT_NAME)) {
    Serial.println("# Bluetooth iniciado como " BT_NAME);
  } else {
    Serial.println("# ERRO ao iniciar o Bluetooth");
  }
}

// ---------------------------------------------------------------------------
// Comandos
// ---------------------------------------------------------------------------
void cmdInfo()
{
  enviaInfo("Dinamometro Digital firmware " FW_VERSION);
  enviaInfo("Marcelo Maurin Martins - marcelomaurinmartins@gmail.com");
  enviaInfo("Protocolo: D,<ms>,<bruto> | E,<ms>,<codigo>");
}

void cmdStatus()
{
  char buf[96];
  snprintf(buf, sizeof(buf), "STATUS taxa=%.1f SPS, ultima=%ld, envio=%s, bt=%s",
           taxaSps, ultimaLeitura, enviando ? "ON" : "OFF",
           btConectado ? "conectado" : "livre");
  enviaInfo(buf);
}

void executaComando(char *cmd)
{
  // Normaliza: remove espacos nas pontas e passa para maiusculas
  while (*cmd == ' ') cmd++;
  size_t n = strlen(cmd);
  while (n > 0 && (cmd[n - 1] == ' ' || cmd[n - 1] == '\r')) cmd[--n] = '\0';
  for (size_t i = 0; i < n; i++) cmd[i] = toupper((unsigned char)cmd[i]);
  if (n == 0) return;

  if      (strcmp(cmd, "INFO") == 0)   cmdInfo();
  else if (strcmp(cmd, "STATUS") == 0) cmdStatus();
  else if (strcmp(cmd, "START") == 0)  { enviando = true;  enviaInfo("envio ligado"); }
  else if (strcmp(cmd, "STOP") == 0)   { enviando = false; enviaInfo("envio desligado"); }
  else if (strcmp(cmd, "PING") == 0)   enviaInfo("PONG");
  else {
    char buf[64];
    snprintf(buf, sizeof(buf), "comando desconhecido: %s", cmd);
    enviaInfo(buf);
  }
}

// Acumula bytes ate o fim de linha. Linhas longas demais sao descartadas.
void leCanal(Stream &canal, char *buf, size_t &len)
{
  while (canal.available()) {
    char c = (char)canal.read();
    if (c == '\n') {
      buf[len] = '\0';
      executaComando(buf);
      len = 0;
    } else if (len < CMD_MAX - 1) {
      buf[len++] = c;
    } else {
      len = 0;  // estourou: descarta a linha
    }
  }
}

// ---------------------------------------------------------------------------
// Leitura do HX711 (nao bloqueante)
// ---------------------------------------------------------------------------
void leCelula()
{
  uint32_t agora = millis();

  if (!scale.is_ready()) {
    if (agora - ultimaAmostraMs > HX711_TIMEOUT_MS && agora - ultimoErroMs > 2000) {
      enviaErro(agora, "NOHX711");
      ultimoErroMs = agora;
    }
    return;
  }

  long bruto = (long)scale.read();
  ultimaLeitura   = bruto;
  ultimaAmostraMs = agora;

  // Taxa de amostragem medida a cada segundo
  contAmostras++;
  if (agora - janelaInicioMs >= 1000) {
    taxaSps = contAmostras * 1000.0f / (agora - janelaInicioMs);
    contAmostras = 0;
    janelaInicioMs = agora;
  }

  if (!enviando) return;

  if (bruto >= ADC_MAX || bruto <= ADC_MIN) {
    if (agora - ultimoErroMs > 2000) {
      enviaErro(agora, "SAT");
      ultimoErroMs = agora;
    }
    return;
  }

  char buf[40];
  snprintf(buf, sizeof(buf), "D,%lu,%ld", (unsigned long)agora, bruto);
  enviaLinha(buf);
}

// ---------------------------------------------------------------------------
void setup()
{
  Serial.begin(115200);
  delay(200);

  cmdInfo();

  // fastProcessor = true: pulsos de clock mais longos para o ESP32 a 240 MHz,
  // dispensando baixar o clock da CPU (que atrapalhava o Bluetooth).
  scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN, true);

  iniciaBluetooth();

  janelaInicioMs  = millis();
  ultimaAmostraMs = millis();
  enviaInfo("pronto");
}

void loop()
{
  leCanal(Serial, cmdUsb, cmdUsbLen);
  leCanal(SerialBT, cmdBt, cmdBtLen);
  leCelula();
  delay(1);  // cede tempo ao Wi-Fi/Bluetooth; nao limita a taxa do HX711
}
