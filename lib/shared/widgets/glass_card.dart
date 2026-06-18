import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double borderRadius;
  final bool hasGlow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius = 16.0,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final childWidget = Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    if (colors.isDark) {
      return Stack(
        children: [
          if (hasGlow)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              bottom: 10,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: RadialGradient(
                    center: const Alignment(0.3, -0.5),
                    radius: 0.8,
                    colors: [colors.primaryGlow.withValues(alpha: 0.10), Colors.transparent],
                  ),
                ),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.surface.withValues(alpha: 0.7),
                      colors.surface.withValues(alpha: 0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: colors.border.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.03),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: onTap != null
                    ? InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: childWidget,
                      )
                    : childWidget,
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colors.border,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              child: childWidget,
            )
          : childWidget,
    );
  }
}
