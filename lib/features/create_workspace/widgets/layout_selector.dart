import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';

class LayoutSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const LayoutSelector({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final layouts = [
      (title: "Grid", icon: Icons.grid_view_rounded),
      (title: "List", icon: Icons.view_list_rounded),
    ];

    return Row(
      children: List.generate(layouts.length, (index) {
        final selected = selectedIndex == index;

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.only(right: index == 0 ? 12 : 0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: selected ? AppColor.scaffold : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? AppColor.primary : Colors.grey.shade300,
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
                    layouts[index].icon,
                    size: 28,
                    color: selected ? Colors.white : Colors.grey.shade700,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    layouts[index].title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.black87,
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
