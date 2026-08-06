import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  final String title;
  final int items;
  final String updated;

  const ProjectCard({
    super.key,
    required this.title,
    required this.items,
    required this.updated,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      elevation: .5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.folder_open)),
        title: Text(title),
        subtitle: Text("$items Resources\nUpdated $updated"),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
