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
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

class CreateMenuSheet extends StatelessWidget {
  const CreateMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Create",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          _CreateOption(
            icon: Icons.create_new_folder_outlined,
            title: "Create Project",
            onTap: () {},
          ),
          _CreateOption(
            icon: Icons.notes_outlined,
            title: "Add Note",
            onTap: () {},
          ),
          _CreateOption(
            icon: Icons.link_rounded,
            title: "Add Link",
            onTap: () {},
          ),
          _CreateOption(
            icon: Icons.image_outlined,
            title: "Add Image",
            onTap: () {},
          ),
          _CreateOption(
            icon: Icons.picture_as_pdf_outlined,
            title: "Add PDF",
            onTap: () {},
          ),
          _CreateOption(
            icon: Icons.palette_outlined,
            title: "Add Color",
            onTap: () {},
          ),
          _CreateOption(
            icon: Icons.text_fields_rounded,
            title: "Add Typography",
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _CreateOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _CreateOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon),
      ),

      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),

      trailing: const Icon(Icons.chevron_right_rounded),

      onTap: onTap,
    );
  }
}
