import 'package:flutter/material.dart';

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
    final List<String> tabTitles = ['FREE TIPS', 'VIP TIPS', 'HISTORY'];

    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: List.generate(tabTitles.length, (index) {
          final isSelected = selectedIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                margin: isSelected ? const EdgeInsets.all(4) : EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFEB3B) : Colors.black,
                  borderRadius: isSelected ? BorderRadius.circular(24) : null,
                ),
                child: Text(
                  tabTitles[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
