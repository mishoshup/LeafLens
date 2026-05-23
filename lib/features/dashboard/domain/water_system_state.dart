/// Read-only view of the autonomous water system state.
///
/// ESP32 #2 publishes water_level telemetry and sets shared
/// attributes (refill_active, safety_lockout) that Flutter reads
/// via ThingsBoard attribute subscription.
class WaterSystemState {
  /// Creates a [WaterSystemState] snapshot.
  const WaterSystemState({
    required this.tankLevelPercent,
    required this.refillActive,
    required this.safetyLockout,
    this.lastRefillAt,
  });

  /// The current water tank level as a percentage (0–100).
  final double tankLevelPercent;

  /// Whether the refill pump is currently running.
  final bool refillActive;

  /// Whether the system is in safety lockout mode.
  final bool safetyLockout;

  /// The timestamp of the last refill cycle, if any.
  final DateTime? lastRefillAt;

  /// Whether the tank level is low (below 20%).
  bool get isLow => tankLevelPercent < 20;

  /// Whether the tank level is critically low (below 10%).
  bool get isCritical => tankLevelPercent < 10;
}
