#include "Seeed_vl53l0x.h"
Seeed_vl53l0x VL53L0X;
#include "SD/Seeed_SD.h"
#include <Seeed_FS.h>
#include <WiFiClientSecure.h>
WiFiClientSecure client;
client.setCACert(CERTIFICATE);
#include <ArduinoJSON.h>
#include "camera.h"
void setupSDCard(setupSDCard();)
int fileNum = 1;

void saveToSDCard(byte *buffer, uint32_t length)
{
    char buff[16];
    sprintf(buff, "%d.jpg", fileNum);
    fileNum++;

    File outFile = SD.open(buff, FILE_WRITE );
    outFile.write(buffer, length);
    outFile.close();

    Serial.print("Image written to file ");
    Serial.println(buff);
}
Serial.print("Image read to buffer with length ");
Serial.println(length);

saveToSDCard(buffer, length);

delete(buffer);
{
    while (!SD.begin(SDCARD_SS_PIN, SDCARD_SPI))
    {
        Serial.println("SD Card Error");
    }
}
void setupCamera()
{
    pinMode(PIN_SPI_SS, OUTPUT);
    digitalWrite(PIN_SPI_SS, HIGH);

    Wire.begin();
    SPI.begin();

    if (!camera.init())
    {
        Serial.println("Error setting up the camera!");
    }
}setupCamera();
Camera camera = Camera(JPEG, OV2640_640x480);
void classifyImage(byte *buffer, uint32_t length)
{
    HTTPClient httpClient;
    httpClient.begin(client, PREDICTION_URL);
    httpClient.addHeader("Content-Type", "application/octet-stream");
    httpClient.addHeader("Prediction-Key", PREDICTION_KEY);

    int httpResponseCode = httpClient.POST(buffer, length);

    if (httpResponseCode == 200)
    {
        String result = httpClient.getString();

        DynamicJsonDocument doc(1024);
        deserializeJson(doc, result.c_str());

        JsonObject obj = doc.as<JsonObject>();
        JsonArray predictions = obj["predictions"].as<JsonArray>();

        for(JsonVariant prediction : predictions) 
        {
            String tag = prediction["tagName"].as<String>();
            float probability = prediction["probability"].as<float>();

            char buff[32];
            sprintf(buff, "%s:\t%.2f%%", tag.c_str(), probability * 100.0);
            Serial.println(buff);
        }
    }

    httpClient.end();
}
VL53L0X.VL53L0X_common_init();
VL53L0X.VL53L0X_high_accuracy_ranging_init();
VL53L0X_RangingMeasurementData_t RangingMeasurementData;
memset(&RangingMeasurementData, 0, sizeof(VL53L0X_RangingMeasurementData_t));
VL53L0X.PerformSingleRangingMeasurement(&RangingMeasurementData);
Serial.print("Distance = ");
Serial.print(RangingMeasurementData.RangeMilliMeter);
Serial.println(" mm");

delay(1000);
pinMode(WIO_KEY_C, INPUT_PULLUP);
void buttonPressed()
{
    
}
void loop()
{
    if (digitalRead(WIO_KEY_C) == LOW)
    {
        buttonPressed();
        delay(2000);
    }

    delay(200);
}
camera.startCapture();

while (!camera.captureReady())
    delay(100);

Serial.println("Image captured");

byte *buffer;
uint32_t length;

if (camera.readImageToBuffer(&buffer, length))
{
    Serial.print("Image read to buffer with length ");
    Serial.println(length);

    delete(buffer);
}