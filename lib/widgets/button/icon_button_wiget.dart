import 'package:flutter/material.dart';

class IconButtonWiget extends StatelessWidget {
  final Widget iconData;
  final VoidCallback? onTap;
  final double? sizeWidth;
  final double? sizeHeight;
  const IconButtonWiget({
    super.key,
    required this.iconData,
    this.onTap,
    this.sizeWidth,
    this.sizeHeight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: sizeWidth ?? 36,
        height: sizeHeight ?? 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(25),
        ),
        child: iconData,
      ),
    );
  }
}
