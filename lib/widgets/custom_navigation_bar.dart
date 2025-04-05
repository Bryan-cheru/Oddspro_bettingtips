// widgets/custom_navigation_bar.dart
import 'package:flutter/material.dart';
import '../config/theme.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tabs = [
      {'title': 'FREE TIPS', 'icon': Icons.sports_soccer},
      {'title': 'VIP TIPS', 'icon': Icons.star},
      {'title': 'HISTORY', 'icon': Icons.history},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(tabs.length, (index) {
            final isSelected = selectedIndex == index;
            return Expanded(
              child: InkWell(
                onTap: () => onTabSelected(index),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.secondaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: AppTheme.secondaryColor)
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tabs[index]['icon'],
                        color: isSelected
                            ? AppTheme.secondaryColor
                            : AppTheme.textLightColor,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tabs[index]['title'],
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.secondaryColor
                              : AppTheme.textLightColor,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
