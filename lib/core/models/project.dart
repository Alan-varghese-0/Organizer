import 'package:flutter/material.dart';
import 'resource.dart';

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
  });
}
