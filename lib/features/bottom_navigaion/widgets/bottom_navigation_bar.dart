import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/features/bottom_navigaion/widgets/navigation_indicator.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (title: "Home", icon: Icons.home_rounded),
      (title: "Search", icon: Icons.search_rounded),
      (title: "AI", icon: Icons.auto_awesome_rounded),
      (title: "Settings", icon: Icons.settings_rounded),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 78,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final selected = currentIndex == index;

            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: selected ? 1.15 : 1,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          items[index].icon,
                          color: selected ? AppColor.primary : Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 4),

                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? AppColor.primary : Colors.grey,
                        ),
                        child: Text(items[index].title),
                      ),

                      const SizedBox(height: 4),

                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: selected ? 1 : 0,
                        child: Navigationindicator(),
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
