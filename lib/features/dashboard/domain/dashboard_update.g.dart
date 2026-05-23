// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TelemetryUpdate _$TelemetryUpdateFromJson(Map<String, dynamic> json) =>
    TelemetryUpdate(
      soilMoisture: (json['soilMoisture'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble(),
      waterLevel: (json['waterLevel'] as num?)?.toDouble(),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$TelemetryUpdateToJson(TelemetryUpdate instance) =>
    <String, dynamic>{
      'soilMoisture': instance.soilMoisture,
      'temperature': instance.temperature,
      'humidity': instance.humidity,
      'waterLevel': instance.waterLevel,
      'type': instance.$type,
    };

GHSUpdate _$GHSUpdateFromJson(Map<String, dynamic> json) => GHSUpdate(
  score: (json['score'] as num).toDouble(),
  status: json['status'] as String,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$GHSUpdateToJson(GHSUpdate instance) => <String, dynamic>{
  'score': instance.score,
  'status': instance.status,
  'type': instance.$type,
};

WaterSystemUpdate _$WaterSystemUpdateFromJson(Map<String, dynamic> json) =>
    WaterSystemUpdate(
      tankLevelPercent: (json['water_level'] as num).toDouble(),
      refillActive: json['refill_active'] as bool,
      safetyLockout: json['safety_lockout'] as bool,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$WaterSystemUpdateToJson(WaterSystemUpdate instance) =>
    <String, dynamic>{
      'water_level': instance.tankLevelPercent,
      'refill_active': instance.refillActive,
      'safety_lockout': instance.safetyLockout,
      'type': instance.$type,
    };

AckUpdate _$AckUpdateFromJson(Map<String, dynamic> json) =>
    AckUpdate(type: json['type'] as String, success: json['success'] as bool);

Map<String, dynamic> _$AckUpdateToJson(AckUpdate instance) => <String, dynamic>{
  'type': instance.type,
  'success': instance.success,
};
