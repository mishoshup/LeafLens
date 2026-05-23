/// Maps to ThingsBoard telemetry keys from the dual-ESP32 setup.
///
/// ESP32 #1 (env): soil_moisture, temperature, humidity
/// ESP32 #2 (water): water_level
enum SensorKey {
  soilMoisture('soil_moisture', '%'),
  temperature('temperature', '°C'),
  humidity('humidity', '%'),
  waterLevel('water_level', '%');

  final String tbKey;
  final String unit;

  const SensorKey(this.tbKey, this.unit);

  static SensorKey fromTbKey(String key) =>
      values.firstWhere((k) => k.tbKey == key);
}
