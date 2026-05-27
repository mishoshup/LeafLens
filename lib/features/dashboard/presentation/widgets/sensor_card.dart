import 'package:flutter/material.dart';

import 'package:leaflens/core/theme/app_colors.dart';
import 'package:leaflens/features/dashboard/presentation/widgets/mini_gauge.dart';

/// Sensor reading card displayed on the dashboard.
///
/// Shows a [MiniGauge] on the left, the sensor name and unit icon on the
/// top-right, a status message, and a "More" link at the bottom-right.
class SensorCard extends StatelessWidget {
  /// Creates a [SensorCard].
  const SensorCard({
    required this.sensorName,
    required this.value,
    required this.unit,
    required this.unitIcon,
    required this.statusText,
    required this.gaugeColor,
    required this.onMoreTap,
    super.key,
    this.isStale = false,
  });

  /// Display name (e.g. "Temperature", "Humidity").
  final String sensorName;

  /// Numeric value to display.
  final double value;

  /// Unit string (e.g. "°C", "%").
  final String unit;

  /// Icon representing the unit (e.g. thermometer, water droplet).
  final IconData unitIcon;

  /// Status description (e.g. "Temperature is normal", "Saturated").
  final String statusText;

  /// Colour of the gauge arc.
  final Color gaugeColor;

  /// Called when the user taps "More".
  final VoidCallback onMoreTap;

  /// Whether the reading is stale.
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 191,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          _GaugeSection(value: value, gaugeColor: gaugeColor),
          _InfoSection(
            sensorName: sensorName,
            unitIcon: unitIcon,
            unit: unit,
            statusText: statusText,
          ),
          const _MoreLink(),
        ],
      ),
    );
  }
}

//
// Private widgets
//

class _GaugeSection extends StatelessWidget {
  const _GaugeSection({required this.value, required this.gaugeColor});

  final double value;
  final Color gaugeColor;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: MiniGauge(
          value: value / 100,
          color: gaugeColor,
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.sensorName,
    required this.unitIcon,
    required this.unit,
    required this.statusText,
  });

  final String sensorName;
  final IconData unitIcon;
  final String unit;
  final String statusText;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 160,
      right: 16,
      top: 20,
      bottom: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SensorTitle(name: sensorName),
          const SizedBox(height: 4),
          _UnitRow(icon: unitIcon, unit: unit),
          const Spacer(),
          _StatusText(text: statusText),
        ],
      ),
    );
  }
}

class _SensorTitle extends StatelessWidget {
  const _SensorTitle({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: AppColors.offBlack,
      ),
    );
  }
}

class _UnitRow extends StatelessWidget {
  const _UnitRow({required this.icon, required this.unit});

  final IconData icon;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: AppColors.offBlack),
        const SizedBox(width: 4),
        Text(
          unit,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.offBlack,
          ),
        ),
      ],
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        fontSize: 16,
        color: AppColors.darkGreenText,
      ),
    );
  }
}

class _MoreLink extends StatelessWidget {
  const _MoreLink();

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      right: 16,
      bottom: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'More',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: AppColors.offBlack,
            ),
          ),
          SizedBox(width: 4),
          Icon(
            Icons.double_arrow,
            size: 20,
            color: AppColors.offBlack,
          ),
        ],
      ),
    );
  }
}
