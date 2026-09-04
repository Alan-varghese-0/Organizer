import 'dart:io';
import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/core/database/database_service.dart';
import 'package:organizer/core/models/project.dart';
import 'package:organizer/features/dashboard/widgets/project_card.dart';
import 'package:organizer/features/project_detail/presentation/screens/project_detail_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  String searchQuery = '';
  String selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final categories = const [
    'All',
    'Mobile App',
    'Web Design',
    'Design System',
    'AI Tools',
    'Branding',
  ];

  List<ProjectItem> get filteredProjects {
    var projects = DatabaseService.instance.getProjects();
    if (selectedCategory != 'All') {
      projects = projects.where((p) => p.category == selectedCategory).toList();
    }
    if (searchQuery.isNotEmpty) {
      projects = projects
          .where((p) =>
              p.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              p.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
              p.category.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    return projects;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: DatabaseService.instance.projectsListenable,
      builder: (context, box, _) {
        final projects = filteredProjects;
        final starredProjects = DatabaseService.instance.getProjects().where((p) => p.isFavorite).toList();

        return Scaffold(
          backgroundColor: AppColor.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Browse',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Explore workspace projects & offline categories',
                          style: TextStyle(fontSize: 13, color: AppColor.textMuted),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => searchQuery = val),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search offline projects...',
                            prefixIcon: const Icon(Icons.search_rounded, color: AppColor.textMuted),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, color: AppColor.textMuted),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => searchQuery = '');
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
                      ],
                    ),
                  ),
                ),

                if (searchQuery.isEmpty && selectedCategory == 'All' && starredProjects.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Text(
                        'Starred Projects',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primarySoft,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: starredProjects.length,
                        itemBuilder: (context, index) {
                          final project = starredProjects[index];
                          final hasBanner = project.bannerPath != null &&
                              project.bannerPath!.isNotEmpty &&
                              File(project.bannerPath!).existsSync();

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProjectDetailScreen(project: project),
                                ),
                              ).then((_) => setState(() {}));
                            },
                            child: Container(
                              width: 250,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: hasBanner
                                      ? Colors.white.withValues(alpha: 0.18)
                                      : project.color.withValues(alpha: 0.4),
                                ),
                                image: hasBanner
                                    ? DecorationImage(
                                        image: FileImage(File(project.bannerPath!)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: hasBanner
                                      ? LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withValues(alpha: 0.25),
                                            Colors.black.withValues(alpha: 0.65),
                                            Colors.black.withValues(alpha: 0.92),
                                          ],
                                          stops: const [0.0, 0.45, 1.0],
                                        )
                                      : LinearGradient(
                                          colors: [
                                            project.color.withValues(alpha: 0.35),
                                            AppColor.surface,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: hasBanner
                                                ? Colors.black.withValues(alpha: 0.55)
                                                : project.color.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: hasBanner
                                                  ? Colors.white.withValues(alpha: 0.2)
                                                  : project.color.withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Text(
                                            project.category,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: hasBanner ? Colors.white : project.color,
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      project.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1)),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${project.resources.length} items • ${project.todos.length} to-dos',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withValues(alpha: 0.75),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final selected = selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: selected,
                            selectedColor: AppColor.primary,
                            backgroundColor: AppColor.surface,
                            labelStyle: TextStyle(
                              color: selected ? Colors.white : AppColor.textMuted,
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            onSelected: (_) {
                              setState(() => selectedCategory = cat);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                projects.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_off_rounded, size: 64, color: AppColor.textMuted.withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              const Text(
                                'No offline projects found',
                                style: TextStyle(color: AppColor.textMuted, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final project = projects[index];
                            return ProjectCard(
                              project: project,
                              onReturn: () => setState(() {}),
                            );
                          },
                          childCount: projects.length,
                        ),
                      ),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
          ),
        );
      },
    );
  }
}
