import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/features/bottom_navigaion/widgets/bottom_navigation_bar.dart';
import 'package:organizer/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:organizer/features/browse/presentation/screens/browse_screen.dart';
import 'package:organizer/features/library/presentation/screens/library_screen.dart';
import 'package:organizer/features/settings/presentation/screens/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = const [
      DashboardScreen(),
      BrowseScreen(),
      LibraryScreen(),
      SettingsScreen(),
    ];
  }

  void _onNavigationTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void _showCreateMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const CreateMenuSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onNavigationTap,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateMenu,
        backgroundColor: AppColor.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

class CreateMenuSheet extends StatelessWidget {
  const CreateMenuSheet({super.key});

  void _openCreateForm(BuildContext context, String itemType) {
    Navigator.pop(context);
    final controllerTitle = TextEditingController();
    final controllerDesc = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'New ',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColor.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controllerTitle,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: ' Title',
                  hintText: 'Enter title...',
                  filled: true,
                  fillColor: AppColor.surfaceAlt,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controllerDesc,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: itemType == 'Link' ? 'URL' : 'Details / Content',
                  hintText: itemType == 'Link' ? 'https://...' : 'Enter details...',
                  filled: true,
                  fillColor: AppColor.surfaceAlt,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    final title = controllerTitle.text.trim();
                    if (title.isNotEmpty) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('   created successfully!'),
                          backgroundColor: AppColor.primary,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Create ',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
      decoration: const BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColor.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Create New',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _CreateOption(
            icon: Icons.create_new_folder_outlined,
            title: 'Create Project',
            subtitle: 'Organize notes, links, and design specs',
            onTap: () => _openCreateForm(context, 'Project'),
          ),
          _CreateOption(
            icon: Icons.notes_outlined,
            title: 'Add Note',
            subtitle: 'Save ideas, text docs, and code snippets',
            onTap: () => _openCreateForm(context, 'Note'),
          ),
          _CreateOption(
            icon: Icons.link_rounded,
            title: 'Add Link',
            subtitle: 'Bookmark websites, Figma specs, and repos',
            onTap: () => _openCreateForm(context, 'Link'),
          ),
          _CreateOption(
            icon: Icons.image_outlined,
            title: 'Add Image',
            subtitle: 'Upload screenshots, banners, and logos',
            onTap: () => _openCreateForm(context, 'Image'),
          ),
          _CreateOption(
            icon: Icons.picture_as_pdf_outlined,
            title: 'Add PDF',
            subtitle: 'Attach flowcharts, reports, and documents',
            onTap: () => _openCreateForm(context, 'PDF'),
          ),
          _CreateOption(
            icon: Icons.palette_outlined,
            title: 'Add Color',
            subtitle: 'Save brand colors and theme hex tokens',
            onTap: () => _openCreateForm(context, 'Color Token'),
          ),
          _CreateOption(
            icon: Icons.text_fields_rounded,
            title: 'Add Typography',
            subtitle: 'Store font family specs and text styles',
            onTap: () => _openCreateForm(context, 'Typography Spec'),
          ),
        ],
      ),
    );
  }
}

class _CreateOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CreateOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColor.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColor.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColor.textMuted, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColor.textMuted),
      onTap: onTap,
    );
  }
}
