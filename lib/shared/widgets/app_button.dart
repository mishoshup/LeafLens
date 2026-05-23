import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, outline, text }

/// Styled button using the app's FilledButton/OutlinedButton theme.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
          onPressed: loading ? null : onPressed,
          child: child,
        ),
      AppButtonVariant.secondary => FilledButton.tonal(
          onPressed: loading ? null : onPressed,
          child: child,
        ),
      AppButtonVariant.outline => OutlinedButton(
          onPressed: loading ? null : onPressed,
          child: child,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: loading ? null : onPressed,
          child: child,
        ),
    };

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }
}
