import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Decorative SVG positioned with fractional sizing.
///
/// Always occupies [widthFactor] × [heightFactor] of the parent,
/// anchored at [alignment]. Defaults to bottom-right, 60% × 50%.
class BackgroundEllipse extends StatelessWidget {
  final String assetPath;
  final double widthFactor;
  final double heightFactor;
  final Alignment alignment;
  final BoxFit fit;

  const BackgroundEllipse({
    super.key,
    this.assetPath = 'assets/images/splash_ellipse.svg',
    this.widthFactor = 0.9,
    this.heightFactor = 0.9,
    this.alignment = Alignment.bottomRight,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: SvgPicture.asset(assetPath, fit: fit),
      ),
    );
  }
}
