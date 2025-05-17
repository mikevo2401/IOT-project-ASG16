#include <WiFiClientSecure.h>
WiFiClientSecure client;
client.setCACert(CERTIFICATE);
#include <ArduinoJSON.h>
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