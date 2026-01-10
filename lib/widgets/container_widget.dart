import 'package:flutter/widgets.dart';

/// Universal container widget with customizable styling
///
/// Example usage:
/// ```dart
/// // Basic usage with color
/// ContainerWidget(
///   child: Text('Hello'),
///   color: Colors.blue.withOpacity(0.2),
/// )
///
/// // With custom radius and padding
/// ContainerWidget(
///   child: Icon(Icons.star),
///   color: Colors.amber,
///   borderRadius: 16,
///   padding: EdgeInsets.all(20),
/// )
///
/// // With border and shadow
/// ContainerWidget(
///   child: Text('Premium'),
///   color: Colors.white,
///   borderRadius: 12,
///   border: Border.all(color: Colors.blue, width: 2),
///   boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
/// )
///
/// // With gradient
/// ContainerWidget(
///   child: Text('Gradient'),
///   gradient: LinearGradient(
///     colors: [Colors.purple, Colors.blue],
///   ),
/// )
/// ```
class ContainerWidget extends StatelessWidget {
  /// The child widget to display inside the container
  final Widget child;

  /// Background color of the container (ignored if gradient is provided)
  final Color? color;

  /// Gradient for the container background (overrides color if provided)
  final Gradient? gradient;

  /// Inner padding of the container
  final EdgeInsetsGeometry? padding;

  /// Outer margin of the container
  final EdgeInsetsGeometry? margin;

  /// Width of the container (null for constraints-based width)
  final double? width;

  /// Height of the container (null for constraints-based height)
  final double? height;

  /// Border radius (can be a single value or custom BorderRadius)
  final double? borderRadius;

  /// Custom border radius (overrides borderRadius if provided)
  final BorderRadiusGeometry? customBorderRadius;

  /// Border of the container
  final Border? border;

  /// Box shadow effects
  final List<BoxShadow>? boxShadow;

  /// Alignment of the child widget
  final AlignmentGeometry? alignment;

  /// Custom decoration (overrides all decoration-related properties)
  final Decoration? decoration;

  const ContainerWidget({
    super.key,
    required this.child,
    this.color,
    this.gradient,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.customBorderRadius,
    this.border,
    this.boxShadow,
    this.alignment,
    this.decoration,
  });

  /// Factory constructor for backward compatibility
  factory ContainerWidget.legacy({
    Key? key,
    required Widget widget,
    required Color color,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
  }) {
    return ContainerWidget(
      key: key,
      color: color,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      borderRadius: 25,
      child: widget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12.0),
      margin: margin ?? const EdgeInsets.all(8.0),
      width: width,
      height: height,
      alignment: alignment,
      decoration:
          decoration ??
          BoxDecoration(
            color: gradient == null ? color : null,
            gradient: gradient,
            borderRadius:
                customBorderRadius ??
                (borderRadius != null
                    ? BorderRadius.circular(borderRadius!)
                    : BorderRadius.circular(25)),
            border: border,
            boxShadow: boxShadow,
          ),
      child: child,
    );
  }
}
