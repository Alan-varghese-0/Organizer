import 'package:flutter/material.dart';
import 'resource.dart';

class SubTodoItem {
  final String id;
  final String title;
  final bool isCompleted;

  const SubTodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  SubTodoItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class TodoItem {
  final String id;
  final String title;
  final bool isCompleted;
  final List<SubTodoItem> subTodos;

  const TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.subTodos = const [],
  });

  TodoItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    List<SubTodoItem>? subTodos,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      subTodos: subTodos ?? this.subTodos,
    );
  }
}

class ProjectItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final int itemsCount;
  final String updated;
  final Color color;
  final bool isFavorite;
  final List<ResourceItem> resources;
  final String? bannerPath;
  final List<TodoItem> todos;

  const ProjectItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.itemsCount,
    required this.updated,
    required this.color,
    this.isFavorite = false,
    this.resources = const [],
    this.bannerPath,
    this.todos = const [],
  });
}
