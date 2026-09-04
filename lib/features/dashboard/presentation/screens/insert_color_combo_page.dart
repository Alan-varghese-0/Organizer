import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/core/database/database_service.dart';
import 'package:organizer/core/models/project.dart';
import 'package:organizer/core/models/resource.dart';
import 'package:organizer/features/dashboard/widgets/blossom_color_picker.dart';
import 'package:uuid/uuid.dart';

class InsertColorComboPage extends StatefulWidget {
  const InsertColorComboPage({super.key});

  @override
  State<InsertColorComboPage> createState() => _InsertColorComboPageState();
}

class _InsertColorComboPageState extends State<InsertColorComboPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Color primaryColor = const Color(0xFF8B5CF6);
  Color accentColor = const Color(0xFF38BDF8);
  Color backgroundColor = const Color(0xFF0A0B12);

  String? selectedProjectId;
  late List<ProjectItem> existingProjects;

  @override
  void initState() {
    super.initState();
    existingProjects = DatabaseService.instance.getProjects();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _colorToHex(Color c) {
    return '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  Future<void> _pickColor(
    Color currentColor,
    ValueChanged<Color> onColorPicked,
  ) async {
    final Color? picked = await showBlossomColorPicker(context, currentColor);
    if (picked != null && picked != currentColor) {
      onColorPicked(picked);
    }
  }

  Future<void> _saveColorCombo() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title for this color palette.'),
        ),
      );
      return;
    }

    final uniqueId = const Uuid().v4();
    final pHex = _colorToHex(primaryColor);
    final aHex = _colorToHex(accentColor);
    final bHex = _colorToHex(backgroundColor);

    final notesText = _notesController.text.trim();
    final content =
        'Primary $pHex, Accent $aHex, Background $bHex'
        '${notesText.isNotEmpty ? '\nNotes: $notesText' : ''}';

    final newResource = ResourceItem(
      id: uniqueId,
      title: title,
      content: content,
      type: ResourceType.color,
      category: 'Design Tokens',
      createdAt: DateTime.now().toIso8601String(),
      colorHex: pHex,
      tags: ['ColorCombo', 'Palette'],
    );

    await DatabaseService.instance.saveResource(newResource);

    if (selectedProjectId != null) {
      final targetProj = existingProjects.firstWhere(
        (p) => p.id == selectedProjectId,
        orElse: () => existingProjects.first,
      );
      final updatedResources = List<ResourceItem>.from(targetProj.resources)
        ..add(newResource);
      final updatedProj = ProjectItem(
        id: targetProj.id,
        title: targetProj.title,
        description: targetProj.description,
        category: targetProj.category,
        itemsCount: targetProj.itemsCount + 1,
        updated: 'Just now',
        color: targetProj.color,
        isFavorite: targetProj.isFavorite,
        resources: updatedResources,
      );
      await DatabaseService.instance.saveProject(updatedProj);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Color Combo saved successfully!')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Color Combo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _saveColorCombo,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Palette Name',
                style: TextStyle(
                  color: AppColor.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., Cyberpunk Dark Theme',
                  hintStyle: const TextStyle(color: AppColor.textMuted),
                  filled: true,
                  fillColor: AppColor.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColor.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColor.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColor.primary),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Assign to Project (Optional)',
                style: TextStyle(
                  color: AppColor.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: selectedProjectId,
                dropdownColor: AppColor.surface,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColor.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColor.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColor.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColor.primary),
                  ),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      'General Library (Unassigned)',
                      style: TextStyle(color: AppColor.textMuted),
                    ),
                  ),
                  ...existingProjects.map(
                    (p) => DropdownMenuItem<String?>(
                      value: p.id,
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder_open_rounded,
                            color: p.color,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            p.title,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: (val) => setState(() => selectedProjectId = val),
              ),

              const SizedBox(height: 24),

              const Text(
                'Select Colors',
                style: TextStyle(
                  color: AppColor.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  // Primary Color
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickColor(
                        primaryColor,
                        (c) => setState(() => primaryColor = c),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColor.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColor.border),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.colorize_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Primary',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _colorToHex(primaryColor),
                              style: const TextStyle(
                                color: AppColor.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Accent Color
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickColor(
                        accentColor,
                        (c) => setState(() => accentColor = c),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColor.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColor.border),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.colorize_rounded,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Accent',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _colorToHex(accentColor),
                              style: const TextStyle(
                                color: AppColor.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Background Color
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickColor(
                        backgroundColor,
                        (c) => setState(() => backgroundColor = c),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColor.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColor.border),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.colorize_rounded,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Background',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _colorToHex(backgroundColor),
                              style: const TextStyle(
                                color: AppColor.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'Description / Usage Notes (Optional)',
                style: TextStyle(
                  color: AppColor.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText:
                      'e.g., Primary for headers and buttons, Accent for badges...',
                  hintStyle: const TextStyle(color: AppColor.textMuted),
                  filled: true,
                  fillColor: AppColor.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColor.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColor.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColor.primary),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Live Palette Preview',
                style: TextStyle(
                  color: AppColor.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColor.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: backgroundColor, width: 3.5),
                  boxShadow: [
                    BoxShadow(
                      color: backgroundColor.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _titleController.text.trim().isEmpty
                                ? 'Live UI Component Preview'
                                : _titleController.text.trim(),
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'ACCENT',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Real-time Mini App Card Mockup using the 3 colors
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.auto_awesome_rounded,
                                  color: primaryColor.computeLuminance() > 0.4
                                      ? Colors.black
                                      : Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Card Title Preview',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      'Subtext in background container',
                                      style: TextStyle(
                                        color:
                                            backgroundColor.computeLuminance() >
                                                0.4
                                            ? Colors.black.withValues(
                                                alpha: 0.7,
                                              )
                                            : Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: accentColor),
                                ),
                                child: Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor:
                                    primaryColor.computeLuminance() > 0.4
                                    ? Colors.black
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text(
                                'Primary Button Action',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Color Hex Swatch Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              color: primaryColor,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Primary',
                                    style: TextStyle(
                                      color:
                                          primaryColor.computeLuminance() > 0.4
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _colorToHex(primaryColor),
                                    style: TextStyle(
                                      color:
                                          primaryColor.computeLuminance() > 0.4
                                          ? Colors.black87
                                          : Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 48,
                              color: accentColor,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Accent',
                                    style: TextStyle(
                                      color:
                                          accentColor.computeLuminance() > 0.4
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _colorToHex(accentColor),
                                    style: TextStyle(
                                      color:
                                          accentColor.computeLuminance() > 0.4
                                          ? Colors.black87
                                          : Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 48,
                              color: backgroundColor,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Background',
                                    style: TextStyle(
                                      color:
                                          backgroundColor.computeLuminance() >
                                              0.4
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _colorToHex(backgroundColor),
                                    style: TextStyle(
                                      color:
                                          backgroundColor.computeLuminance() >
                                              0.4
                                          ? Colors.black87
                                          : Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
