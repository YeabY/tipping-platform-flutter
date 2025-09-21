import 'package:flutter/material.dart';

enum ButtonVariant {
  elevated,
  outlined,
  text,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final ButtonSize size;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.elevated,
    this.size = ButtonSize.medium,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine button style based on variant
    ButtonStyle buttonStyle;
    Widget buttonChild;
    
    switch (variant) {
      case ButtonVariant.elevated:
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
          disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
          disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
          padding: padding ?? _getPadding(size),
          minimumSize: Size(width ?? 0, height ?? _getHeight(size)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        );
        buttonChild = _buildButtonChild(theme);
        break;
        
      case ButtonVariant.outlined:
        buttonStyle = OutlinedButton.styleFrom(
          foregroundColor: foregroundColor ?? theme.colorScheme.primary,
          side: BorderSide(
            color: backgroundColor ?? theme.colorScheme.primary,
          ),
          disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
          padding: padding ?? _getPadding(size),
          minimumSize: Size(width ?? 0, height ?? _getHeight(size)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
        buttonChild = _buildButtonChild(theme);
        break;
        
      case ButtonVariant.text:
        buttonStyle = TextButton.styleFrom(
          foregroundColor: foregroundColor ?? theme.colorScheme.primary,
          disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
          padding: padding ?? _getPadding(size),
          minimumSize: Size(width ?? 0, height ?? _getHeight(size)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
        buttonChild = _buildButtonChild(theme);
        break;
    }

    // Return appropriate button widget
    switch (variant) {
      case ButtonVariant.elevated:
        return SizedBox(
          width: width,
          height: height ?? _getHeight(size),
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          ),
        );
        
      case ButtonVariant.outlined:
        return SizedBox(
          width: width,
          height: height ?? _getHeight(size),
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          ),
        );
        
      case ButtonVariant.text:
        return SizedBox(
          width: width,
          height: height ?? _getHeight(size),
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          ),
        );
    }
  }

  Widget _buildButtonChild(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(size),
        width: _getIconSize(size),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == ButtonVariant.elevated 
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.primary,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: _getFontSize(size),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: _getFontSize(size),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  EdgeInsetsGeometry _getPadding(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getHeight(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  double _getFontSize(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
    }
  }

  double _getIconSize(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}
