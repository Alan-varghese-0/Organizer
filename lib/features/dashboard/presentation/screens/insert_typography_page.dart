import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/core/database/database_service.dart';
import 'package:organizer/core/models/project.dart';
import 'package:organizer/core/models/resource.dart';
import 'package:organizer/features/dashboard/widgets/typography_picker.dart';
import 'package:uuid/uuid.dart';

class InsertTypographyPage extends StatefulWidget {
  const InsertTypographyPage({super.key});

  @override
  State<InsertTypographyPage> createState() => _InsertTypographyPageState();
}

class _InsertTypographyPageState extends State<InsertTypographyPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _sampleTextController = TextEditingController(
    text: 'The quick brown fox jumps over the lazy dog',
  );

  String selectedFontFamily = 'AiryBlend';
  String selectedFontWeight = 'Regular';
  double fontSize = 20.0;
  String? selectedProjectId;
  late List<ProjectItem> existingProjects;

  final fontWeights = const ['Light', 'Regular', 'Medium', 'SemiBold', 'Bold'];

  @override
  void initState() {
    super.initState();
    existingProjects = DatabaseService.instance.getProjects();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sampleTextController.dispose();
    super.dispose();
  }

  FontWeight _getFontWeight(String weight) {
    switch (weight) {
      case 'Light':
        return FontWeight.w300;
      case 'Regular':
        return FontWeight.w400;
      case 'Medium':
        return FontWeight.w500;
      case 'SemiBold':
        return FontWeight.w600;
      case 'Bold':
        return FontWeight.w700;
      default:
        return FontWeight.w400;
    }
  }

  Future<void> _saveTypography() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for this typography spec.')),
      );
      return;
    }

    final uniqueId = const Uuid().v4();
    final sampleText = _sampleTextController.text.trim();
    final content = 'Font: $selectedFontFamily ($selectedFontWeight, ${fontSize.toInt()}px)'
        '${sampleText.isNotEmpty ? '\nSample: $sampleText' : ''}';

    final newResource = ResourceItem(
      id: uniqueId,
      title: title,
      content: content,
      type: ResourceType.typography,
      category: 'Design Tokens',
      createdAt: DateTime.now().toIso8601String(),
      fontFamily: selectedFontFamily,
      tags: ['Typography', selectedFontFamily],
    );

    await DatabaseService.instance.saveResource(newResource);

    if (selectedProjectId != null) {
      final targetProj = existingProjects.firstWhere((p) => p.id == selectedProjectId, orElse: () => existingProjects.first);
      final updatedResources = List<ResourceItem>.from(targetProj.resources)..add(newResource);
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
        const SnackBar(content: Text('Typography saved successfully!')),
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
          'Create Typography Spec',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _saveTypography,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                'Typography Spec Title',
                style: TextStyle(color: AppColor.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'e.g., Primary Heading Font',
                  hintStyle: const TextStyle(color: AppColor.textMuted),
                  filled: true,
                  fillColor: AppColor.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColor.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColor.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColor.primary)),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Assign to Project (Optional)',
                style: TextStyle(color: AppColor.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: selectedProjectId,
                dropdownColor: AppColor.surface,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColor.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColor.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColor.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColor.primary)),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('General Library (Unassigned)', style: TextStyle(color: AppColor.textMuted)),
                  ),
                  ...existingProjects.map((p) => DropdownMenuItem<String?>(
                        value: p.id,
                        child: Row(
                          children: [
                            Icon(Icons.folder_open_rounded, color: p.color, size: 18),
                            const SizedBox(width: 8),
                            Text(p.title, style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      )),
                ],
                onChanged: (val) => setState(() => selectedProjectId = val),
              ),

              const SizedBox(height: 20),

              const Text(
                'Font Family (Asset & Google Fonts)',
                style: TextStyle(color: AppColor.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TypographyPicker(
                initialFont: selectedFontFamily,
                onFontChanged: (font) {
                  setState(() {
                    selectedFontFamily = font;
                  });
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Font Weight',
                style: TextStyle(color: AppColor.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: fontWeights.map((w) {
                  final isSel = selectedFontWeight == w;
                  return ChoiceChip(
                    label: Text(w),
                    selected: isSel,
                    selectedColor: AppColor.primary,
                    backgroundColor: AppColor.surfaceAlt,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColor.textMuted,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => setState(() => selectedFontWeight = w),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Font Size',
                    style: TextStyle(color: AppColor.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${fontSize.toInt()} px',
                    style: TextStyle(color: AppColor.primarySoft, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Slider(
                value: fontSize,
                min: 12,
                max: 48,
                divisions: 36,
                activeColor: AppColor.primary,
                inactiveColor: AppColor.surfaceAlt,
                onChanged: (val) => setState(() => fontSize = val),
              ),

              const SizedBox(height: 16),

              const Text(
                'Sample Text Preview',
                style: TextStyle(color: AppColor.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _sampleTextController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type sample text here...',
                  hintStyle: const TextStyle(color: AppColor.textMuted),
                  filled: true,
                  fillColor: AppColor.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColor.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColor.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColor.primary)),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Typography Spec Card',
                style: TextStyle(color: AppColor.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColor.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColor.border),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedFontFamily,
                          style: TextStyle(color: AppColor.primarySoft, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColor.surfaceAlt,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColor.border),
                          ),
                          child: Text(
                            '$selectedFontWeight • ${fontSize.toInt()}px',
                            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _sampleTextController.text.isEmpty
                          ? 'The quick brown fox jumps over the lazy dog'
                          : _sampleTextController.text,
                      style: getAppFontStyle(
                        selectedFontFamily,
                        color: Colors.white,
                        fontSize: fontSize,
                        fontWeight: _getFontWeight(selectedFontWeight),
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
