import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/core/database/database_service.dart';
import 'package:organizer/core/models/project.dart';
import 'package:organizer/core/models/resource.dart';
import 'package:organizer/features/dashboard/widgets/color_combo_picker.dart';
import 'package:organizer/features/dashboard/widgets/project_selector.dart';
import 'package:organizer/features/dashboard/widgets/typography_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class InsertImagePage extends StatefulWidget {
  final String? initialProjectId;

  const InsertImagePage({super.key, this.initialProjectId});

  @override
  State<InsertImagePage> createState() => _InsertImagePageState();
}

class _InsertImagePageState extends State<InsertImagePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _localImagePath;
  String _colorHex = '#10B981';
  String _fontFamily = 'Inter';
  bool _isPicking = false;
  late final List<ProjectItem> _existingProjects;
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _existingProjects = DatabaseService.instance.getProjects();
    _selectedProjectId = widget.initialProjectId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _isPicking = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final originalPath = result.files.single.path!;
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(originalPath)}';
        final savedFile = await File(originalPath).copy('${appDir.path}/$fileName');

        setState(() {
          _localImagePath = savedFile.path;
          if (_titleController.text.isEmpty) {
            _titleController.text = p.basenameWithoutExtension(originalPath);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _saveImage() async {
    if (_localImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image file first.')),
      );
      return;
    }

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    final resource = ResourceItem(
      id: const Uuid().v4(),
      title: title.isEmpty ? 'Untitled Image' : title,
      content: content,
      type: ResourceType.image,
      category: 'Images',
      createdAt: DateTime.now().toIso8601String(),
      url: _localImagePath,
      colorHex: _colorHex,
      fontFamily: _fontFamily,
    );

    await DatabaseService.instance.saveResource(resource);
    if (_selectedProjectId != null) {
      await DatabaseService.instance.assignResourceToProject(resource, _selectedProjectId!);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image saved successfully!')),
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
          'Insert Image',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _saveImage,
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProjectSelector(
                      projects: _existingProjects,
                      selectedProjectId: _selectedProjectId,
                      onChanged: (value) => setState(() => _selectedProjectId = value),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Image File',
                      style: TextStyle(color: AppColor.textMuted, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _isPicking ? null : _pickImage,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        height: 220,
                        decoration: BoxDecoration(
                          color: AppColor.surfaceAlt,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColor.border, width: 1.5),
                        ),
                        child: _localImagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(
                                  File(_localImagePath!),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColor.primary.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.add_photo_alternate_rounded, color: AppColor.primary, size: 36),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Tap to select local image',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Supports PNG, JPG, WEBP & GIF',
                                    style: TextStyle(color: AppColor.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    if (_localImagePath != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              p.basename(_localImagePath!),
                              style: const TextStyle(color: AppColor.textMuted, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Change'),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Text(
                      'Image Title',
                      style: TextStyle(color: AppColor.textMuted, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.getFont(_fontFamily, color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'e.g. Design Wireframe',
                        hintStyle: const TextStyle(color: AppColor.textMuted),
                        filled: true,
                        fillColor: AppColor.surfaceAlt,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColor.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColor.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Caption / Description (Optional)',
                      style: TextStyle(color: AppColor.textMuted, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _contentController,
                      maxLines: 3,
                      style: GoogleFonts.getFont(_fontFamily, color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Add description or notes about this image...',
                        hintStyle: const TextStyle(color: AppColor.textMuted),
                        filled: true,
                        fillColor: AppColor.surfaceAlt,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColor.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColor.border),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColor.surface,
                border: Border(top: BorderSide(color: AppColor.border)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Styling:',
                    style: TextStyle(color: AppColor.textMuted, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 12),
                  ColorComboPicker(
                    initialColorHex: _colorHex,
                    onColorChanged: (hex) => setState(() => _colorHex = hex),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TypographyPicker(
                      initialFont: _fontFamily,
                      onFontChanged: (font) => setState(() => _fontFamily = font),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
