import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';

class PersonalityCard extends StatelessWidget {
  final String title;
  final List<Color> colors;
  final bool selected;
  final VoidCallback onTap;

  const PersonalityCard({
    super.key,
    required this.title,
    required this.colors,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.03 : 1,
      duration: const Duration(milliseconds: 250),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              width: 2,
              color: selected ? AppColor.primary : Colors.grey.shade300,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: selected ? 16 : 8,
                color: Colors.black.withOpacity(.05),
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColor.scaffold : AppColor.textSecondary,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: colors
                    .map(
                      (color) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
