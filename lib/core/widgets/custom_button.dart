import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../constants/app_constants.dart';

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final Widget? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Color getBackgroundColor() {
      if (backgroundColor != null) return backgroundColor!;
      
      switch (type) {
        case ButtonType.primary:
          return ThemeProvider.primary(context);
        case ButtonType.secondary:
          return ThemeProvider.secondary(context);
        case ButtonType.outline:
          return Colors.transparent;
        case ButtonType.text:
          return Colors.transparent;
      }
    }
    
    Color getTextColor() {
      if (textColor != null) return textColor!;
      
      switch (type) {
        case ButtonType.primary:
        case ButtonType.secondary:
          return ThemeProvider.onPrimary(context);
        case ButtonType.outline:
        case ButtonType.text:
          return ThemeProvider.primary(context);
      }
    }
    
    BorderSide? getBorder() {
      switch (type) {
        case ButtonType.outline:
          return BorderSide(color: ThemeProvider.primary(context), width: 1);
        default:
          return null;
      }
    }
    
    Widget buildContent() {
      if (isLoading) {
        return SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(getTextColor()),
          ),
        );
      }
      
      if (icon != null) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon!,
            const SizedBox(width: 8),
            Text(text),
          ],
        );
      }
      
      return Text(text);
    }
    
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: getBackgroundColor(),
      foregroundColor: getTextColor(),
      minimumSize: Size(
        width ?? double.infinity,
        height ?? AppConstants.buttonHeight,
      ),
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppConstants.defaultBorderRadius,
        ),
        side: getBorder() ?? BorderSide.none,
      ),
      elevation: type == ButtonType.text ? 0 : null,
    );
    
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: buildContent(),
    );
  }
}