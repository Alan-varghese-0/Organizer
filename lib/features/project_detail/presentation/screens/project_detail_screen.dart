import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/core/database/database_service.dart';
import 'package:organizer/core/models/project.dart';
import 'package:organizer/core/models/resource.dart';

class ProjectDetailScreen extends StatefulWidget {
  final ProjectItem project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  int selectedCategoryIndex = 0;
  late bool isFav;
  late List<ResourceItem> items;

  final categories = const ['All', 'Notes', 'Links', 'Media', 'Design Specs'];

  @override
  void initState() {
    super.initState();
    isFav = widget.project.isFavorite;
    items = List.from(widget.project.resources);
  }

  List<ResourceItem> get filteredItems {
    if (selectedCategoryIndex == 0) return items;
    if (selectedCategoryIndex == 1) {
      return items.where((i) => i.type == ResourceType.note).toList();
    }
    if (selectedCategoryIndex == 2) {
      return items.where((i) => i.type == ResourceType.link).toList();
    }
    if (selectedCategoryIndex == 3) {
      return items.where((i) => i.type == ResourceType.image || i.type == ResourceType.pdf).toList();
    }
    if (selectedCategoryIndex == 4) {
      return items.where((i) => i.type == ResourceType.color || i.type == ResourceType.typography).toList();
    }
    return items;
  }

  void _showResourceDetails(ResourceItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.type.icon, color: AppColor.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          ' • ',
                          style: const TextStyle(fontSize: 12, color: AppColor.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item.content,
                  style: const TextStyle(fontSize: 14, color: AppColor.textSecondary, height: 1.4),
                ),
              ),
              if (item.url != null) ...[
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: item.url!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied to clipboard!')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColor.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link_rounded, color: AppColor.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.url!,
                            style: const TextStyle(color: AppColor.primary, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.copy_rounded, color: AppColor.primary, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
              if (item.colorHex != null) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(int.parse(item.colorHex!.replaceAll('#', '0xFF'))),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white24),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      item.colorHex!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                children: item.tags
                    .map((t) => Chip(
                          label: Text('#', style: const TextStyle(fontSize: 11, color: AppColor.primarySoft)),
                          backgroundColor: AppColor.surfaceAlt,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColor.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isFav ? Colors.amber : Colors.white70,
                ),
                onPressed: () async {
                  final newFavoriteValue = !isFav;
                  setState(() {
                    isFav = newFavoriteValue;
                  });
                  await DatabaseService.instance.saveProject(
                    ProjectItem(
                      id: widget.project.id,
                      title: widget.project.title,
                      description: widget.project.description,
                      category: widget.project.category,
                      itemsCount: widget.project.itemsCount,
                      updated: widget.project.updated,
                      color: widget.project.color,
                      isFavorite: newFavoriteValue,
                      resources: widget.project.resources,
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                onPressed: () async {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Delete project?'),
                      content: const Text('This project and its saved resources will be removed.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (shouldDelete != true) return;
                  await DatabaseService.instance.deleteProject(widget.project.id);
                  if (!mounted) return;
                  Navigator.pop(context);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.project.color.withValues(alpha: 0.35),
                      AppColor.background,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.project.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: widget.project.color.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        widget.project.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: widget.project.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.project.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.project.description,
                      style: const TextStyle(fontSize: 13, color: AppColor.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final selected = selectedCategoryIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(categories[index]),
                      selected: selected,
                      selectedColor: AppColor.primary,
                      backgroundColor: AppColor.surface,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColor.textMuted,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onSelected: (_) {
                        setState(() {
                          selectedCategoryIndex = index;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          filteredItems.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_rounded, size: 64, color: AppColor.textMuted.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        const Text(
                          'No resources in this category',
                          style: TextStyle(color: AppColor.textMuted, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = filteredItems[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: AppColor.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(14),
                            leading: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppColor.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(item.type.icon, color: AppColor.primary),
                            ),
                            title: Text(
                              item.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                item.content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppColor.textMuted, fontSize: 13),
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded, color: AppColor.textMuted),
                            onTap: () => _showResourceDetails(item),
                          ),
                        );
                      },
                      childCount: filteredItems.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
