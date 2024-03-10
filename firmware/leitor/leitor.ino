  
#include "BluetoothSerial.h"

  
BluetoothSerial SerialBT;

//Função CallBack
void callback(esp_spp_cb_event_t event, esp_spp_cb_param_t *param){
  if(event == ESP_SPP_SRV_OPEN_EVT){
    Serial.println("Client Connected");
  }
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
  // put your setup code here, to run once:
  Start_BTSerial();
}

void loop() {
  // put your main code here, to run repeatedly:

}
