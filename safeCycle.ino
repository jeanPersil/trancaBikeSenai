#include <WiFi.h>
#include <Firebase_ESP_Client.h>

#define WIFI_SSID "note 12 iwin"
#define WIFI_PASSWORD "iwinlb04"

#define API_KEY "AIzaSyCELZUB4BzaezA4rZiYMERuQ6DF40ULL_A"
#define DATABASE_URL "ledwoki-default-rtdb.firebaseio.com"
#define USER_EMAIL "teste003@gmail.com"
#define USER_PASSWORD "123456789"

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

unsigned long sendDataPrevMillis = 0;
const int numReadings = 10;
const int readingDelay = 50;   

int led = 26;
int trigPin = 16;
int echoPin = 17;
int buzzer = 27;

int estado_fechadura = 0; 

void fechar_fechadura();
void abrir_fechadura();

void setup() {
  pinMode(led, OUTPUT); 
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode (buzzer, OUTPUT); 
  Serial.begin(115200);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Conectando ao Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.println(".");
    delay(1000);
  }
  Serial.println("\nConectado ao Wi-Fi com IP: " + WiFi.localIP().toString());

  // Configuração do Firebase
  config.api_key = API_KEY;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  config.database_url = DATABASE_URL;
  Firebase.reconnectNetwork(true);
  config.timeout.serverResponse = 10 * 1000;   

  Firebase.begin(&config, &auth);   
  Firebase.setDoubleDigits(5);   
  fbdo.setBSSLBufferSize(1024, 1024);   
  fbdo.setResponseSize(1024);   
  Serial.println("Conectado ao Firebase");   
}

void loop() {

  if (Firebase.ready()) {
    if (Firebase.RTDB.getInt(&fbdo, "/tranca/fechadura")) {
      estado_fechadura = fbdo.intData();
      Serial.print("Estado lido do Firebase: ");
      Serial.println(estado_fechadura);
    } else {
      Serial.print("Falha ao ler do Firebase: ");
      Serial.println(fbdo.errorReason());
    }
  }

  switch (estado_fechadura) {
    case 0:
      Serial.println("Estado: 0 - ABRIR A FECHADURA");
      Serial.println(estado_fechadura);
      abrir_fechadura();
      break;
    
    case 1: 
      digitalWrite(trigPin, LOW);
      delayMicroseconds(2);
      digitalWrite(trigPin, HIGH);
      delayMicroseconds(10);
      digitalWrite(trigPin, LOW);
      long duration = pulseIn(echoPin, HIGH);
      float distance = duration * 0.034 / 2;
      Serial.println("DISTANCIA SENSOR");
      Serial.println(distance);


      Serial.println(estado_fechadura);
      Serial.println("Estado: 1 - FECHAR A FECHADURA");
      Serial.println(distance);
      fechar_fechadura();
      if (distance < 10) {
        Serial.println("DISPARAR ALARME");
        tone(buzzer, 1000); 
      }else{
        noTone(buzzer);
      }
      break;
  }

  delay(500); 
}

void fechar_fechadura() {
  digitalWrite(led, 0); 
}

void abrir_fechadura() {
  digitalWrite(led, 1);
}