import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';

class NewProjectButton extends StatelessWidget {
  final VoidCallback onTap;

  const NewProjectButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text(
            'New Project',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            shadowColor: AppColor.primary.withOpacity(0.25),
          ),
        ),
      ),
    );
  }
}
