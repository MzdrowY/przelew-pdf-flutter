import 'package:flutter/material.dart';
import '../../core/theme/app_theme_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expanded;
  final IconData? icon;
  final bool isOutlined;
  final bool gradient;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.expanded = true,
    this.icon,
    this.isOutlined = false,
    this.gradient = true,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = isOutlined ? colors.textPrimary : Colors.white;

    final child = isLoading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: foreground),
                const SizedBox(width: 8),
              ],
              Text(label, style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: foreground,
                letterSpacing: 0.3,
              )),
            ],
          );

    final button = gradient && !isOutlined
        ? Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.primaryGlow],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: colors.isDark ? 0.20 : 0.35),
                  blurRadius: 12,
                  spreadRadius: -2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : onPressed,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: height,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  child: child,
                ),
              ),
            ),
          )
        : isOutlined
            ? OutlinedButton(
                onPressed: isLoading ? null : onPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textPrimary,
                  side: BorderSide(color: colors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  minimumSize: Size(44, height),
                ),
                child: child,
              )
            : ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                child: child,
              );

    if (expanded) return SizedBox(width: double.infinity, child: button);
    return button;
  }
}
