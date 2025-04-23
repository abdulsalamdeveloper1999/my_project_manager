import 'package:flutter/material.dart';
import '../theme/theme_provider.dart';

/// A custom card widget with soft shadows replacing the standard Card widget
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final double? height;
  final double? width;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.height,
    this.width,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = CustomThemeExtension.of(context);

    final cardWidget = Container(
      height: height,
      width: width,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color ?? theme.cardTheme.color ?? Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: [customTheme.cardShadow],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}
