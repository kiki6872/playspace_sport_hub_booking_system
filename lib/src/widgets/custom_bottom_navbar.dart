import 'package:flutter/material.dart';
import 'package:playspace_sport_hub_booking_system/src/core/constants/app_colors.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;

  const CustomBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: Color(0xFF2B2C44), width: 1)),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final bool selected = currentIndex == index;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Image.asset(
                        selected
                            ? items[index].activeIcon
                            : items[index].inactiveIcon,
                        key: ValueKey(selected.toString() + index.toString()),
                        width: 40,
                        height: 40,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      items[index].label,
                      style: TextStyle(
                        color: selected ? AppColors.primary : Colors.grey,
                        fontSize: 11,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class NavItem {
  final String label;
  final String activeIcon;
  final String inactiveIcon;

  const NavItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
  });
}
