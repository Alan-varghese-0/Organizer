import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';

class Navigationindicator extends StatelessWidget {
  const Navigationindicator({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: AppColor.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}
