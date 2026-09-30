/*
  Dinamometro Digital - firmware do leitor (ESP32 + HX711)
  Autor: Marcelo Maurin Martins <marcelomaurinmartins@gmail.com>
  FATEC Ribeirao Preto - Sistemas Biomedicos

  Versao 1.2
  ----------
  - Leitura nao bloqueante do HX711 (sem delay no loop), filtro de mediana movel.
  - Mesma saida na USB (Serial) e no Bluetooth (SerialBT).
  - Taxa de envio fixa e configuravel (padrao 100 ms), boa para graficos forca x tempo.
  - Boot rapido: o zero e medido automaticamente (sem as esperas de 10 s).
  - Comandos por USB ou Bluetooth (ver HELP).

  Protocolo de saida (compativel com o app desktop 1.4+):
      Peso:<inteiro>\n
    <inteiro> = contagens brutas do HX711 menos o zero do equipamento.
    A conversao para gramas/Newtons (tara e fator de calibracao) e feita no app.
    Linhas que comecam com '#' sao mensagens informativas e devem ser ignoradas.

  Comandos (terminados em \n, sem diferenciar maiusculas):
      ZERO | TARA     refaz o zero do equipamento (retire a carga antes)
      RATE <ms>       intervalo de envio, 20..5000 ms
      INFO            versao, zero atual e estado do sensor
      HELP | ?        lista de comandos

  Bibliotecas: HX711 (bogde) e BluetoothSerial (core ESP32).
*/

#include <Arduino.h>
#include "BluetoothSerial.h"
#include "HX711.h"

#define FW_VERSION "1.2"

// ---------------- Configuracao ----------------
const int      LOADCELL_DOUT_PIN = 18;
const int      LOADCELL_SCK_PIN  = 19;
const char    *BT_NAME           = "PESO";
const uint32_t SERIAL_BAUD       = 115200;

const uint8_t  MEDIAN_WINDOW     = 3;      // mediana de 3: remove picos com pouco atraso
const uint8_t  ZERO_SAMPLES      = 20;     // amostras para medir o zero
const uint32_t DEFAULT_PERIOD_MS = 100;    // intervalo padrao de envio
const uint32_t SENSOR_TIMEOUT_MS = 1000;   // sem amostra por esse tempo => sensor ausente

// ---------------- Estado ----------------
HX711 scale;
BluetoothSerial SerialBT;

volatile bool btConnected = false;

long     samples[MEDIAN_WINDOW];
uint8_t  sampleCount  = 0;
uint8_t  sampleIndex  = 0;
long     zeroOffset   = 0;
uint32_t sendPeriodMs = DEFAULT_PERIOD_MS;
uint32_t lastSendMs   = 0;
uint32_t lastSampleMs = 0;
uint32_t lastWarnMs   = 0;
bool     sensorOk     = false;

String   serialCmd;
String   btCmd;

// ---------------- Saida ----------------
// Envia a mesma linha para USB e Bluetooth (se houver cliente).
void out(const String &line)
{
  Serial.println(line);
  if (btConnected)
    SerialBT.println(line);
}

void info(const String &msg)
{
  out("# " + msg);
}

// ---------------- Bluetooth ----------------
void btCallback(esp_spp_cb_event_t event, esp_spp_cb_param_t *param)
{
  (void)param;
  if (event == ESP_SPP_SRV_OPEN_EVT)
    btConnected = true;
  else if (event == ESP_SPP_CLOSE_EVT)
    btConnected = false;
}

// ---------------- Filtro ----------------
void pushSample(long v)
{
  samples[sampleIndex] = v;
  sampleIndex = (sampleIndex + 1) % MEDIAN_WINDOW;
  if (sampleCount < MEDIAN_WINDOW)
    sampleCount++;
}

long medianSample()
{
  long tmp[MEDIAN_WINDOW];
  for (uint8_t i = 0; i < sampleCount; i++)
    tmp[i] = samples[i];

  // insertion sort (janela pequena)
  for (uint8_t i = 1; i < sampleCount; i++)
  {
    long key = tmp[i];
    int8_t j = i - 1;
    while (j >= 0 && tmp[j] > key)
    {
      tmp[j + 1] = tmp[j];
      j--;
    }
    tmp[j + 1] = key;
  }
  return tmp[sampleCount / 2];
}

