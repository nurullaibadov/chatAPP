import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

enum ButtonVariant { primary, secondary, outline, ghost, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? height;
  final double? width;
  final Widget? child;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.height,
    this.width,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color foregroundColor;
    Color? borderColor;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = AppColors.primary;
        foregroundColor = Colors.white;
        break;
      case ButtonVariant.secondary:
        backgroundColor = AppColors.secondary;
        foregroundColor = Colors.white;
        break;
      case ButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.primary;
        borderColor = AppColors.primary;
        break;
      case ButtonVariant.ghost:
        backgroundColor = isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant;
        foregroundColor = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;
        break;
      case ButtonVariant.danger:
        backgroundColor = AppColors.error;
        foregroundColor = Colors.white;
        break;
    }

    final btn = SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height ?? 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withAlpha(150),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 1.5)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: foregroundColor,
                ),
              )
            : child ??
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (leadingIcon != null) ...
                    [
                      Icon(leadingIcon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: foregroundColor,
                      ),
                    ),
                    if (trailingIcon != null) ...
                    [
                      const SizedBox(width: 8),
                      Icon(trailingIcon, size: 20),
                    ],
                  ],
                ),
      ),
    );

    return btn.animate().fadeIn(duration: 200.ms);
  }
}
