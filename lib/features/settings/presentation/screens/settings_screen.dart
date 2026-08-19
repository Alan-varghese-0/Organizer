import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool autoSyncEnabled = true;
  bool aiAutoTagging = true;
  int selectedThemeIndex = 2; // Dark
  int selectedPersonalityIndex = 3; // Aurora

  final themes = const ['System', 'Light', 'Dark'];
  final personalities = const [
    (title: 'Ocean', color: Color(0xff2563EB)),
    (title: 'Forest', color: Color(0xff15803D)),
    (title: 'Sunset', color: Color(0xffF97316)),
    (title: 'Aurora', color: Color(0xff7C3AED)),
    (title: 'Noir', color: Color(0xff111827)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Manage profile, workspace, and preferences',
                style: TextStyle(fontSize: 13, color: AppColor.textMuted),
              ),

              const SizedBox(height: 24),

              // Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColor.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColor.border),
                  gradient: LinearGradient(
                    colors: [
                      AppColor.surface,
                      AppColor.primary.withValues(alpha: 0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.primary,
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.primary.withValues(alpha: 0.4),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'AV',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Alan Varghese',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.amber.withValues(alpha: 0.6)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                                    SizedBox(width: 4),
                                    Text(
                                      'PRO',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'alan@organizer.app',
                            style: TextStyle(fontSize: 13, color: AppColor.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: AppColor.textMuted),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              const _SectionHeader(title: 'Workspace Preferences'),
              const SizedBox(height: 12),

              _buildTile(
                icon: Icons.workspaces_rounded,
                title: 'Workspace Name',
                subtitle: 'My Workspace',
                onTap: () {},
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColor.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.palette_rounded, color: AppColor.primary, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Theme',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: List.generate(themes.length, (index) {
                        final selected = selectedThemeIndex == index;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedThemeIndex = index),
                            child: Container(
                              margin: EdgeInsets.only(right: index == themes.length - 1 ? 0 : 8),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selected ? AppColor.primary : AppColor.surfaceAlt,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  themes[index],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                    color: selected ? Colors.white : AppColor.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColor.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.color_lens_rounded, color: AppColor.primary, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Workspace Personality',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(personalities.length, (index) {
                        final p = personalities[index];
                        final selected = selectedPersonalityIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => selectedPersonalityIndex = index),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: p.color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected ? Colors.white : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: p.color.withValues(alpha: 0.6),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              const _SectionHeader(title: 'AI Assistant'),
              const SizedBox(height: 12),

              _buildTile(
                icon: Icons.smart_toy_rounded,
                title: 'Assistant Name',
                subtitle: 'Organizer AI',
                onTap: () {},
              ),

              const SizedBox(height: 10),

              _buildSwitchTile(
                icon: Icons.auto_awesome_rounded,
                title: 'Auto-Tag Resources',
                subtitle: 'Automatically extract tags using AI',
                value: aiAutoTagging,
                onChanged: (val) => setState(() => aiAutoTagging = val),
              ),

              const SizedBox(height: 28),
              const _SectionHeader(title: 'Storage and System'),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColor.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColor.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.cloud_queue_rounded, color: AppColor.primary, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Cloud Storage',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ],
                        ),
                        Text(
                          '1.2 GB / 10 GB',
                          style: TextStyle(fontSize: 13, color: AppColor.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 0.12,
                        minHeight: 8,
                        backgroundColor: AppColor.surfaceAlt,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColor.primary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              _buildSwitchTile(
                icon: Icons.sync_rounded,
                title: 'Auto-Sync',
                subtitle: 'Sync data across devices',
                value: autoSyncEnabled,
                onChanged: (val) => setState(() => autoSyncEnabled = val),
              ),

              const SizedBox(height: 10),

              _buildSwitchTile(
                icon: Icons.notifications_rounded,
                title: 'Push Notifications',
                subtitle: 'Receive project updates and reminders',
                value: notificationsEnabled,
                onChanged: (val) => setState(() => notificationsEnabled = val),
              ),

              const SizedBox(height: 28),

              Center(
                child: Column(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColor.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cache cleared successfully!')),
                        );
                      },
                      icon: const Icon(Icons.cleaning_services_rounded, color: AppColor.textMuted, size: 18),
                      label: const Text('Clear Cache', style: TextStyle(color: AppColor.textMuted)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Organizer v1.0.0 - Build 2026.08',
                      style: TextStyle(fontSize: 12, color: AppColor.textMuted),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: AppColor.primary, size: 22),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColor.textMuted)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColor.textMuted),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.border),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColor.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Icon(icon, color: AppColor.primary, size: 22),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColor.textMuted)),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColor.primarySoft,
      ),
    );
  }
}
