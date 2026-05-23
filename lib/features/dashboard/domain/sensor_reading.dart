import 'package:leaflens/core/config/app_config.dart';

/// Single telemetry data point with staleness tracking.
class SensorReading {
  final double value;
  final DateTime recordedAt;
  final String unit;

  const SensorReading({
    required this.value,
    required this.recordedAt,
    required this.unit,
  });

  Duration get age => DateTime.now().difference(recordedAt);

  bool get isStale => age > AppConfig.staleThreshold;

  String get ageLabel {
    if (age.inMinutes < 1) return 'just now';
    if (age.inMinutes < 60) return '${age.inMinutes}m ago';
    if (age.inHours < 24) return '${age.inHours}h ago';
    return '${age.inDays}d ago';
  }

  factory SensorReading.fromTbJson(Map<String, dynamic> json, String unit) {
    return SensorReading(
      value: double.parse(json['value'] as String),
      recordedAt: DateTime.fromMillisecondsSinceEpoch(json['ts'] as int),
      unit: unit,
    );
  }
}
