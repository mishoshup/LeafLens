import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:leaflens/core/theme/app_colors.dart';
import 'package:leaflens/core/theme/app_typography.dart';
import 'package:leaflens/features/auth/data/leaf_lens_auth.dart';
import 'package:leaflens/features/dashboard/presentation/widgets/action_switch.dart';
import 'package:leaflens/features/dashboard/presentation/widgets/health_score_card.dart';
import 'package:leaflens/features/dashboard/presentation/widgets/sensor_card.dart';

/// Main dashboard screen showing live sensor readings, action toggles,
/// and the overall Growth Health Score.
class DashboardScreen extends ConsumerStatefulWidget {
  /// Creates a [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _mistOn = false;
  bool _waterOn = false;
  bool _refillOn = false;

  Future<void> _logout() => LeafLensAuth.signOut();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GreetingHeader(onAvatarTap: _logout),
          const SizedBox(height: 16),
          _ActionSwitchesRow(
            mistOn: _mistOn,
            waterOn: _waterOn,
            refillOn: _refillOn,
            onMistChanged: (v) => setState(() => _mistOn = v),
            onWaterChanged: (v) => setState(() => _waterOn = v),
            onRefillChanged: (v) => setState(() => _refillOn = v),
          ),
          const SizedBox(height: 16),
          const HealthScoreCard(
            score: 62,
            statusText: 'Environment is great but the soil is too wet!',
            gaugeColor: AppColors.gaugeOrange,
            warningText: 'STOP WATERING!',
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 120),
              children: [
                // TODO(danial): Wire to real telemetry data
                SensorCard(
                  sensorName: 'Temperature',
                  value: 26,
                  unit: '°C',
                  unitIcon: Icons.thermostat,
                  statusText: 'Temperature is normal',
                  gaugeColor: AppColors.gaugeGreen,
                  onMoreTap: () {},
                ),
                const SizedBox(height: 12),
                SensorCard(
                  sensorName: 'Humidity',
                  value: 64,
                  unit: '%',
                  unitIcon: Icons.water_drop_outlined,
                  statusText: 'Perfect Environment',
                  gaugeColor: AppColors.gaugeGreen,
                  onMoreTap: () {},
                ),
                const SizedBox(height: 12),
                SensorCard(
                  sensorName: 'Soil Moisture',
                  value: 90,
                  unit: '%',
                  unitIcon: Icons.water_drop,
                  statusText: 'Saturated',
                  gaugeColor: AppColors.redAlert,
                  onMoreTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//
// Private widgets
//

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.onAvatarTap});

  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Avatar(onTap: onAvatarTap),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _timeGreeting(),
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Aishah Abdul Aziz',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppColors.offBlack,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 51,
        decoration: const BoxDecoration(
          color: AppColors.mediumGreen,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            'A',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 32,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionSwitchesRow extends StatelessWidget {
  const _ActionSwitchesRow({
    required this.mistOn,
    required this.waterOn,
    required this.refillOn,
    required this.onMistChanged,
    required this.onWaterChanged,
    required this.onRefillChanged,
  });

  final bool mistOn;
  final bool waterOn;
  final bool refillOn;
  final ValueChanged<bool> onMistChanged;
  final ValueChanged<bool> onWaterChanged;
  final ValueChanged<bool> onRefillChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ActionSwitch(
            icon: Icons.cloud_outlined,
            label: 'Mist',
            value: mistOn,
            onChanged: onMistChanged,
          ),
          const SizedBox(width: 10),
          ActionSwitch(
            icon: Icons.water_drop_outlined,
            label: 'Water',
            value: waterOn,
            onChanged: onWaterChanged,
          ),
          const SizedBox(width: 10),
          ActionSwitch(
            icon: Icons.autorenew,
            label: 'Refill',
            value: refillOn,
            onChanged: onRefillChanged,
          ),
        ],
      ),
    );
  }
}
