import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:organizer/core/models/project.dart';
import 'package:organizer/core/models/resource.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();

  DatabaseService._internal();

  late Box _projectsBox;
  late Box _resourcesBox;
  late Box _settingsBox;

  ValueListenable<Box> get projectsListenable => _projectsBox.listenable();
  ValueListenable<Box> get resourcesListenable => _resourcesBox.listenable();

  Future<void> init() async {
    await Hive.initFlutter();

    _projectsBox = await Hive.openBox('projects_box');
    _resourcesBox = await Hive.openBox('resources_box');
    _settingsBox = await Hive.openBox('settings_box');

  }

  List<ProjectItem> getProjects() {
    final List<ProjectItem> list = [];
    for (var i = 0; i < _projectsBox.length; i++) {
      final map = Map<String, dynamic>.from(_projectsBox.getAt(i));
      list.add(_mapToProject(map));
    }
    return list;
  }

  Future<void> saveProject(ProjectItem p) async {
    await _projectsBox.put(p.id, _projectToMap(p));
  }

  Future<void> deleteProject(String id) async {
    await _projectsBox.delete(id);
  }

  Future<void> clearAllData() async {
    await _projectsBox.clear();
    await _resourcesBox.clear();
    await _settingsBox.clear();
  }

  List<ResourceItem> getResources() {
    final List<ResourceItem> list = [];
    for (var i = 0; i < _resourcesBox.length; i++) {
      final map = Map<String, dynamic>.from(_resourcesBox.getAt(i));
      list.add(_mapToResource(map));
    }
    return list;
  }

  Future<void> saveResource(ResourceItem r) async {
    await _resourcesBox.put(r.id, _resourceToMap(r));
  }

  Map<String, dynamic> getSettings() {
    return {
      'workspaceName': _settingsBox.get('workspaceName', defaultValue: 'My Workspace'),
      'theme': _settingsBox.get('theme', defaultValue: 'Dark'),
      'personality': _settingsBox.get('personality', defaultValue: 'Aurora'),
      'aiName': _settingsBox.get('aiName', defaultValue: 'Organizer AI'),
      'aiAutoTagging': _settingsBox.get('aiAutoTagging', defaultValue: true),
    };
  }

  bool get hasCompletedOnboarding => _settingsBox.get('onboardingCompleted', defaultValue: false) as bool;

  Future<void> completeOnboarding() async {
    await _settingsBox.put('onboardingCompleted', true);
  }

  Future<void> updateSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  Map<String, dynamic> _projectToMap(ProjectItem p) {
    return {
      'id': p.id,
      'title': p.title,
      'description': p.description,
      'category': p.category,
      'itemsCount': p.itemsCount,
      'updated': p.updated,
      'colorValue': p.color.toARGB32(),
      'isFavorite': p.isFavorite,
      'resources': p.resources.map((r) => _resourceToMap(r)).toList(),
      'bannerPath': p.bannerPath,
      'todos': p.todos
          .map((t) => {
                'id': t.id,
                'title': t.title,
                'isCompleted': t.isCompleted,
                'subTodos': t.subTodos
                    .map((s) => {
                          'id': s.id,
                          'title': s.title,
                          'isCompleted': s.isCompleted,
                        })
                    .toList(),
              })
          .toList(),
    };
  }

  ProjectItem _mapToProject(Map<String, dynamic> map) {
    final rawRes = map['resources'] as List? ?? [];
    final resourcesList = rawRes
        .map((e) => _mapToResource(Map<String, dynamic>.from(e as Map)))
        .toList();

    final rawTodos = map['todos'] as List? ?? [];
    final todosList = rawTodos.map((t) {
      final tMap = Map<String, dynamic>.from(t as Map);
      final rawSubTodos = tMap['subTodos'] as List? ?? [];
      final subTodosList = rawSubTodos.map((s) {
        final sMap = Map<String, dynamic>.from(s as Map);
        return SubTodoItem(
          id: sMap['id'] ?? '',
          title: sMap['title'] ?? '',
          isCompleted: sMap['isCompleted'] ?? false,
        );
      }).toList();

      return TodoItem(
        id: tMap['id'] ?? '',
        title: tMap['title'] ?? '',
        isCompleted: tMap['isCompleted'] ?? false,
        subTodos: subTodosList,
      );
    }).toList();

    return ProjectItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      itemsCount: map['itemsCount'] ?? 0,
      updated: map['updated'] ?? '',
      color: Color(map['colorValue'] ?? 0xFF8B5CF6),
      isFavorite: map['isFavorite'] ?? false,
      resources: resourcesList,
      bannerPath: map['bannerPath'],
      todos: todosList,
    );
  }

  Map<String, dynamic> _resourceToMap(ResourceItem r) {
    return {
      'id': r.id,
      'title': r.title,
      'content': r.content,
      'typeIndex': r.type.index,
      'category': r.category,
      'createdAt': r.createdAt,
      'tags': r.tags,
      'url': r.url,
      'colorHex': r.colorHex,
      'fontFamily': r.fontFamily,
      'isFavorite': r.isFavorite,
    };
  }

  ResourceItem _mapToResource(Map<String, dynamic> map) {
    final typeIdx = map['typeIndex'] ?? 0;
    return ResourceItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      type: ResourceType.values[typeIdx < ResourceType.values.length ? typeIdx : 0],
      category: map['category'] ?? '',
      createdAt: map['createdAt'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      url: map['url'],
      colorHex: map['colorHex'],
      fontFamily: map['fontFamily'],
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}
