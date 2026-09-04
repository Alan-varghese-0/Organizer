import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/core/models/project.dart';

class ProjectSelector extends StatelessWidget {
  final List<ProjectItem> projects;
  final String? selectedProjectId;
  final ValueChanged<String?> onChanged;

  const ProjectSelector({
    super.key,
    required this.projects,
    required this.selectedProjectId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: selectedProjectId,
      dropdownColor: AppColor.surface,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Assign to Project (Optional)',
        prefixIcon: Icon(Icons.folder_rounded, color: AppColor.primary),
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text(
            'No project',
            style: TextStyle(color: AppColor.textMuted),
          ),
        ),
        ...projects.map(
          (project) => DropdownMenuItem<String?>(
            value: project.id,
            child: Text(project.title, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
