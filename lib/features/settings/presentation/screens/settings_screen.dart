import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/app/theme/theme_notifier.dart';
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

  // Additional configurable settings
  bool compactView = false;
  bool showBanners = true;
  bool hapticFeedback = true;

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
    compactView = settings['compactView'] ?? false;
    showBanners = settings['showBanners'] ?? true;
    hapticFeedback = settings['hapticFeedback'] ?? true;
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
                          // Update global notifier → immediately rebuilds app theme
                          personalityNotifier.value = p.title;
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

  void _openDisplaySettingsSheet() {
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
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Display & View Options',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColor.textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: compactView,
                    onChanged: (val) {
                      setModalState(() => compactView = val);
                      setState(() => compactView = val);
                      DatabaseService.instance.updateSetting('compactView', val);
                    },
                    activeTrackColor: AppColor.primary,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Compact Card Density', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Show tighter project cards to fit more items on screen', style: TextStyle(color: AppColor.textMuted, fontSize: 12)),
                  ),
                  const Divider(color: AppColor.border),
                  SwitchListTile(
                    value: showBanners,
                    onChanged: (val) {
                      setModalState(() => showBanners = val);
                      setState(() => showBanners = val);
                      DatabaseService.instance.updateSetting('showBanners', val);
                    },
                    activeTrackColor: AppColor.primary,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show Project Banners', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Display image banners on project headers & previews', style: TextStyle(color: AppColor.textMuted, fontSize: 12)),
                  ),
                  const Divider(color: AppColor.border),
                  SwitchListTile(
                    value: hapticFeedback,
                    onChanged: (val) {
                      setModalState(() => hapticFeedback = val);
                      setState(() => hapticFeedback = val);
                      DatabaseService.instance.updateSetting('hapticFeedback', val);
                    },
                    activeTrackColor: AppColor.primary,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Micro-interactions & Haptics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Sensory response on button taps and color selection', style: TextStyle(color: AppColor.textMuted, fontSize: 12)),
                  ),
                  const SizedBox(height: 20),
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

  void _openTechnologiesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final techList = [
          (
            name: 'Flutter & Dart',
            desc: 'High-performance native reactive framework for seamless cross-platform rendering.',
            icon: Icons.flutter_dash_rounded,
          ),
          (
            name: 'Hive Local DB',
            desc: 'Superfast, lightweight NoSQL key-value database providing 100% offline persistence.',
            icon: Icons.storage_rounded,
          ),
          (
            name: 'Google Fonts (Inter)',
            desc: 'Curated modern typography system optimized for high readability and UI density.',
            icon: Icons.font_download_rounded,
          ),
          (
            name: 'Dynamic Material 3 Palettes',
            desc: 'Adaptive theme engine that recalculates full UI schemes on live personality switch.',
            icon: Icons.color_lens_rounded,
          ),
          (
            name: 'Local Media Storage',
            desc: 'Custom image caching and banner file picker for rich multimedia project headers.',
            icon: Icons.image_rounded,
          ),
        ];

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Technologies & Architecture',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColor.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Built entirely with modern offline-first open-source technology.',
                style: TextStyle(color: AppColor.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ...techList.map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColor.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColor.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(t.icon, color: AppColor.primary, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(t.desc, style: const TextStyle(color: AppColor.textMuted, fontSize: 12, height: 1.3)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleClearAllData() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColor.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColor.error, width: 1.2),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColor.error, size: 28),
            SizedBox(width: 10),
            Text('Clear All Data?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'This will permanently erase all projects, tasks, notes, links, swatches, and reset workspace preferences. This action cannot be undone.',
          style: TextStyle(color: AppColor.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: AppColor.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear Everything', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldClear != true) return;

    await DatabaseService.instance.clearAllData();
    personalityNotifier.value = 'Aurora';
    _loadSettings();
    if (!mounted) return;

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All local workspace data has been cleared.'),
        backgroundColor: AppColor.card,
      ),
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
              // Clean Header (no profile container)
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Workspace customization & app preferences',
                style: TextStyle(fontSize: 13, color: AppColor.textMuted),
              ),

              const SizedBox(height: 24),

              // 1. Preferences Section
              const _SectionHeader(title: 'Preferences'),
              const SizedBox(height: 12),

              _buildTile(
                icon: Icons.workspaces_rounded,
                title: 'Workspace Settings',
                subtitle: '$workspaceName • $selectedPersonality • $selectedTheme',
                onTap: _openWorkspaceSheet,
              ),

              const SizedBox(height: 10),

              _buildTile(
                icon: Icons.smart_toy_outlined,
                title: 'AI Assistant Settings',
                subtitle: '$aiName • ${aiAutoTagging ? 'Auto-tagging active' : 'Manual tagging'}',
                onTap: _openAISheet,
              ),

              const SizedBox(height: 26),

              // 2. Settings Section
              const _SectionHeader(title: 'Settings'),
              const SizedBox(height: 12),

              _buildTile(
                icon: Icons.dashboard_customize_outlined,
                title: 'Display & View Options',
                subtitle: 'Card density, project banners, micro-animations',
                onTap: _openDisplaySettingsSheet,
              ),

              const SizedBox(height: 10),

              _buildTile(
                icon: Icons.sd_card_outlined,
                title: 'Offline Storage Mode',
                subtitle: 'Hive NoSQL active • Instant local persistence',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('100% offline: All data is saved directly on your device storage.'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 26),

              // 3. Info Section
              const _SectionHeader(title: 'Info'),
              const SizedBox(height: 12),

              _buildTile(
                icon: Icons.description_outlined,
                title: 'Licenses',
                subtitle: 'Open-source software notices & dependencies',
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'Organizer',
                    applicationVersion: '1.0.0',
                    applicationLegalese: 'MIT Open Source License • 2026',
                  );
                },
              ),

              const SizedBox(height: 10),

              _buildTile(
                icon: Icons.code_rounded,
                title: 'Technologies & Architecture',
                subtitle: 'Flutter, Hive DB, Google Fonts, Material 3',
                onTap: _openTechnologiesSheet,
              ),

              const SizedBox(height: 10),

              _buildTile(
                icon: Icons.shield_outlined,
                title: 'Privacy & Security',
                subtitle: 'Zero telemetry • No external servers • Fully private',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      backgroundColor: AppColor.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Row(
                        children: [
                          Icon(Icons.lock_outline_rounded, color: AppColor.success, size: 24),
                          SizedBox(width: 10),
                          Text('Offline Privacy Guarantee', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      content: const Text(
                        'Organizer is an offline-first workspace application. It does not collect analytics, track cookies, or transmit your projects or notes to any cloud server. Your data stays entirely in your local Hive vault.',
                        style: TextStyle(color: AppColor.textSecondary, height: 1.4),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx),
                          child: const Text('Got it', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 26),

              // 4. Danger Section
              const _SectionHeader(
                title: 'Danger Zone',
                color: AppColor.error,
              ),
              const SizedBox(height: 12),

              _buildTile(
                icon: Icons.delete_forever_rounded,
                title: 'Clear All Data',
                subtitle: 'Permanently erase all projects, tasks, and reset workspace',
                isDestructive: true,
                onTap: _handleClearAllData,
              ),

              const SizedBox(height: 36),

              // Footer version
              const Center(
                child: Text(
                  'Organizer v1.0.0 • Offline Architecture',
                  style: TextStyle(fontSize: 12, color: AppColor.textMuted),
                ),
              ),

              const SizedBox(height: 24),
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
    bool isDestructive = false,
  }) {
    final tileColor = isDestructive ? AppColor.error : AppColor.primary;

    return Material(
      color: AppColor.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDestructive ? AppColor.error.withValues(alpha: 0.3) : AppColor.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: tileColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: tileColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDestructive ? AppColor.error : Colors.white,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColor.textMuted)),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isDestructive ? AppColor.error : AppColor.textMuted,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color? color;

  const _SectionHeader({required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color ?? AppColor.primarySoft,
      ),
    );
  }
}
