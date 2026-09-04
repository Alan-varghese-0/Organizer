import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/core/database/database_service.dart';
import 'package:organizer/core/models/resource.dart';
import 'package:organizer/features/dashboard/widgets/color_combo_picker.dart';
import 'package:organizer/features/dashboard/widgets/typography_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class InsertPdfPage extends StatefulWidget {
  const InsertPdfPage({super.key});

  @override
  State<InsertPdfPage> createState() => _InsertPdfPageState();
}

class _InsertPdfPageState extends State<InsertPdfPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _localPdfPath;
  int _fileSizeBytes = 0;
  String _colorHex = '#EF4444';
  String _fontFamily = 'Inter';
  bool _isPicking = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    setState(() => _isPicking = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final originalPath = result.files.single.path!;
        final file = File(originalPath);
        final size = await file.length();

        final appDir = await getApplicationDocumentsDirectory();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(originalPath)}';
        final savedFile = await file.copy('${appDir.path}/$fileName');

        setState(() {
          _localPdfPath = savedFile.path;
          _fileSizeBytes = size;
          if (_titleController.text.isEmpty) {
            _titleController.text = p.basenameWithoutExtension(originalPath);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking PDF file: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _savePdf() async {
    if (_localPdfPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file first.')),
      );
      return;
    }

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    final resource = ResourceItem(
      id: const Uuid().v4(),
      title: title.isEmpty ? 'Untitled Document.pdf' : title,
      content: content,
      type: ResourceType.pdf,
      category: 'Documents',
      createdAt: DateTime.now().toIso8601String(),
      url: _localPdfPath,
      colorHex: _colorHex,
      fontFamily: _fontFamily,
    );

    await DatabaseService.instance.saveResource(resource);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF document saved successfully!')),
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
          'Insert PDF Document',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _savePdf,
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
                    const Text(
                      'PDF File',
                      style: TextStyle(color: AppColor.textMuted, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _isPicking ? null : _pickPdf,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColor.surfaceAlt,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColor.border, width: 1.5),
                        ),
                        child: _localPdfPath != null
                            ? Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 40),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    p.basename(_localPdfPath!),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Size: ${_formatFileSize(_fileSizeBytes)}',
                                    style: const TextStyle(color: AppColor.textMuted, fontSize: 12),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: _pickPdf,
                                    icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                                    label: const Text('Change PDF'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColor.textMuted,
                                      side: const BorderSide(color: AppColor.border),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 36),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Tap to select PDF document',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Select any PDF file from your device',
                                    style: TextStyle(color: AppColor.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Document Title',
                      style: TextStyle(color: AppColor.textMuted, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.getFont(_fontFamily, color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'e.g. Q3 Financial Report',
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
                      'Notes / Summary (Optional)',
                      style: TextStyle(color: AppColor.textMuted, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _contentController,
                      maxLines: 3,
                      style: GoogleFonts.getFont(_fontFamily, color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Add notes or key points for this PDF...',
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
