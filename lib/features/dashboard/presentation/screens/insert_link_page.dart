import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/core/database/database_service.dart';
import 'package:organizer/core/models/resource.dart';
import 'package:organizer/features/dashboard/widgets/color_combo_picker.dart';
import 'package:organizer/features/dashboard/widgets/typography_picker.dart';
import 'package:uuid/uuid.dart';

class InsertLinkPage extends StatefulWidget {
  const InsertLinkPage({super.key});

  @override
  State<InsertLinkPage> createState() => _InsertLinkPageState();
}

class _InsertLinkPageState extends State<InsertLinkPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _colorHex = '#3B82F6';
  String _fontFamily = 'Inter';

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveLink() async {
    final title = _titleController.text.trim();
    var url = _urlController.text.trim();
    final content = _contentController.text.trim();

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid URL.')),
      );
      return;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final linkItem = ResourceItem(
      id: const Uuid().v4(),
      title: title.isEmpty ? url : title,
      content: content,
      type: ResourceType.link,
      category: 'Links',
      createdAt: DateTime.now().toIso8601String(),
      url: url,
      colorHex: _colorHex,
      fontFamily: _fontFamily,
    );

    await DatabaseService.instance.saveResource(linkItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link saved successfully!')),
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
          'Insert Link',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _saveLink,
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
                      'URL / Web Address',
                      style: TextStyle(color: AppColor.textMuted, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _urlController,
                      style: GoogleFonts.getFont(_fontFamily, color: Colors.white, fontSize: 16),
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        hintText: 'https://example.com',
                        hintStyle: const TextStyle(color: AppColor.textMuted),
                        prefixIcon: Icon(Icons.link_rounded, color: AppColor.primary),
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: AppColor.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Link Title (Optional)',
                      style: TextStyle(color: AppColor.textMuted, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.getFont(_fontFamily, color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'e.g. Flutter Documentation',
                        hintStyle: const TextStyle(color: AppColor.textMuted),
                        prefixIcon: const Icon(Icons.title_rounded, color: AppColor.textMuted),
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
                      'Notes / Description (Optional)',
                      style: TextStyle(color: AppColor.textMuted, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _contentController,
                      maxLines: 4,
                      style: GoogleFonts.getFont(_fontFamily, color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Add context or summary for this link...',
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
