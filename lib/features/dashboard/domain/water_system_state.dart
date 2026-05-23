/// Read-only view of the autonomous water system state.
///
/// ESP32 #2 publishes water_level telemetry and sets shared
/// attributes (refill_active, safety_lockout) that Flutter reads
/// via ThingsBoard attribute subscription.
class WaterSystemState {
  final double tankLevelPercent;
  final bool refillActive;
  final bool safetyLockout;
  final DateTime? lastRefillAt;

  const WaterSystemState({
    required this.tankLevelPercent,
    required this.refillActive,
    required this.safetyLockout,
    this.lastRefillAt,
  });

  bool get isLow => tankLevelPercent < 20;
  bool get isCritical => tankLevelPercent < 10;
}
