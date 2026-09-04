import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/core/database/database_service.dart';
import 'package:organizer/core/models/project.dart';
import 'package:organizer/core/models/resource.dart';
import 'package:uuid/uuid.dart';

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
  late List<TodoItem> todos;
  final Set<String> expandedTodoIds = {};

  final categories = const ['All', 'To-Dos', 'Notes', 'Links', 'Media', 'Design Specs'];

  @override
  void initState() {
    super.initState();
    isFav = widget.project.isFavorite;
    items = List.from(widget.project.resources);
    todos = List.from(widget.project.todos);
  }

  List<ResourceItem> get filteredItems {
    if (selectedCategoryIndex == 0) return items;
    if (selectedCategoryIndex == 1) return []; // To-Dos tab handled separately
    if (selectedCategoryIndex == 2) {
      return items.where((i) => i.type == ResourceType.note).toList();
    }
    if (selectedCategoryIndex == 3) {
      return items.where((i) => i.type == ResourceType.link).toList();
    }
    if (selectedCategoryIndex == 4) {
      return items.where((i) => i.type == ResourceType.image || i.type == ResourceType.pdf).toList();
    }
    if (selectedCategoryIndex == 5) {
      return items.where((i) => i.type == ResourceType.color || i.type == ResourceType.typography).toList();
    }
    return items;
  }

  Future<void> _saveProjectState() async {
    final updatedProj = ProjectItem(
      id: widget.project.id,
      title: widget.project.title,
      description: widget.project.description,
      category: widget.project.category,
      itemsCount: items.length,
      updated: 'Just now',
      color: widget.project.color,
      isFavorite: isFav,
      resources: items,
      bannerPath: widget.project.bannerPath,
      todos: todos,
    );
    await DatabaseService.instance.saveProject(updatedProj);
  }

  void _toggleTodoCompleted(int index) {
    final current = todos[index];

    // If trying to mark the parent todo as completed, ensure all sub-tasks are completed first
    final hasSubTodos = current.subTodos.isNotEmpty;
    final allSubDone = hasSubTodos ? current.subTodos.every((s) => s.isCompleted) : true;

    if (!current.isCompleted && hasSubTodos && !allSubDone) {
      // Notify the user and prevent checking the main todo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete all sub-tasks before marking this task complete')),
      );
      return;
    }

    setState(() {
      todos[index] = current.copyWith(isCompleted: !current.isCompleted);
    });
    _saveProjectState();
  }

  void _toggleSubTodoCompleted(int todoIndex, int subIndex) {
    setState(() {
      final parent = todos[todoIndex];
      final updatedSubTodos = List<SubTodoItem>.from(parent.subTodos);
      final currentSub = updatedSubTodos[subIndex];
      updatedSubTodos[subIndex] = currentSub.copyWith(isCompleted: !currentSub.isCompleted);
      
      // Auto complete parent if all sub-todos are completed
      final allSubDone = updatedSubTodos.every((s) => s.isCompleted);
      todos[todoIndex] = parent.copyWith(
        subTodos: updatedSubTodos,
        isCompleted: updatedSubTodos.isNotEmpty ? allSubDone : parent.isCompleted,
      );
    });
    _saveProjectState();
  }

  void _openAddTodoDialog() {
    final titleController = TextEditingController();
    final List<TextEditingController> subTodoControllers = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                        'Add New To-Do',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColor.textMuted),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'What needs to be done?',
                      hintStyle: const TextStyle(color: AppColor.textMuted),
                      filled: true,
                      fillColor: AppColor.surfaceAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sub-tasks / Steps',
                        style: TextStyle(color: AppColor.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setModalState(() {
                            subTodoControllers.add(TextEditingController());
                          });
                        },
                        icon: Icon(Icons.add_rounded, size: 16, color: AppColor.primary),
                        label: Text('Add Sub-task', style: TextStyle(color: AppColor.primary, fontSize: 12)),
                      ),
                    ],
                  ),
                  if (subTodoControllers.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: subTodoControllers.length,
                      itemBuilder: (context, subIdx) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.subdirectory_arrow_right_rounded, color: AppColor.textMuted, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: subTodoControllers[subIdx],
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'Sub-task detail...',
                                    hintStyle: const TextStyle(color: AppColor.textMuted),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    filled: true,
                                    fillColor: AppColor.surfaceAlt,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 20),
                                onPressed: () {
                                  setModalState(() {
                                    subTodoControllers.removeAt(subIdx);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        if (title.isEmpty) return;

                        final newSubTodos = subTodoControllers
                            .map((c) => c.text.trim())
                            .where((t) => t.isNotEmpty)
                            .map((t) => SubTodoItem(id: const Uuid().v4(), title: t, isCompleted: false))
                            .toList();

                        final newTodo = TodoItem(
                          id: const Uuid().v4(),
                          title: title,
                          isCompleted: false,
                          subTodos: newSubTodos,
                        );

                        setState(() {
                          todos.add(newTodo);
                        });
                        _saveProjectState();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Add To-Do', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openEditTodoDialog(TodoItem todo, int todoIndex) {
    final titleController = TextEditingController(text: todo.title);
    final List<SubTodoItem> currentSubTodos = List.from(todo.subTodos);
    final newSubController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                        'Edit To-Do',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            todos.removeAt(todoIndex);
                          });
                          _saveProjectState();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'To-Do Title',
                      labelStyle: const TextStyle(color: AppColor.textSecondary),
                      filled: true,
                      fillColor: AppColor.surfaceAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sub-tasks',
                    style: TextStyle(color: AppColor.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (currentSubTodos.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentSubTodos.length,
                      itemBuilder: (context, sIdx) {
                        final sub = currentSubTodos[sIdx];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Checkbox(
                                value: sub.isCompleted,
                                activeColor: AppColor.primary,
                                onChanged: (val) {
                                  setModalState(() {
                                    currentSubTodos[sIdx] = sub.copyWith(isCompleted: val ?? false);
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  sub.title,
                                  style: TextStyle(
                                    color: sub.isCompleted ? AppColor.textMuted : Colors.white,
                                    decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, color: AppColor.textMuted, size: 18),
                                onPressed: () {
                                  setModalState(() {
                                    currentSubTodos.removeAt(sIdx);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: newSubController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Add new sub-task...',
                            hintStyle: const TextStyle(color: AppColor.textMuted),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            filled: true,
                            fillColor: AppColor.surfaceAlt,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () {
                          final text = newSubController.text.trim();
                          if (text.isEmpty) return;
                          setModalState(() {
                            currentSubTodos.add(SubTodoItem(
                              id: const Uuid().v4(),
                              title: text,
                              isCompleted: false,
                            ));
                            newSubController.clear();
                          });
                        },
                        icon: const Icon(Icons.add_rounded, size: 20),
                        style: IconButton.styleFrom(backgroundColor: AppColor.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        if (title.isEmpty) return;

                        setState(() {
                          final allDone = currentSubTodos.isNotEmpty ? currentSubTodos.every((s) => s.isCompleted) : todo.isCompleted;
                          todos[todoIndex] = todo.copyWith(
                            title: title,
                            subTodos: currentSubTodos,
                            isCompleted: allDone,
                          );
                        });
                        _saveProjectState();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasBanner = widget.project.bannerPath != null && File(widget.project.bannerPath!).existsSync();

    return Scaffold(
      backgroundColor: AppColor.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTodoDialog,
        backgroundColor: AppColor.primary,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text('Add To-Do', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 230,
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
                onPressed: () {
                  setState(() {
                    isFav = !isFav;
                  });
                  _saveProjectState();
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
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasBanner)
                    Image.file(
                      File(widget.project.bannerPath!),
                      fit: BoxFit.cover,
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          hasBanner ? Colors.black.withValues(alpha: 0.75) : widget.project.color.withValues(alpha: 0.35),
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
                            color: widget.project.color.withValues(alpha: 0.25),
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
                ],
              ),
            ),
          ),

          // Category filter tabs
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

          // Render To-Dos list section if selected category is 'All' or 'To-Dos'
          if (selectedCategoryIndex == 0 || selectedCategoryIndex == 1)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.task_alt_rounded, color: AppColor.primary, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Project To-Dos',
                              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColor.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${todos.where((t) => t.isCompleted).length}/${todos.length}',
                                style: TextStyle(color: AppColor.primary, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: _openAddTodoDialog,
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Add Task', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (todos.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColor.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColor.border),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.checklist_rounded, color: AppColor.textMuted, size: 40),
                            const SizedBox(height: 8),
                            const Text('No To-Dos added yet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            const Text('Tap "Add To-Do" button to create tasks & sub-tasks', style: TextStyle(color: AppColor.textMuted, fontSize: 12)),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: todos.length,
                        itemBuilder: (context, tIdx) {
                          final todo = todos[tIdx];
                          final isExpanded = expandedTodoIds.contains(todo.id);
                          final completedSubCount = todo.subTodos.where((s) => s.isCompleted).length;

                          return Material(
                            color: AppColor.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: todo.isCompleted ? AppColor.primary.withValues(alpha: 0.3) : AppColor.border),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  leading: Checkbox(
                                    value: todo.isCompleted,
                                    activeColor: AppColor.primary,
                                    onChanged: (_) => _toggleTodoCompleted(tIdx),
                                  ),
                                  title: Text(
                                    todo.title,
                                    style: TextStyle(
                                      color: todo.isCompleted ? AppColor.textMuted : Colors.white,
                                      fontWeight: FontWeight.w600,
                                      decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  subtitle: todo.subTodos.isNotEmpty
                                      ? Text(
                                          '$completedSubCount of ${todo.subTodos.length} sub-tasks completed',
                                          style: const TextStyle(color: AppColor.textMuted, fontSize: 12),
                                        )
                                      : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_rounded, color: AppColor.textMuted, size: 18),
                                        onPressed: () => _openEditTodoDialog(todo, tIdx),
                                      ),
                                      if (todo.subTodos.isNotEmpty)
                                        IconButton(
                                          icon: Icon(
                                            isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                            color: AppColor.textMuted,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (isExpanded) {
                                                expandedTodoIds.remove(todo.id);
                                              } else {
                                                expandedTodoIds.add(todo.id);
                                              }
                                            });
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                                if (isExpanded || (todo.subTodos.isNotEmpty && selectedCategoryIndex == 1))
                                  Container(
                                    padding: const EdgeInsets.only(left: 48, right: 16, bottom: 12),
                                    child: Column(
                                      children: todo.subTodos.asMap().entries.map((entry) {
                                        final sIdx = entry.key;
                                        final sub = entry.value;
                                        return InkWell(
                                          onTap: () => _toggleSubTodoCompleted(tIdx, sIdx),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  sub.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                                  size: 18,
                                                  color: sub.isCompleted ? AppColor.primary : AppColor.textMuted,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    sub.title,
                                                    style: TextStyle(
                                                      color: sub.isCompleted ? AppColor.textMuted : Colors.white70,
                                                      fontSize: 13,
                                                      decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

          // Render Resources list section if category is not 'To-Dos'
          if (selectedCategoryIndex != 1)
            filteredItems.isEmpty && (selectedCategoryIndex != 0 || todos.isNotEmpty)
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open_rounded, size: 48, color: AppColor.textMuted.withValues(alpha: 0.5)),
                            const SizedBox(height: 8),
                            const Text(
                              'No saved resources in this category',
                              style: TextStyle(color: AppColor.textMuted, fontSize: 14),
                            ),
                          ],
                        ),
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
