import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/core/database/database_service.dart';
import 'package:organizer/core/models/project.dart';
import 'package:uuid/uuid.dart';

class InsertTodoPage extends StatefulWidget {
  final String projectId;

  const InsertTodoPage({super.key, required this.projectId});

  @override
  State<InsertTodoPage> createState() => _InsertTodoPageState();
}

class _InsertTodoPageState extends State<InsertTodoPage> {
  final _titleController = TextEditingController();
  final _subtaskControllers = <TextEditingController>[];
  late final ProjectItem _project;

  @override
  void initState() {
    super.initState();
    final project = DatabaseService.instance
        .getProjects()
        .where((item) => item.id == widget.projectId)
        .firstOrNull;
    if (project == null) {
      throw StateError('Project ${widget.projectId} was not found.');
    }
    _project = project;
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final controller in _subtaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveTodo() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a to-do title.')),
      );
      return;
    }

    final subTodos = _subtaskControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .map((text) => SubTodoItem(id: const Uuid().v4(), title: text))
        .toList();

    final todo = TodoItem(
      id: const Uuid().v4(),
      title: title,
      subTodos: subTodos,
    );
    final updatedProject = ProjectItem(
      id: _project.id,
      title: _project.title,
      description: _project.description,
      category: _project.category,
      itemsCount: _project.itemsCount,
      updated: 'Just now',
      color: _project.color,
      isFavorite: _project.isFavorite,
      resources: _project.resources,
      bannerPath: _project.bannerPath,
      todos: [..._project.todos, todo],
    );

    await DatabaseService.instance.saveProject(updatedProject);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        title: const Text('Create To-Do', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _saveTodo,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Save'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'To-Do Title',
            style: TextStyle(color: AppColor.textSecondary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'What needs to be done?',
              filled: true,
              fillColor: AppColor.surfaceAlt,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtasks',
                style: TextStyle(color: AppColor.textSecondary, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => setState(() {
                  _subtaskControllers.add(TextEditingController());
                }),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add subtask'),
              ),
            ],
          ),
          ..._subtaskControllers.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: entry.value,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Subtask ${entry.key + 1}',
                      filled: true,
                      fillColor: AppColor.surfaceAlt,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColor.textMuted),
                        onPressed: () => setState(() {
                          final controller = _subtaskControllers.removeAt(entry.key);
                          controller.dispose();
                        }),
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
