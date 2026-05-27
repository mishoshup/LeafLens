import 'package:flutter/material.dart';
import 'package:leaflens/core/theme/app_colors.dart';
import 'package:leaflens/core/theme/app_typography.dart';

/// Placeholder screen for the Stats / Graphs tab.
class StatsScreen extends StatelessWidget {
  /// Creates a [StatsScreen].
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 64,
            color: AppColors.white.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            '30-Day Trends',
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
