  
#include "BluetoothSerial.h"
// Calibrating the load cell
#include <Arduino.h>
#include "soc/rtc.h"
#include "HX711.h"

// HX711 circuit wiring
const int LOADCELL_DOUT_PIN = 18;
const int LOADCELL_SCK_PIN = 19;

//#define CALIBRATION_FACTOR -471.497
//#define CALIBRATION_FACTOR 420.0983
#define CALIBRATION_FACTOR -7050

float scaleFactor = 10000.0; // Valor obtido na calibração com 1 Newton

HX711 scale;

  
BluetoothSerial SerialBT;
int flgconected = 0; //Testa se tem alguem

int reading;
int lastReading;
int refzero = 0;
uint32_t start, stop;
volatile float f;


//Funcoes
void displayWeight(int weight);

//Função CallBack
void callback(esp_spp_cb_event_t event, esp_spp_cb_param_t *param){
  if(event == ESP_SPP_SRV_OPEN_EVT){
    Serial.println("Client Connected");
    flgconected = 1;
  }  
  if(event == ESP_SPP_CLOSE_EVT ){
    Serial.println("Client disconnected");
    flgconected = 0;
  }
}

void Wellcome()
{
  Serial.println("Dinanometro Version 1.0");
  Serial.println("Create Marcelo Maurin Martins");
  Serial.println("Email: marcelomaurinmartins@gmail.com");
}


void Inicializa()
{

  flgconected = 0;

  Serial.println("\nPERFORMANCE");
  start = micros();
  f = 0;
  for (int i = 0; i < 100; i++)
  {
    reading = scale.read_medavg(7);
  }
  refzero = reading;
  stop = micros();
  Serial.print("100x read_medavg(7) = ");
  Serial.println(stop - start);
  Serial.print("  VAL: ");
  Serial.println(reading, 2);
}


void Start_LC()
{
  rtc_cpu_freq_config_t config;
  rtc_clk_cpu_freq_get_config(&config);
  rtc_clk_cpu_freq_to_config(RTC_CPU_FREQ_80M, &config);
  rtc_clk_cpu_freq_set_config_fast(&config);
  Serial.println("Initializing the scale");
  scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN);

  scale.set_scale(CALIBRATION_FACTOR);   // this value is obtained by calibrating the scale with known weights; see the README for details
  scale.tare();               // reset the scale to 0
}
void Start_Serial()
{
  Serial.begin(115200); 
}

void Start_BTSerial()
{   
  //Registrando o Callback da funcao
  SerialBT.register_callback(callback);
 
  if(!SerialBT.begin("ESP32"))
  {
     Serial.println("An error occurred initializing Bluetooth");
  }else
  {
    Serial.println("Bluetooth initialized");
  }
}

void setup() {
  Start_Serial(); 
  Wellcome();
   Start_LC();
  // put your setup code here, to run once:
  Start_BTSerial();
  Tara();  
  Serial.println("Initialize finished!");
}

void Tara()
{
  if (scale.is_ready()) 
  {
    scale.set_scale();    
    Serial.println("Tare... remove any weights from the scale.");
    delay(5000);
    scale.tare();
    Serial.println("Tare done...");
    Serial.print("Place a known weight on the scale...");
    delay(5000);
    //reading = scale.get_units(10);
    reading = scale.read_medavg(7);  
    refzero = reading;
    Serial.print("Tara: ");
    Serial.println(reading);
  } 
  else {
    Serial.println("HX711 not found.");
  }
}

void displayWeight(int weight){
    
  // Display static text
  SerialBT.print("Peso:");
  SerialBT.println(weight);
  Serial.print("Peso: ");
  Serial.println(reading);  
}

void LerLC()
{
  if (scale.wait_ready_timeout(200)) 
  {
    //reading = round(scale.get_units());
    // continuous scale once per second
    reading = scale.read_medavg(7);  

    if (reading != lastReading)
    {
      displayWeight(reading-refzero ); 
    }
  }
}

void LerBT()
{
  while(SerialBT.available())
  {
    Serial.write(SerialBT.read());
  }
}

void Leituras()
{
  LerBT();
  LerLC();
}

void loop() {
  // put your main code here, to run repeatedly:
  Leituras();
  delay(1000);
}
