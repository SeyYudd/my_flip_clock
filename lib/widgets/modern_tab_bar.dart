import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ModernTabBar extends StatelessWidget {
  final TabController controller;
  final bool isVisible;
  final VoidCallback onInteraction;

  const ModernTabBar({
    super.key,
    required this.controller,
    required this.isVisible,
    required this.onInteraction,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isVisible ? 56 : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isVisible ? 1.0 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.black.withValues(alpha: 0.95)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: controller,
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            labelPadding: const EdgeInsets.symmetric(horizontal: 20),
            indicatorSize: TabBarIndicatorSize.label,
            indicator: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[400],
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            onTap: (_) => onInteraction(),
            tabs: const [
              Tab(text: '2 GRID'),
              Tab(text: 'CLOCK'),
              Tab(text: 'MUSIC'),
              Tab(text: 'QUOTE'),
            ],
          ),
        ),
      ),
    );
  }
}
