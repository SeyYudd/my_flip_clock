import 'package:flutter/material.dart';
import 'widget_carousel.dart';

/// Main grid layout component displaying top and bottom widget slots
class GridLayoutWidget extends StatelessWidget {
  final List<String> topWidgets;
  final List<String> bottomWidgets;
  final double topRatio;
  final double innerPadding;
  final double outerPadding;
  final double borderRadius;
  final bool autoRotate;
  final Color topColor;
  final Color bottomColor;
  final double burnInOffsetX;
  final double burnInOffsetY;

  const GridLayoutWidget({
    super.key,
    required this.topWidgets,
    required this.bottomWidgets,
    required this.topRatio,
    required this.innerPadding,
    required this.outerPadding,
    required this.borderRadius,
    required this.autoRotate,
    required this.topColor,
    required this.bottomColor,
    this.burnInOffsetX = 0,
    this.burnInOffsetY = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(outerPadding),
      child: Transform.translate(
        offset: Offset(burnInOffsetX, burnInOffsetY),
        child: Column(
          children: [
            // Top slot
            Expanded(
              flex: (topRatio * 100).toInt(),
              child: WidgetCarousel(
                widgets: topWidgets,
                autoRotate: autoRotate,
                backgroundColor: topColor,
              ),
            ),
            SizedBox(height: innerPadding),
            // Bottom slot
            Expanded(
              flex: ((1 - topRatio) * 100).toInt(),
              child: WidgetCarousel(
                widgets: bottomWidgets,
                autoRotate: autoRotate,
                backgroundColor: bottomColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
