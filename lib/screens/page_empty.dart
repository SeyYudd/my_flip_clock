import 'package:flutter/material.dart';
import 'package:my_stand_clock/widgets/button/icon_button_wiget.dart';

class PageEmpty extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final String? message;
  final Widget? widget;
  const PageEmpty({
    super.key,
    this.title,
    this.icon,
    this.message,
    this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade900,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          IconButtonWiget(
            iconData: Icon(
              icon ?? Icons.dashboard_customize_outlined,
              color: Colors.white70,
              size: 32,
            ),
            sizeWidth: 80,
            sizeHeight: 80,
          ),
          Text(
            title ?? 'Slot Kosong',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          widget ?? SizedBox(height: 2),
          Text(
            message ?? 'Ketuk untuk menambahkan widget',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
