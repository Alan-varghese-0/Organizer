import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/core/database/database_service.dart';
import 'package:organizer/core/models/project.dart';
import 'package:organizer/core/models/resource.dart';
import 'package:uuid/uuid.dart';

class CreateProjectFormSheet extends StatefulWidget {
  final VoidCallback onProjectCreated;

  const CreateProjectFormSheet({super.key, required this.onProjectCreated});

  @override
  State<CreateProjectFormSheet> createState() => _CreateProjectFormSheetState();
}

class _CreateProjectFormSheetState extends State<CreateProjectFormSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String selectedCategory = 'Mobile App';
  Color selectedColor = AppColor.primary;

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
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Create Project',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColor.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Project Title',
              hintText: 'Enter title...',
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: selectedCategory,
            dropdownColor: AppColor.surface,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Category',
            ),
            items: categories
                .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat, style: const TextStyle(color: Colors.white)),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => selectedCategory = val);
            },
          ),
          const SizedBox(height: 16),
          const Text('Theme Color', style: TextStyle(color: AppColor.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: colors.map((c) {
              final isSel = selectedColor == c;
              return GestureDetector(
                onTap: () => setState(() => selectedColor = c),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(color: isSel ? Colors.white : Colors.transparent, width: 3),
                  ),
                  child: isSel ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _descController,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Enter project details...',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () async {
                final title = _titleController.text.trim();
                final desc = _descController.text.trim();
                if (title.isNotEmpty) {
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
                  );
                  await DatabaseService.instance.saveProject(newProject);
                  if (context.mounted) {
                    Navigator.pop(context);
                    widget.onProjectCreated();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Project   created in !'),
                        backgroundColor: AppColor.primary,
                      ),
                    );
                  }
                }
              },
              child: const Text('Create Project', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class CreateResourceFormSheet extends StatefulWidget {
  final String itemType;
  final VoidCallback onSaved;

  const CreateResourceFormSheet({
    super.key,
    required this.itemType,
    required this.onSaved,
  });

  @override
  State<CreateResourceFormSheet> createState() => _CreateResourceFormSheetState();
}

class _CreateResourceFormSheetState extends State<CreateResourceFormSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _urlController = TextEditingController();
  final _hex1Controller = TextEditingController(text: '#8B5CF6');
  final _hex2Controller = TextEditingController(text: '#38BDF8');
  final _hex3Controller = TextEditingController(text: '#0A0B12');
  final _sampleTextController = TextEditingController(text: 'The quick brown fox jumps over the lazy dog');

  String selectedFontFamily = 'Inter';
  String selectedFontWeight = 'Regular';
  String? selectedProjectId;
  late List<ProjectItem> existingProjects;

  final fontFamilies = const [
    'Inter',
    'Roboto',
    'Outfit',
    'Playfair Display',
    'Fira Code',
    'Poppins',
    'Montserrat',
  ];

  final fontWeights = const ['Light', 'Regular', 'Medium', 'SemiBold', 'Bold'];

  @override
  void initState() {
    super.initState();
    existingProjects = DatabaseService.instance.getProjects();
    if (widget.itemType == 'Link') {
      _urlController.text = 'https://';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _urlController.dispose();
    _hex1Controller.dispose();
    _hex2Controller.dispose();
    _hex3Controller.dispose();
    _sampleTextController.dispose();
    super.dispose();
  }

  ResourceType _getResourceType(String itemType) {
    switch (itemType) {
      case 'Note':
        return ResourceType.note;
      case 'Link':
        return ResourceType.link;
      case 'Image':
        return ResourceType.image;
      case 'PDF':
        return ResourceType.pdf;
      case 'Color Combo':
        return ResourceType.color;
      case 'Typography':
        return ResourceType.typography;
      default:
        return ResourceType.note;
    }
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

  Color _parseHex(String hex, Color fallback) {
    try {
      final clean = hex.replaceAll('#', '').trim();
      if (clean.length == 6) {
        return Color(int.parse('0xFF$clean'));
      }
    } catch (_) {}
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.itemType;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add $type',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColor.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Title Field
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: '$type Title',
                hintText: 'Enter title for this $type...',
              ),
            ),
            const SizedBox(height: 14),

            // Assign to Project Dropdown
            DropdownButtonFormField<String?>(
              initialValue: selectedProjectId,
              dropdownColor: AppColor.surface,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Assign to Existing Project',
                hintText: 'General Library (Unassigned)',
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

            const SizedBox(height: 14),

            // Item-type specific fields
            if (type == 'Note') ...[
              TextField(
                controller: _contentController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Note Details / Content',
                  hintText: 'Write your notes or ideas here...',
                ),
              ),
            ] else if (type == 'Link') ...[
              TextField(
                controller: _urlController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Web URL Address',
                  hintText: 'https://example.com',
                  prefixIcon: Icon(Icons.link_rounded, color: AppColor.primary),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _contentController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Description / Notes (Optional)',
                  hintText: 'Add brief summary or tags for this link...',
                ),
              ),
            ] else if (type == 'Image') ...[
              TextField(
                controller: _urlController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Image Source (URL or Path)',
                  hintText: 'https://images.unsplash.com/... or assets/image.jpg',
                  prefixIcon: Icon(Icons.image_rounded, color: AppColor.primary),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _contentController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Caption / Details',
                  hintText: 'Enter image description or notes...',
                ),
              ),
            ] else if (type == 'PDF') ...[
              TextField(
                controller: _urlController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Document Link or Path',
                  hintText: 'https://... or docs/spec.pdf',
                  prefixIcon: Icon(Icons.picture_as_pdf_rounded, color: AppColor.primary),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _contentController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Document Summary',
                  hintText: 'Summary or key takeaways from this PDF...',
                ),
              ),
            ] else if (type == 'Color Combo') ...[
              const Text('Color Swatches (Hex Codes)', style: TextStyle(color: AppColor.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _hex1Controller,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(labelText: 'Primary'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _hex2Controller,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(labelText: 'Accent'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _hex3Controller,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(labelText: 'Background'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Live Color Palette Preview Card
              Container(
                height: 54,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColor.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColor.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: _parseHex(_hex1Controller.text, AppColor.primary),
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                        ),
                        child: Center(
                          child: Text(
                            _hex1Controller.text,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: _parseHex(_hex2Controller.text, const Color(0xFF38BDF8)),
                        child: Center(
                          child: Text(
                            _hex2Controller.text,
                            style: const TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: _parseHex(_hex3Controller.text, const Color(0xFF0A0B12)),
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                        ),
                        child: Center(
                          child: Text(
                            _hex3Controller.text,
                            style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (type == 'Typography') ...[
              DropdownButtonFormField<String>(
                initialValue: selectedFontFamily,
                dropdownColor: AppColor.surface,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Font Family'),
                items: fontFamilies
                    .map((font) => DropdownMenuItem(
                          value: font,
                          child: Text(font, style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedFontFamily = val);
                },
              ),
              const SizedBox(height: 14),
              const Text('Font Weight', style: TextStyle(color: AppColor.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
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
              const SizedBox(height: 14),
              TextField(
                controller: _sampleTextController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Sample Text Preview',
                  hintText: 'Enter sample text...',
                ),
              ),
              const SizedBox(height: 14),
              // Live Typography Preview Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColor.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preview: $selectedFontFamily ($selectedFontWeight)',
                      style: TextStyle(fontSize: 11, color: AppColor.primarySoft, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _sampleTextController.text.isEmpty
                          ? 'The quick brown fox jumps over the lazy dog'
                          : _sampleTextController.text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: _getFontWeight(selectedFontWeight),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  final title = _titleController.text.trim();
                  if (title.isEmpty) return;

                  final uniqueId = const Uuid().v4();
                  final resType = _getResourceType(widget.itemType);

                  String content = '';
                  String? url;
                  String? colorHex;
                  String? fontFamily;
                  String category = 'General';

                  if (type == 'Note') {
                    content = _contentController.text.trim().isEmpty ? 'Notes content' : _contentController.text.trim();
                    category = 'Notes';
                  } else if (type == 'Link') {
                    url = _urlController.text.trim();
                    content = _contentController.text.trim().isEmpty ? url : _contentController.text.trim();
                    category = 'Links';
                  } else if (type == 'Image') {
                    url = _urlController.text.trim();
                    content = _contentController.text.trim().isEmpty ? 'Image asset' : _contentController.text.trim();
                    category = 'Media';
                  } else if (type == 'PDF') {
                    url = _urlController.text.trim();
                    content = _contentController.text.trim().isEmpty ? 'PDF document' : _contentController.text.trim();
                    category = 'Media';
                  } else if (type == 'Color Combo') {
                    colorHex = _hex1Controller.text.trim();
                    content = 'Palette: Primary ${_hex1Controller.text}, Accent ${_hex2Controller.text}, Background ${_hex3Controller.text}';
                    category = 'Design Tokens';
                  } else if (type == 'Typography') {
                    fontFamily = selectedFontFamily;
                    content = 'Spec: $selectedFontFamily ($selectedFontWeight) - ${_sampleTextController.text.trim()}';
                    category = 'Design Tokens';
                  }

                  final newResource = ResourceItem(
                    id: uniqueId,
                    title: title,
                    content: content,
                    type: resType,
                    category: category,
                    createdAt: 'Just now',
                    url: url,
                    colorHex: colorHex,
                    fontFamily: fontFamily,
                    tags: [type.replaceAll(' ', '')],
                  );

                  await DatabaseService.instance.saveResource(newResource);

                  if (selectedProjectId != null) {
                    final projList = DatabaseService.instance.getProjects();
                    final targetProj = projList.firstWhere((p) => p.id == selectedProjectId, orElse: () => projList.first);
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

                  if (context.mounted) {
                    Navigator.pop(context);
                    widget.onSaved();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$type saved successfully!'),
                        backgroundColor: AppColor.primary,
                      ),
                    );
                  }
                },
                child: Text(
                  'Save $type',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
