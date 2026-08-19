import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';

class ProjectFilter extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const ProjectFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const filters = ["All", "Recent", "Favorites"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(filters.length, (index) {
          final active = selected == index;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(filters[index]),
              selected: active,
              onSelected: (_) => onChanged(index),
              selectedColor: AppColor.primary,
              labelStyle: TextStyle(color: Colors.white),
            ),
          );
        }),
      ),
    );
  }
}
