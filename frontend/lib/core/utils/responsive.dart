import 'package:flutter/material.dart';

/// Breakpoints
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Shorthand responsive helpers
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isMobile => screenWidth < Breakpoints.mobile;
  bool get isTablet =>
      screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.desktop;
  bool get isDesktop => screenWidth >= Breakpoints.desktop;

  /// Max content width for centered layouts on wide screens
  double get contentMaxWidth => isDesktop ? 1100 : double.infinity;

  /// Horizontal padding that scales with screen size
  double get horizontalPadding {
    if (isDesktop) return 48;
    if (isTablet) return 32;
    return 20;
  }
}

/// Switches between mobile, tablet, desktop widgets automatically
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.desktop && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= Breakpoints.mobile &&
            tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}

/// Centers content with a max width — useful for web desktop views
class CenteredConstraint extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const CenteredConstraint({
    super.key,
    required this.child,
    this.maxWidth = 480,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
