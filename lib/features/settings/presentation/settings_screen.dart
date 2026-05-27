import 'package:flutter/material.dart';
import 'package:leaflens/core/theme/app_colors.dart';
import 'package:leaflens/core/theme/app_typography.dart';

/// Placeholder screen for the Settings tab.
class SettingsScreen extends StatelessWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.settings_rounded,
            size: 64,
            color: AppColors.white.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Settings',
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