// ---------------- Sensor ----------------
bool measureZero()
{
  if (!scale.wait_ready_timeout(SENSOR_TIMEOUT_MS))
    return false;

  zeroOffset  = scale.read_average(ZERO_SAMPLES);
  sampleCount = 0;
  sampleIndex = 0;
  return true;
}

void readSensor()
{
  // Nao bloqueia: so le quando o HX711 tem amostra pronta (~10 SPS ou 80 SPS).
  if (scale.is_ready())
  {
    pushSample(scale.read());
    lastSampleMs = millis();
    if (!sensorOk)
    {
      sensorOk = true;
      info("HX711 OK");
    }
  }
  else if (millis() - lastSampleMs > SENSOR_TIMEOUT_MS)
  {
    sensorOk = false;
    sampleCount = 0;
  }
}

void sendReading()
{
  uint32_t now = millis();
  if (now - lastSendMs < sendPeriodMs)
    return;
  lastSendMs = now;

  if (!sensorOk || sampleCount == 0)
  {
    if (now - lastWarnMs > 3000)
    {
      lastWarnMs = now;
      info("ERRO: HX711 nao responde - verifique a ligacao (DOUT=" +
           String(LOADCELL_DOUT_PIN) + ", SCK=" + String(LOADCELL_SCK_PIN) + ")");
    }
    return;
  }

  out("Peso:" + String(medianSample() - zeroOffset));
}

// ---------------- Comandos ----------------
void printHelp()
{
  info("Comandos: ZERO|TARA, RATE <ms>, INFO, HELP");
}

void printInfo()
{
  info("Dinamometro firmware " FW_VERSION " - Marcelo Maurin Martins");
  info("Zero=" + String(zeroOffset) + " Intervalo=" + String(sendPeriodMs) +
       "ms Sensor=" + String(sensorOk ? "OK" : "AUSENTE") +
       " BT=" + String(btConnected ? "conectado" : "livre"));
}

void handleCommand(String cmd)
{
  cmd.trim();
  if (cmd.length() == 0)
    return;
  cmd.toUpperCase();

  if (cmd == "ZERO" || cmd == "TARA")
  {
    info("Zerando... mantenha o dinamometro sem carga.");
    if (measureZero())
      info("Zero=" + String(zeroOffset));
    else
      info("ERRO: HX711 nao responde, zero nao alterado.");
  }
  else if (cmd.startsWith("RATE"))
  {
    long ms = cmd.substring(4).toInt();
    if (ms >= 20 && ms <= 5000)
    {
      sendPeriodMs = (uint32_t)ms;
      info("Intervalo=" + String(sendPeriodMs) + "ms");
    }
    else
      info("ERRO: use RATE <20..5000>");
  }
  else if (cmd == "INFO")
    printInfo();
  else if (cmd == "HELP" || cmd == "?")
    printHelp();
  else
    info("Comando desconhecido: " + cmd);
}

// Acumula caracteres ate \n (ou \r) e executa o comando.
void pollStream(Stream &s, String &buf)
{
  while (s.available())
  {
    char c = (char)s.read();
    if (c == '\n' || c == '\r')
    {
      if (buf.length() > 0)
        handleCommand(buf);
      buf = "";
    }
    else if (buf.length() < 32)
      buf += c;
  }
}

// ---------------- Arduino ----------------
void setup()
{
  Serial.begin(SERIAL_BAUD);
  delay(200);

  // 80 MHz e suficiente e deixa a temporizacao do HX711 mais folgada.
  // (O Bluetooth exige no minimo 80 MHz.)
  setCpuFrequencyMhz(80);

  info("Dinamometro firmware " FW_VERSION);

  scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN);

  SerialBT.register_callback(btCallback);
  if (SerialBT.begin(BT_NAME))
    info(String("Bluetooth pronto: ") + BT_NAME);
  else
    info("ERRO: falha ao iniciar Bluetooth");

  info("Medindo zero... mantenha o dinamometro sem carga.");
  delay(500); // estabilizacao do sensor
  if (measureZero())
  {
    sensorOk = true;
    lastSampleMs = millis();
    info("Zero=" + String(zeroOffset));
  }
  else
    info("ERRO: HX711 nao encontrado. Envie ZERO depois de corrigir a ligacao.");

  printHelp();
}

void loop()
{
  pollStream(Serial, serialCmd);
  pollStream(SerialBT, btCmd);
  readSensor();
  sendReading();
}
