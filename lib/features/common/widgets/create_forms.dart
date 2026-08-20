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
  final _hex1Controller = TextEditingController(text: '#8B5CF6');
  final _hex2Controller = TextEditingController(text: '#38BDF8');
  final _hex3Controller = TextEditingController(text: '#0A0B12');

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
    _contentController.dispose();
    _hex1Controller.dispose();
    _hex2Controller.dispose();
    _hex3Controller.dispose();
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

  Color _parseHex(String hex, Color fallback) {
    try {
      final clean = hex.replaceAll('#', '').trim();
      if (clean.length == 6) {
        return Color(int.parse('0xFF'));
      }
    } catch (_) {}
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final isColorCombo = widget.itemType == 'Color Combo';

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
              Text(
                'Add ',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColor.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: ' Title',
              hintText: 'Enter title...',
            ),
          ),
          const SizedBox(height: 14),

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

          if (isColorCombo) ...[
            const Text('Color Combination / Palette Swatches', style: TextStyle(color: AppColor.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 12),
            Container(
              height: 44,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColor.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColor.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _parseHex(_hex1Controller.text, AppColor.primary),
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: _parseHex(_hex2Controller.text, const Color(0xFF38BDF8)),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _parseHex(_hex3Controller.text, const Color(0xFF0A0B12)),
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            TextField(
              controller: _contentController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: widget.itemType == 'Link' ? 'URL' : 'Details / Content',
                hintText: widget.itemType == 'Link' ? 'https://...' : 'Enter content...',
              ),
            ),
          ],

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
                final content = isColorCombo
                    ? 'Color Combo Palette: , , '
                    : _contentController.text.trim();

                if (title.isNotEmpty) {
                  final uniqueId = const Uuid().v4();
                  final type = _getResourceType(widget.itemType);

                  final newResource = ResourceItem(
                    id: uniqueId,
                    title: title,
                    content: content.isEmpty ? 'Saved resource' : content,
                    type: type,
                    category: isColorCombo ? 'Design Tokens' : 'General',
                    createdAt: 'Just now',
                    url: widget.itemType == 'Link' ? content : null,
                    colorHex: isColorCombo ? _hex1Controller.text : null,
                    tags: [widget.itemType.replaceAll(' ', '')],
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
                        content: Text('  saved successfully!'),
                        backgroundColor: AppColor.primary,
                      ),
                    );
                  }
                }
              },
              child: Text('Save ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
