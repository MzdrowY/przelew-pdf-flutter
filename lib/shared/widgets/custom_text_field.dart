import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final IconData? leadingIcon;

  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.focusNode,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    Widget? prefix;
    if (leadingIcon != null) {
      prefix = Padding(
        padding: const EdgeInsets.only(left: 12, right: 4),
        child: Icon(leadingIcon, size: 18, color: AppColors.textTertiary),
      );
    } else if (prefixIcon != null) {
      prefix = Padding(padding: const EdgeInsets.only(left: 8), child: prefixIcon);
    }

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      onChanged: onChanged,
      focusNode: focusNode,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontFamily: 'Inter',
        letterSpacing: 0.2,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.field,
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 12, fontFamily: 'Inter'),
        prefixIcon: prefix,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2A2A3E), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF7C75FF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0454B), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0454B), width: 1.5),
        ),
      ),
    );
  }
}
