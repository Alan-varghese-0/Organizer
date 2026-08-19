import 'package:flutter/material.dart';

enum ResourceType {
  note,
  link,
  image,
  pdf,
  color,
  typography;

  String get displayName {
    switch (this) {
      case ResourceType.note:
        return 'Note';
      case ResourceType.link:
        return 'Link';
      case ResourceType.image:
        return 'Image';
      case ResourceType.pdf:
        return 'PDF';
      case ResourceType.color:
        return 'Color';
      case ResourceType.typography:
        return 'Typography';
    }
  }

  IconData get icon {
    switch (this) {
      case ResourceType.note:
        return Icons.notes_rounded;
      case ResourceType.link:
        return Icons.link_rounded;
      case ResourceType.image:
        return Icons.image_rounded;
      case ResourceType.pdf:
        return Icons.picture_as_pdf_rounded;
      case ResourceType.color:
        return Icons.palette_rounded;
      case ResourceType.typography:
        return Icons.text_fields_rounded;
    }
  }
}

class ResourceItem {
  final String id;
  final String title;
  final String content;
  final ResourceType type;
  final String category;
  final String createdAt;
  final List<String> tags;
  final String? url;
  final String? colorHex;
  final String? fontFamily;
  final bool isFavorite;

  const ResourceItem({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.category,
    required this.createdAt,
    this.tags = const [],
    this.url,
    this.colorHex,
    this.fontFamily,
    this.isFavorite = false,
  });
}
