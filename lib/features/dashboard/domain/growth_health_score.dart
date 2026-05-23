import 'package:leaflens/features/dashboard/domain/sensor_key.dart';
import 'package:leaflens/features/dashboard/domain/sensor_reading.dart';

/// Threshold ranges for Growth Health Score computation.
/// Defaults are for fragile indoor plants. User-configurable per species.
class HealthConfig {
  final double soilMoistureMin;
  final double soilMoistureMax;
  final double temperatureMin;
  final double temperatureMax;
  final double humidityMin;
  final double humidityMax;

  const HealthConfig({
    this.soilMoistureMin = 40,
    this.soilMoistureMax = 70,
    this.temperatureMin = 18,
    this.temperatureMax = 28,
    this.humidityMin = 50,
    this.humidityMax = 80,
  });
}

enum HealthStatus { optimal, moderate, caution, danger, critical }

/// Result of a single Growth Health Score computation.
class HealthScoreResult {
  final double score;
  final HealthStatus status;
  final Map<SensorKey, double> componentScores;
  final DateTime computedAt;

  const HealthScoreResult({
    required this.score,
    required this.status,
    required this.componentScores,
    required this.computedAt,
  });

  bool get isCritical => score < 30;
  bool get isDanger => score < 50;
  bool get isOptimal => score >= 80;
}

/// Pure domain logic — zero Flutter imports, fully testable.
class GrowthHealthScore {
  static const _weights = {
    SensorKey.soilMoisture: 0.50,
    SensorKey.temperature: 0.30,
    SensorKey.humidity: 0.20,
  };

  static HealthScoreResult compute(
    Map<SensorKey, SensorReading> readings,
    HealthConfig config,
  ) {
    final scores = <SensorKey, double>{};

    final moisture = readings[SensorKey.soilMoisture]?.value;
    if (moisture != null) {
      scores[SensorKey.soilMoisture] = _bellScore(
        moisture,
        config.soilMoistureMin,
        config.soilMoistureMax,
      );
    }

    final temp = readings[SensorKey.temperature]?.value;
    if (temp != null) {
      scores[SensorKey.temperature] = _bellScore(
        temp,
        config.temperatureMin,
        config.temperatureMax,
      );
    }

    final humidity = readings[SensorKey.humidity]?.value;
    if (humidity != null) {
      scores[SensorKey.humidity] = _bellScore(
        humidity,
        config.humidityMin,
        config.humidityMax,
      );
    }

    var totalWeight = 0.0;
    var weightedSum = 0.0;
    for (final entry in scores.entries) {
      final weight = _weights[entry.key] ?? 0.0;
      weightedSum += entry.value * weight;
      totalWeight += weight;
    }

    final score =
        totalWeight > 0 ? (weightedSum / totalWeight) * 100 : 0.0;

    return HealthScoreResult(
      score: score.clamp(0.0, 100.0),
      status: _statusFrom(score),
      componentScores: scores,
      computedAt: DateTime.now(),
    );
  }

  /// Bell curve: 1.0 at midpoint, 0.0 at or beyond bounds.
  static double _bellScore(double value, double min, double max) {
    if (value < min || value > max) return 0.0;
    final mid = (min + max) / 2;
    final range = (max - min) / 2;
    return 1.0 - (value - mid).abs() / range;
  }

  static HealthStatus _statusFrom(double score) => switch (score) {
        >= 80 => HealthStatus.optimal,
        >= 65 => HealthStatus.moderate,
        >= 50 => HealthStatus.caution,
        >= 30 => HealthStatus.danger,
        _ => HealthStatus.critical,
      };
}
