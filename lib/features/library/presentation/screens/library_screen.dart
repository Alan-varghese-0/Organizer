import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/core/database/database_service.dart';
import 'package:organizer/core/models/resource.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int selectedCategoryIndex = 0;
  bool isGridView = true;
  bool showFavoritesOnly = false;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final categories = const ['All', 'Notes', 'Links', 'Media', 'Design Specs'];

  List<ResourceItem> get filteredResources {
    var list = DatabaseService.instance.getResources();
    if (showFavoritesOnly) {
      list = list.where((r) => r.isFavorite).toList();
    }
    if (searchQuery.isNotEmpty) {
      list = list
          .where((r) =>
              r.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              r.content.toLowerCase().contains(searchQuery.toLowerCase()) ||
              r.category.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    if (selectedCategoryIndex == 1) {
      return list.where((r) => r.type == ResourceType.note).toList();
    }
    if (selectedCategoryIndex == 2) {
      return list.where((r) => r.type == ResourceType.link).toList();
    }
    if (selectedCategoryIndex == 3) {
      return list.where((r) => r.type == ResourceType.image || r.type == ResourceType.pdf).toList();
    }
    if (selectedCategoryIndex == 4) {
      return list.where((r) => r.type == ResourceType.color || r.type == ResourceType.typography).toList();
    }
    return list;
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(item.type.icon, color: AppColor.primary, size: 26),
                  ),
                  const SizedBox(width: 14),
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
                        Icon(Icons.link_rounded, color: AppColor.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.url!,
                            style: TextStyle(color: AppColor.primary, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.copy_rounded, color: AppColor.primary, size: 18),
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
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Color(int.parse(item.colorHex!.replaceAll('#', '0xFF'))),
                        borderRadius: BorderRadius.circular(12),
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
                          label: Text('#', style: TextStyle(fontSize: 11, color: AppColor.primarySoft)),
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
    return ValueListenableBuilder(
      valueListenable: DatabaseService.instance.resourcesListenable,
      builder: (context, box, _) {
        final resources = filteredResources;

        return Scaffold(
          backgroundColor: AppColor.background,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Library',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Offline saved assets, notes, and links',
                            style: TextStyle(fontSize: 13, color: AppColor.textMuted),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              showFavoritesOnly ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: showFavoritesOnly ? Colors.amber : Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                showFavoritesOnly = !showFavoritesOnly;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                isGridView = !isGridView;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val;
                      });
                    },
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search offline library...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColor.textMuted),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: AppColor.textMuted),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColor.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                SizedBox(
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

                const SizedBox(height: 12),

                Expanded(
                  child: resources.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 64, color: AppColor.textMuted.withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              const Text(
                                'No library resources found',
                                style: TextStyle(color: AppColor.textMuted, fontSize: 15),
                              ),
                            ],
                          ),
                        )
                      : isGridView
                          ? GridView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: resources.length,
                              itemBuilder: (context, index) {
                                final item = resources[index];
                                return _buildGridCard(item);
                              },
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                              itemCount: resources.length,
                              itemBuilder: (context, index) {
                                final item = resources[index];
                                return _buildListCard(item);
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridCard(ResourceItem item) {
    return GestureDetector(
      onTap: () => _showResourceDetails(item),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColor.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.type.icon, color: AppColor.primary, size: 20),
                ),
                if (item.isFavorite)
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              ],
            ),
            const Spacer(),
            Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              item.content,
              style: const TextStyle(color: AppColor.textMuted, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              item.createdAt,
              style: TextStyle(color: AppColor.textMuted.withValues(alpha: 0.7), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(ResourceItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColor.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColor.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(item.type.icon, color: AppColor.primary),
        ),
        title: Text(
          item.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        trailing: item.isFavorite
            ? const Icon(Icons.star_rounded, color: Colors.amber, size: 20)
            : const Icon(Icons.chevron_right_rounded, color: AppColor.textMuted),
        onTap: () => _showResourceDetails(item),
      ),
    );
  }
}
