import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/core/database/database_service.dart';
import 'package:organizer/core/models/project.dart';
import 'package:uuid/uuid.dart';

class InsertProjectPage extends StatefulWidget {
  const InsertProjectPage({super.key});

  @override
  State<InsertProjectPage> createState() => _InsertProjectPageState();
}

class _InsertProjectPageState extends State<InsertProjectPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String selectedCategory = 'Mobile App';
  Color selectedColor = const Color(0xFF8B5CF6);
  String? _bannerImagePath;

  final categories = const [
    'Mobile App',
    'Web Design',
    'Design System',
    'AI Tools',
    'Branding',
  ];

  final colors = const [
    Color(0xFF8B5CF6),
    Color(0xFF38BDF8),
    Color(0xFF34D399),
    Color(0xFFF97316),
    Color(0xFFEC4899),
    Color(0xFFA855F7),
    Color(0xFF22C55E),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickBannerImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _bannerImagePath = image.path;
      });
    }
  }

  Future<void> _saveProject() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a project title.')),
      );
      return;
    }

    final uniqueId = const Uuid().v4();
    final newProject = ProjectItem(
      id: uniqueId,
      title: title,
      description: desc.isEmpty ? 'Offline workspace project' : desc,
      category: selectedCategory,
      itemsCount: 0,
      updated: 'Just now',
      color: selectedColor,
      isFavorite: false,
      bannerPath: _bannerImagePath,
    );

    await DatabaseService.instance.saveProject(newProject);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project created successfully!')),
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
          'Create Project',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _saveProject,
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
                'Project Banner Photo',
                style: TextStyle(
                  color: AppColor.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickBannerImage,
                child: Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColor.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColor.border),
                    image: _bannerImagePath != null
                        ? DecorationImage(
                            image: FileImage(File(_bannerImagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _bannerImagePath != null
                      ? Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.6),
                                    Colors.black.withValues(alpha: 0.2),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 12,
                              top: 12,
                              child: CircleAvatar(
                                backgroundColor: Colors.black.withValues(alpha: 0.6),
                                child: IconButton(
                                  icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                                  onPressed: _pickBannerImage,
                                ),
                              ),
                            ),
                            const Positioned(
                              left: 16,
                              bottom: 16,
                              child: Row(
                                children: [
                                  Icon(Icons.photo_rounded, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Change Banner Photo',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColor.primary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add_a_photo_rounded, color: AppColor.primary, size: 28),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Tap to upload cover banner photo',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'JPG, PNG or WebP',
                              style: TextStyle(color: AppColor.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Project Title',
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
                  hintText: 'e.g., Organizer Redesign',
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
                'Category',
                style: TextStyle(
                  color: AppColor.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final isSel = selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSel,
                    selectedColor: AppColor.primary,
                    backgroundColor: AppColor.surfaceAlt,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColor.textMuted,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => setState(() => selectedCategory = cat),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              const Text(
                'Theme Color',
                style: TextStyle(
                  color: AppColor.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: colors.map((c) {
                  final isSel = selectedColor == c;
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = c),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSel ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSel
                            ? [
                                BoxShadow(
                                  color: c.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: isSel
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              const Text(
                'Description / Notes',
                style: TextStyle(
                  color: AppColor.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                onChanged: (_) => setState(() {}),
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter project details, objectives, or goals...',
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
                'Project Card Preview',
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
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColor.border),
                  boxShadow: [
                    BoxShadow(
                      color: selectedColor.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: selectedColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        image: _bannerImagePath != null
                            ? DecorationImage(
                                image: FileImage(File(_bannerImagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _bannerImagePath == null
                          ? Icon(
                              Icons.folder_rounded,
                              color: selectedColor,
                              size: 26,
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _titleController.text.trim().isEmpty
                                ? 'Project Title'
                                : _titleController.text.trim(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _descController.text.trim().isEmpty
                                ? 'Project details...'
                                : _descController.text.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColor.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: selectedColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        selectedCategory,
                        style: TextStyle(
                          color: selectedColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
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
