import 'package:flutter_test/flutter_test.dart';
import 'package:leaflens/features/dashboard/domain/sensor_key.dart';

void main() {
  group('SensorKey', () {
    test('has 4 values', () {
      expect(SensorKey.values.length, 4);
    });

    test('soilMoisture has correct tbKey and unit', () {
      expect(SensorKey.soilMoisture.tbKey, 'soil_moisture');
      expect(SensorKey.soilMoisture.unit, '%');
    });

    test('temperature has correct tbKey and unit', () {
      expect(SensorKey.temperature.tbKey, 'temperature');
      expect(SensorKey.temperature.unit, '°C');
    });

    test('humidity has correct tbKey and unit', () {
      expect(SensorKey.humidity.tbKey, 'humidity');
      expect(SensorKey.humidity.unit, '%');
    });

    test('waterLevel has correct tbKey and unit', () {
      expect(SensorKey.waterLevel.tbKey, 'water_level');
      expect(SensorKey.waterLevel.unit, '%');
    });

    group('fromTbKey', () {
      test('resolves soil_moisture', () {
        expect(SensorKey.fromTbKey('soil_moisture'), SensorKey.soilMoisture);
      });

      test('resolves temperature', () {
        expect(SensorKey.fromTbKey('temperature'), SensorKey.temperature);
      });

      test('resolves humidity', () {
        expect(SensorKey.fromTbKey('humidity'), SensorKey.humidity);
      });

      test('resolves water_level', () {
        expect(SensorKey.fromTbKey('water_level'), SensorKey.waterLevel);
      });

      test('throws StateError for unknown key', () {
        expect(
          () => SensorKey.fromTbKey('unknown'),
          throwsA(isA<StateError>()),
        );
      });
    });
  });
}
