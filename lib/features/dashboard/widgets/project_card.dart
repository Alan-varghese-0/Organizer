import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/core/models/project.dart';
import 'package:organizer/features/project_detail/presentation/screens/project_detail_screen.dart';

class ProjectCard extends StatelessWidget {
  final ProjectItem project;

  const ProjectCard({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      color: AppColor.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColor.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: project.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.folder_open_rounded, color: project.color),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                project.title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            if (project.isFavorite)
              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            ' Resources • Updated ',
            style: const TextStyle(color: AppColor.textMuted, fontSize: 12),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColor.textMuted),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectDetailScreen(project: project),
            ),
          );
        },
      ),
    );
  }
}
