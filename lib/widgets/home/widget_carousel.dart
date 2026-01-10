import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../clock_widget.dart';
import '../media_widget.dart';
import '../tools_carousel_widget.dart';
import '../quote_widget.dart';
import '../countdown_widget.dart';
import '../photo_frame_widget.dart';
import '../notification_widget.dart';
import '../connectivity_widget.dart';
import '../gif_widget.dart';

/// Widget carousel component for displaying multiple widgets in a slot
class WidgetCarousel extends StatelessWidget {
  final List<String> widgets;
  final bool autoRotate;
  final Color backgroundColor;

  const WidgetCarousel({
    super.key,
    required this.widgets,
    required this.autoRotate,
    required this.backgroundColor,
  });

  Widget _buildWidget(String widgetKey) {
    switch (widgetKey) {
      case 'clock':
        return const ClockWidget();
      case 'now_playing':
        return const MediaWidget();
      case 'tools':
        return const ToolsCarouselWidget();
      case 'quote':
        return const QuoteWidget();
      case 'countdown':
        return const CountdownWidget();
      case 'photo':
        return const PhotoFrameWidget();
    
      case 'notification':
        return const NotificationWidget();
      case 'connectivity':
        return const ConnectivityWidget();
      case 'gif':
        return const GifWidget();
      default:
        return const Center(
          child: Text(
            'Widget not found',
            style: TextStyle(color: Colors.white54),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widgets.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No widget selected',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    if (widgets.length == 1) {
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: _buildWidget(widgets[0]),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: double.infinity,
        viewportFraction: 1.0,
        autoPlay: autoRotate,
        autoPlayInterval: const Duration(seconds: 10),
        enableInfiniteScroll: widgets.length > 1,
      ),
      items: widgets.map((widget) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: _buildWidget(widget),
        );
      }).toList(),
    );
  }
}
