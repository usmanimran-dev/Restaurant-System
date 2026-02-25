import 'package:flutter/material.dart';

/// Breakpoint‑aware layout builder.
///
/// Provides [mobile], [tablet], and [desktop] builders so the caller can
/// supply different widget trees per breakpoint.
class ResponsiveWrapper extends StatelessWidget {
  const ResponsiveWrapper({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Widget tree for screens < 768 px.
  final Widget mobile;

  /// Widget tree for screens 768 – 1199 px. Falls back to [mobile].
  final Widget? tablet;

  /// Widget tree for screens ≥ 1200 px. Falls back to [tablet] then [mobile].
  final Widget? desktop;

  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= desktopBreakpoint) {
          return desktop ?? tablet ?? mobile;
        }
        if (width >= tabletBreakpoint) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}
