import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';

class DashboardAppBar extends StatelessWidget {
  final String workspaceName;
  final VoidCallback? onMenuTap;
  final bool isSearching;
  final VoidCallback? onSearchToggle;
  final String searchQuery;
  final ValueChanged<String>? onSearchChanged;

  const DashboardAppBar({
    super.key,
    required this.workspaceName,
    this.onMenuTap,
    this.isSearching = false,
    this.onSearchToggle,
    this.searchQuery = '',
    this.onSearchChanged,
  });

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
              onPressed: onMenuTap,
              icon: const Icon(Icons.menu_rounded),
              color: AppColor.textPrimary,
              tooltip: 'Workspace Menu',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isSearching
                ? TextField(
                    autofocus: true,
                    onChanged: onSearchChanged,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search projects...',
                      hintStyle: const TextStyle(color: AppColor.textMuted),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColor.textMuted, size: 20),
                      filled: true,
                      fillColor: AppColor.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColor.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColor.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColor.primary),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Text(
                        workspaceName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: Colors.white,
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
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: isSearching ? AppColor.primary.withValues(alpha: 0.2) : AppColor.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isSearching ? AppColor.primary : AppColor.border),
            ),
            child: IconButton(
              onPressed: onSearchToggle,
              icon: Icon(isSearching ? Icons.close_rounded : Icons.search_rounded),
              color: isSearching ? AppColor.primarySoft : AppColor.textPrimary,
              tooltip: isSearching ? 'Close Search' : 'Search Projects',
            ),
          ),
        ],
      ),
    );
  }
}
