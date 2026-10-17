import 'package:flutter/material.dart';

/// Screen breakpoints for phone, tablet, and desktop/large tablet.
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  static const double phoneMax = 599.0;
  static const double tabletMin = 600.0;
  static const double tabletMax = 1023.0;
  static const double desktopMin = 1024.0;

  static const double maxContentWidth = 1100.0;
  static const double contentCardWidth = 800.0;
}

class Responsive {
  Responsive._();

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < ResponsiveBreakpoints.tabletMin;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= ResponsiveBreakpoints.tabletMin &&
        width < ResponsiveBreakpoints.desktopMin;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= ResponsiveBreakpoints.desktopMin;

  static bool isTabletOrDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= ResponsiveBreakpoints.tabletMin;

  static T value<T>(
    BuildContext context, {
    required T phone,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= ResponsiveBreakpoints.desktopMin && desktop != null) {
      return desktop;
    }
    if (width >= ResponsiveBreakpoints.tabletMin && tablet != null) {
      return tablet;
    }
    return phone;
  }

  /// Calculates optimal cross axis count for product / item grids
  static int gridColumns(
    BuildContext context, {
    int phone = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    return value<int>(
      context,
      phone: phone,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Auto-adaptive product card columns based on container width
  static int adaptiveProductColumns(double width) {
    if (width < 600) return 2;
    if (width < 850) return 3;
    if (width < 1200) return 4;
    return 5;
  }
}

/// An extension on [BuildContext] to simplify responsive lookups.
extension ResponsiveContext on BuildContext {
  bool get isPhone => Responsive.isPhone(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);
  bool get isTabletOrDesktop => Responsive.isTabletOrDesktop(this);

  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  T responsive<T>({
    required T phone,
    T? tablet,
    T? desktop,
  }) =>
      Responsive.value<T>(
        this,
        phone: phone,
        tablet: tablet,
        desktop: desktop,
      );
}

/// A wrapper widget that centers its child and constrains its maximum width.
/// Ideal for forms, lists, cards, and reading content on tablet/desktop.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1100.0,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null
            ? Padding(
                padding: padding!,
                child: child,
              )
            : child,
      ),
    );
  }
}

/// A builder that executes different layouts based on screen type.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) phone;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.phone,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= ResponsiveBreakpoints.desktopMin && desktop != null) {
      return desktop!(context);
    }
    if (width >= ResponsiveBreakpoints.tabletMin && tablet != null) {
      return tablet!(context);
    }
    return phone(context);
  }
}
