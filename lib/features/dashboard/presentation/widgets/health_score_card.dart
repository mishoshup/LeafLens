import 'package:flutter/material.dart';

import 'package:leaflens/core/theme/app_colors.dart';
import 'package:leaflens/features/dashboard/presentation/widgets/mini_gauge.dart';

/// Overall health score card displayed at the bottom of the sensor list.
///
/// Shows the GHS gauge, a combined status message, and an optional
/// warning line when the plant needs immediate attention.
class HealthScoreCard extends StatelessWidget {
  /// Creates a [HealthScoreCard].
  const HealthScoreCard({
    required this.score,
    required this.statusText,
    required this.gaugeColor,
    super.key,
    this.warningText,
  });

  /// GHS score as a percentage (0–100).
  final double score;

  /// Combined status description.
  final String statusText;

  /// Colour of the gauge arc.
  final Color gaugeColor;

  /// Optional warning line shown below the status (e.g. "STOP WATERING!").
  final String? warningText;

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
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: MiniGauge(
                value: score / 100,
                color: gaugeColor,
              ),
            ),
          ),
          _InfoSection(
            statusText: statusText,
            warningText: warningText,
          ),
        ],
      ),
    );
  }
}

//
// Private widgets
//

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.statusText, this.warningText});

  final String statusText;
  final String? warningText;

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
          const Text(
            'Health Score',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              fontSize: 20,
              color: AppColors.offBlack,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            statusText,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              fontSize: 16,
              color: AppColors.offBlack,
            ),
          ),
          if (warningText != null) ...[
            const SizedBox(height: 8),
            Text(
              warningText!,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                fontSize: 16,
                color: AppColors.warningText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
