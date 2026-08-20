import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/core/database/database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String workspaceName;
  late String selectedTheme;
  late String selectedPersonality;
  late String aiName;
  late bool aiAutoTagging;

  final themes = const ['System', 'Light', 'Dark'];
  final personalities = const [
    (title: 'Ocean', color: Color(0xff2563EB)),
    (title: 'Forest', color: Color(0xff15803D)),
    (title: 'Sunset', color: Color(0xffF97316)),
    (title: 'Aurora', color: Color(0xff7C3AED)),
    (title: 'Noir', color: Color(0xff111827)),
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settings = DatabaseService.instance.getSettings();
    workspaceName = settings['workspaceName'] ?? 'My Workspace';
    selectedTheme = settings['theme'] ?? 'Dark';
    selectedPersonality = settings['personality'] ?? 'Aurora';
    aiName = settings['aiName'] ?? 'Organizer AI';
    aiAutoTagging = settings['aiAutoTagging'] ?? true;
  }

  void _openWorkspaceSheet() {
    final nameController = TextEditingController(text: workspaceName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                      const Text(
                        'Workspace Settings',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColor.textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Workspace Name',
                      filled: true,
                      fillColor: AppColor.surfaceAlt,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Theme Mode', style: TextStyle(color: AppColor.textSecondary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(themes.length, (index) {
                      final selected = selectedTheme == themes[index];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() => selectedTheme = themes[index]);
                            setState(() {});
                            DatabaseService.instance.updateSetting('theme', themes[index]);
                          },
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
                  const SizedBox(height: 20),
                  const Text('Personality Accent', style: TextStyle(color: AppColor.textSecondary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(personalities.length, (index) {
                      final p = personalities[index];
                      final selected = selectedPersonality == p.title;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() => selectedPersonality = p.title);
                          setState(() {});
                          DatabaseService.instance.updateSetting('personality', p.title);
                        },
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
                          ),
                          child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        final newName = nameController.text.trim();
                        if (newName.isNotEmpty) {
                          setState(() => workspaceName = newName);
                          DatabaseService.instance.updateSetting('workspaceName', newName);
                        }
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save Workspace Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openAISheet() {
    final aiController = TextEditingController(text: aiName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                      const Text(
                        'AI Assistant Settings',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColor.textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: aiController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Assistant Name',
                      filled: true,
                      fillColor: AppColor.surfaceAlt,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: aiAutoTagging,
                    onChanged: (val) {
                      setModalState(() => aiAutoTagging = val);
                      setState(() => aiAutoTagging = val);
                      DatabaseService.instance.updateSetting('aiAutoTagging', val);
                    },
                    activeTrackColor: AppColor.primary,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Auto-Tag Resources', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Automatically generate tags for notes and links', style: TextStyle(color: AppColor.textMuted, fontSize: 12)),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        final newAiName = aiController.text.trim();
                        if (newAiName.isNotEmpty) {
                          setState(() => aiName = newAiName);
                          DatabaseService.instance.updateSetting('aiName', newAiName);
                        }
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save AI Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
                'Settings & Profile',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Offline app preferences & profile',
                style: TextStyle(fontSize: 13, color: AppColor.textMuted),
              ),

              const SizedBox(height: 24),

              // Enhanced Prominent Profile Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColor.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColor.border),
                  gradient: LinearGradient(
                    colors: [
                      AppColor.surface,
                      AppColor.primary.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.primary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primary.withValues(alpha: 0.5),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'AV',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Alan Varghese',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                              const SizedBox(height: 6),
                              const Text(
                                'alan@organizer.app',
                                style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Workspace Owner • Offline Mode',
                                style: TextStyle(fontSize: 12, color: AppColor.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              const _SectionHeader(title: 'Preferences'),
              const SizedBox(height: 14),

              // Single Workspace Tile
              _buildTile(
                icon: Icons.workspaces_rounded,
                title: 'Workspace Settings',
                subtitle: ' •  Theme • ',
                onTap: _openWorkspaceSheet,
              ),

              const SizedBox(height: 12),

              // Single AI Assistant Tile
              _buildTile(
                icon: Icons.smart_toy_rounded,
                title: 'AI Assistant Settings',
                subtitle: ' • Auto-tagging ',
                onTap: _openAISheet,
              ),

              const SizedBox(height: 28),
              const _SectionHeader(title: 'System'),
              const SizedBox(height: 14),

              _buildTile(
                icon: Icons.sd_card_rounded,
                title: 'Offline Database',
                subtitle: 'Hive Local Storage Active',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data is securely stored offline in Hive database.')),
                  );
                },
              ),

              const SizedBox(height: 32),

              Center(
                child: Column(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColor.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () async {
                        final shouldClear = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Clear all data?'),
                            content: const Text('All projects, resources, and settings will be permanently deleted.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
                              FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Clear all')),
                            ],
                          ),
                        );
                        if (shouldClear != true) return;
                        await DatabaseService.instance.clearAllData();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All local data cleared.')));
                      },
                      icon: const Icon(Icons.cleaning_services_rounded, color: AppColor.textMuted, size: 18),
                      label: const Text('Clear Local Cache', style: TextStyle(color: AppColor.textMuted)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Organizer v1.0.0 - Offline Mode',
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColor.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColor.primary, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColor.textMuted)),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColor.textMuted),
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
