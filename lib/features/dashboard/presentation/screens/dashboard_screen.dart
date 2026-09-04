import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/core/database/database_service.dart';
import 'package:organizer/features/dashboard/presentation/screens/insert_project_page.dart';
import 'package:organizer/features/dashboard/widgets/dashboard_appbar.dart';
import 'package:organizer/features/dashboard/widgets/new_project_button.dart';
import 'package:organizer/features/dashboard/widgets/project_filters.dart';
import 'package:organizer/features/dashboard/widgets/project_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedFilter = 0;
  bool isSearching = false;
  String searchQuery = '';

  void _openCreateProjectSheet() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InsertProjectPage()),
    );
    if (res == true && mounted) {
      setState(() {});
    }
  }

  void _openMenuSheet() {
    final settings = DatabaseService.instance.getSettings();
    final workspaceName = settings['workspaceName'] ?? 'My Workspace';
    final projects = DatabaseService.instance.getProjects();
    final resources = DatabaseService.instance.getResources();
    final starredCount = projects.where((p) => p.isFavorite).length;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Material(
          color: AppColor.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.grid_view_rounded,
                            color: AppColor.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workspaceName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Workspace Overview & Menu',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColor.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColor.textMuted,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColor.surfaceAlt,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColor.border),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${projects.length}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Projects',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColor.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColor.surfaceAlt,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColor.border),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$starredCount',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Starred',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColor.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColor.surfaceAlt,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColor.border),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${resources.length}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primarySoft,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Resources',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColor.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: AppColor.primary,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Create New Project',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColor.textMuted,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openCreateProjectSheet();
                  },
                ),
                const Divider(color: AppColor.border, height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'View Starred Projects',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColor.textMuted,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      selectedFilter = 2;
                    });
                  },
                ),
                const Divider(color: AppColor.border, height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColor.primarySoft.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.settings_outlined,
                      color: AppColor.primarySoft,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Workspace Info & Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColor.textMuted,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Manage workspace settings in the Settings tab.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = DatabaseService.instance.getSettings();
    final workspaceName = settings['workspaceName'] ?? 'My Workspace';

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Column(
          children: [
            DashboardAppBar(
              workspaceName: workspaceName,
              onMenuTap: _openMenuSheet,
              isSearching: isSearching,
              onSearchToggle: () {
                setState(() {
                  isSearching = !isSearching;
                  if (!isSearching) searchQuery = '';
                });
              },
              searchQuery: searchQuery,
              onSearchChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
            ),

            const SizedBox(height: 10),

            NewProjectButton(onTap: _openCreateProjectSheet),

            const SizedBox(height: 24),

            ProjectFilter(
              selected: selectedFilter,
              onChanged: (value) {
                setState(() {
                  selectedFilter = value;
                });
              },
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ProjectList(
                filter: selectedFilter,
                searchQuery: searchQuery,
                onCreateProject: _openCreateProjectSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
