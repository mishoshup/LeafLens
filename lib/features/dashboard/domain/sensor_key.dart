/// Maps to ThingsBoard telemetry keys from the dual-ESP32 setup.
///
/// ESP32 #1 (env): soil_moisture, temperature, humidity
/// ESP32 #2 (water): water_level
enum SensorKey {
  /// Soil moisture percentage sensor.
  soilMoisture('soil_moisture', '%'),

  /// Ambient temperature in Celsius.
  temperature('temperature', '°C'),

  /// Ambient humidity percentage.
  humidity('humidity', '%'),

  /// Water tank level percentage.
  waterLevel('water_level', '%');

  const SensorKey(this.tbKey, this.unit);

  /// The ThingsBoard telemetry key for this sensor.
  final String tbKey;

  /// The display unit for this sensor (e.g. '%', '°C').
  final String unit;

  /// Resolves a ThingsBoard telemetry key to the corresponding [SensorKey].
  /// Throws a [StateError] if the key is unknown.
  static SensorKey fromTbKey(String key) =>
      values.firstWhere((k) => k.tbKey == key);
}
