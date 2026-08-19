import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';

class DashboardAppBar extends StatelessWidget {
  final String workspaceName;

  const DashboardAppBar({super.key, required this.workspaceName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColor.border),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.menu_rounded),
              color: AppColor.textPrimary,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  workspaceName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    color: AppColor.textSecondary,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColor.border),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search_rounded),
              color: AppColor.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
