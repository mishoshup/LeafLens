import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leaflens/shared/widgets/background_ellipse.dart';
import 'package:leaflens/shared/widgets/leaf_lens_logo.dart';
import 'package:leaflens/theme/app_colors.dart';

/// Per-screen extensions keep build() readable without
/// global namespace pollution.
extension on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  void navigateTo(String route) => go(route);

  TextStyle get brandStyle => const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 28,
    color: AppColors.offWhite,
  );

  TextStyle get taglineStyle => const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 26,
    color: AppColors.offWhite,
    fontStyle: FontStyle.italic,
  );
  TextStyle get buttonStyle => const TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 22,
    color: AppColors.offWhite,
  );
}

/// Splash / onboarding screen shown on first launch.
///
/// Displays the brand logo, tagline, and a "Get Started" button
/// that navigates to the login screen.
class SplashScreen extends StatelessWidget {
  /// Creates a [SplashScreen] widget.
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.lightGreenBg,
      body: Stack(
        children: [
          BackgroundEllipse(),
          SafeArea(child: _SplashContent()),
        ],
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(flex: 4),
          LeafLensLogo(),
          SizedBox(height: 12),
          _BrandHeader(),
          Spacer(flex: 2),
          _GetStartedButton(),
          Spacer(),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('LEAFLENS', style: context.brandStyle),
        const SizedBox(height: 48),
        Text(
          'Smarter Care for\nHealthier Plants ',
          style: context.taglineStyle,
        ),
        // const SizedBox(width: 6),
        // SvgPicture.asset(
        //   'assets/images/icon_leaf.svg',
        //   width: 24,
        //   height: 24,
        //   colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        // ),
      ],
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => context.navigateTo('/login'),
          style: FilledButton.styleFrom(
            backgroundColor: context.colors.primary,
            foregroundColor: context.colors.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: const StadiumBorder(),
          ),
          child: Text('Get Started', style: context.buttonStyle),
        ),
      ),
    );
  }
}
