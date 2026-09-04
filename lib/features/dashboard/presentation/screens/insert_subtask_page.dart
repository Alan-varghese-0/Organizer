import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/core/database/database_service.dart';
import 'package:organizer/core/models/project.dart';
import 'package:uuid/uuid.dart';

class InsertSubtaskPage extends StatefulWidget {
  final String projectId;

  const InsertSubtaskPage({super.key, required this.projectId});

  @override
  State<InsertSubtaskPage> createState() => _InsertSubtaskPageState();
}

class _InsertSubtaskPageState extends State<InsertSubtaskPage> {
  final _titleController = TextEditingController();
  late final ProjectItem _project;
  String? _parentTodoId;

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
    super.dispose();
  }

  Future<void> _saveSubtask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _parentTodoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a subtask and choose a parent to-do.')),
      );
      return;
    }

    final updatedTodos = _project.todos.map((todo) {
      if (todo.id != _parentTodoId) return todo;
      return todo.copyWith(
        subTodos: [
          ...todo.subTodos,
          SubTodoItem(id: const Uuid().v4(), title: title),
        ],
      );
    }).toList();

    await DatabaseService.instance.saveProject(
      ProjectItem(
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
        todos: updatedTodos,
      ),
    );

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        title: const Text('Create Subtask', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _saveSubtask,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Save'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Parent To-Do', style: TextStyle(color: AppColor.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _parentTodoId,
            dropdownColor: AppColor.surface,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              filled: true,
              fillColor: AppColor.surfaceAlt,
              border: OutlineInputBorder(),
            ),
            hint: const Text('Choose a to-do', style: TextStyle(color: AppColor.textMuted)),
            items: _project.todos
                .map((todo) => DropdownMenuItem(value: todo.id, child: Text(todo.title)))
                .toList(),
            onChanged: (value) => setState(() => _parentTodoId = value),
          ),
          const SizedBox(height: 20),
          const Text('Subtask Title', style: TextStyle(color: AppColor.textSecondary, fontWeight: FontWeight.bold)),
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
        ],
      ),
    );
  }
}
