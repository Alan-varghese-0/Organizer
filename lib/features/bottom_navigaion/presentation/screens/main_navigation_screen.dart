import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/features/bottom_navigaion/widgets/bottom_navigation_bar.dart';
import 'package:organizer/features/browse/presentation/screens/browse_screen.dart';
import 'package:organizer/features/common/widgets/create_forms.dart';
import 'package:organizer/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:organizer/features/library/presentation/screens/library_screen.dart';
import 'package:organizer/features/settings/presentation/screens/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  bool isSpeedDialOpen = false;
  late final AnimationController _speedDialController;
  late final Animation<double> _expandAnimation;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    _speedDialController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _speedDialController,
      curve: Curves.easeOutBack,
    );

    pages = const [
      DashboardScreen(),
      BrowseScreen(),
      LibraryScreen(),
      SettingsScreen(),
    ];
  }

  @override
  void dispose() {
    _speedDialController.dispose();
    super.dispose();
  }

  void _onNavigationTap(int index) {
    if (isSpeedDialOpen) {
      _toggleSpeedDial();
    }
    setState(() {
      currentIndex = index;
    });
  }

  void _toggleSpeedDial() {
    setState(() {
      isSpeedDialOpen = !isSpeedDialOpen;
      if (isSpeedDialOpen) {
        _speedDialController.forward();
      } else {
        _speedDialController.reverse();
      }
    });
  }

  void _openProjectForm() {
    _toggleSpeedDial();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => CreateProjectFormSheet(
        onProjectCreated: () => setState(() {}),
      ),
    );
  }

  void _openResourceForm(String itemType) {
    _toggleSpeedDial();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => CreateResourceFormSheet(
        itemType: itemType,
        onSaved: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final speedDialItems = [
      (label: 'Project', icon: Icons.create_new_folder_outlined, color: const Color(0xFF8B5CF6), onTap: _openProjectForm),
      (label: 'Note', icon: Icons.notes_outlined, color: const Color(0xFF38BDF8), onTap: () => _openResourceForm('Note')),
      (label: 'Link', icon: Icons.link_rounded, color: const Color(0xFF34D399), onTap: () => _openResourceForm('Link')),
      (label: 'Image', icon: Icons.image_outlined, color: const Color(0xFFF97316), onTap: () => _openResourceForm('Image')),
      (label: 'PDF', icon: Icons.picture_as_pdf_outlined, color: const Color(0xFFEC4899), onTap: () => _openResourceForm('PDF')),
      (label: 'Color Combo', icon: Icons.palette_outlined, color: const Color(0xFFA855F7), onTap: () => _openResourceForm('Color Combo')),
      (label: 'Typography', icon: Icons.text_fields_rounded, color: const Color(0xFF22C55E), onTap: () => _openResourceForm('Typography')),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: currentIndex, children: pages),

          // Speed Dial Backdrop Barrier
          if (isSpeedDialOpen)
            GestureDetector(
              onTap: _toggleSpeedDial,
              behavior: HitTestBehavior.opaque,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSpeedDialOpen ? 0.65 : 0.0,
                child: Container(color: Colors.black),
              ),
            ),

          // Speed Dial Surrounding Action Buttons Stack
          if (isSpeedDialOpen)
            Positioned(
              right: 18,
              bottom: 110,
              child: ScaleTransition(
                scale: _expandAnimation,
                alignment: Alignment.bottomRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: speedDialItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColor.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColor.border),
                              boxShadow: const [
                                BoxShadow(color: Colors.black38, blurRadius: 8),
                              ],
                            ),
                            child: Text(
                              item.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          FloatingActionButton.small(
                            heroTag: item.label,
                            onPressed: item.onTap,
                            backgroundColor: item.color,
                            child: Icon(item.icon, color: Colors.white, size: 18),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onNavigationTap,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleSpeedDial,
        backgroundColor: isSpeedDialOpen ? AppColor.surfaceAlt : AppColor.primary,
        child: AnimatedRotation(
          turns: isSpeedDialOpen ? 0.125 : 0.0,
          duration: const Duration(milliseconds: 250),
          child: Icon(
            Icons.add_rounded,
            color: isSpeedDialOpen ? AppColor.primarySoft : Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
