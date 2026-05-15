import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  // Figma design canvas: 402 × 874
  static const double _dW = 402;
  static const double _dH = 874;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final sx = constraints.maxWidth / _dW;
          final sy = constraints.maxHeight / _dH;

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // ── 1. Background ──────────────────────────────────
              Container(color: AppColors.lightGreenBg),

              // ── 2. Decorative circle (bleeds outside frame) ────
              Positioned(
                left: 55 * sx,
                top: 149 * sy,
                child: SvgPicture.asset(
                  'assets/images/splash_ellipse.svg',
                  width: 630 * sx,
                  height: 691 * sy,
                ),
              ),

              // ── 3. Leaf plant illustration ─────────────────────
              Positioned(
                left: 113 * sx,
                top: 336 * sy,
                child: SvgPicture.asset(
                  'assets/images/splash_illustration.svg',
                  width: 156.71 * sx,
                  height: 202.7 * sy,
                ),
              ),

              // ── 4. Brand name ──────────────────────────────────
              Positioned(
                left: 144 * sx,
                top: 552 * sy,
                child: Text(
                  'LEAFLENS',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 24 * sx,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1,
                  ),
                ),
              ),

              // ── 5. Leaf icon (top-right of brand name) ─────────
              Positioned(
                left: 258 * sx,
                top: 540 * sy,
                child: SvgPicture.asset(
                  'assets/images/icon_leaf.svg',
                  width: 24 * sx,
                  height: 24 * sy,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),

              // ── 6. Get Started button ──────────────────────────
              Positioned(
                left: 22 * sx,
                top: 672 * sy,
                child: GestureDetector(
                  onTap: () {},
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50 * sx),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 359 * sx,
                        height: 80 * sy,
                        decoration: BoxDecoration(
                          color: AppColors.deepGreen.withValues(alpha: 0.69),
                          borderRadius: BorderRadius.circular(50 * sx),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Get Started',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            fontSize: 28 * sx,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
