import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Reusable Glassmorphism and Luxury Neobank Widget Decorations
class GlassDecorations {
  const GlassDecorations._();

  /// Standard Glass Card Decoration
  static BoxDecoration card({
    BorderRadius? borderRadius,
    Color backgroundColor = const Color(0x1A1E293B),
    Color borderColor = const Color(0x26FFFFFF),
    double borderWidth = 1.0,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      border: Border.all(
        color: borderColor,
        width: borderWidth,
      ),
      boxShadow: shadows ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
    );
  }

  /// Neon Glowing Glass Card
  static BoxDecoration glowingCard({
    required Color glowColor,
    BorderRadius? borderRadius,
    double glowOpacity = 0.25,
  }) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      border: Border.all(
        color: glowColor.withValues(alpha: 0.4),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: glowColor.withValues(alpha: glowOpacity),
          blurRadius: 24,
          spreadRadius: -4,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Interactive Action Pill / Button Container
  static BoxDecoration pillAction({
    Color backgroundColor = AppColors.surfaceLight,
    Color borderColor = const Color(0x1FFFFFFF),
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor, width: 1),
    );
  }
}

/// Glassmorphic Frosted Container with BackdropFilter
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.blur = 16.0,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(20);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBg = backgroundColor ??
        (isDark ? const Color(0x1A1E293B) : const Color(0xF0FFFFFF));
    final effectiveBorder = borderColor ??
        (isDark ? const Color(0x26FFFFFF) : const Color(0x1A000000));

    Widget container = ClipRRect(
      borderRadius: effectiveRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: effectiveRadius,
            border: Border.all(
              color: effectiveBorder,
              width: borderWidth,
            ),
            boxShadow: isDark
                ? null
                : const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      container = Padding(padding: margin!, child: container);
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: effectiveRadius,
          onTap: onTap,
          child: container,
        ),
      );
    }

    return container;
  }
}
