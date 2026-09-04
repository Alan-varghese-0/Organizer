import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/core/database/database_service.dart';
import 'package:organizer/core/models/project.dart';
import 'package:organizer/core/models/resource.dart';
import 'package:organizer/features/dashboard/widgets/color_combo_picker.dart';
import 'package:organizer/features/dashboard/widgets/project_selector.dart';
import 'package:organizer/features/dashboard/widgets/typography_picker.dart';
import 'package:uuid/uuid.dart';

class InsertNotePage extends StatefulWidget {
  final String? initialProjectId;

  const InsertNotePage({super.key, this.initialProjectId});

  @override
  State<InsertNotePage> createState() => _InsertNotePageState();
}

class _InsertNotePageState extends State<InsertNotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _colorHex = '#8B5CF6';
  String _fontFamily = 'Inter';
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

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title or note content.')),
      );
      return;
    }

    final note = ResourceItem(
      id: const Uuid().v4(),
      title: title.isEmpty ? 'Untitled Note' : title,
      content: content,
      type: ResourceType.note,
      category: 'General',
      createdAt: DateTime.now().toIso8601String(),
      colorHex: _colorHex,
      fontFamily: _fontFamily,
    );

    await DatabaseService.instance.saveResource(note);
    if (_selectedProjectId != null) {
      await DatabaseService.instance.assignResourceToProject(note, _selectedProjectId!);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note saved successfully!')),
      );
      Navigator.pop(context, true);
    }
  }

  Color _hexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _hexToColor(_colorHex);

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
          'Create Note',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _saveNote,
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
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ProjectSelector(
                      projects: _existingProjects,
                      selectedProjectId: _selectedProjectId,
                      onChanged: (value) => setState(() => _selectedProjectId = value),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.getFont(
                        _fontFamily,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: activeColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Note Title...',
                        hintStyle: GoogleFonts.getFont(
                          _fontFamily,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColor.textMuted,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: AppColor.border, height: 1),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        maxLines: null,
                        expands: true,
                        style: GoogleFonts.getFont(
                          _fontFamily,
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Start writing your note here...',
                          hintStyle: GoogleFonts.getFont(
                            _fontFamily,
                            fontSize: 16,
                            color: AppColor.textMuted,
                          ),
                          border: InputBorder.none,
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
                    onColorChanged: (hex) {
                      setState(() {
                        _colorHex = hex;
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TypographyPicker(
                      initialFont: _fontFamily,
                      onFontChanged: (font) {
                        setState(() {
                          _fontFamily = font;
                        });
                      },
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
