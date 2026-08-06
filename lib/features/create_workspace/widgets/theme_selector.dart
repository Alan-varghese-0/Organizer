import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';

class ThemeSelector extends StatelessWidget {
  final List<String> themes;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const ThemeSelector({
    super.key,
    required this.themes,
    required this.selectedIndex,
    required this.onChanged,
  });

  IconData _getIcon(String theme) {
    switch (theme.toLowerCase()) {
      case "light":
        return Icons.light_mode_rounded;

      case "dark":
        return Icons.dark_mode_rounded;

      default:
        return Icons.phone_android_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(themes.length, (index) {
        final selected = index == selectedIndex;

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.only(
                right: index == themes.length - 1 ? 0 : 12,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: selected ? AppColor.scaffold : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? AppColor.primary : AppColor.scaffold,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    _getIcon(themes[index]),
                    color: selected ? Colors.white : Colors.grey.shade700,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    themes[index],
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
