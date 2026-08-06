import 'package:flutter/material.dart';
import 'empty_project_state.dart';
import 'project_card.dart';

class ProjectList extends StatelessWidget {
  const ProjectList({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = [
      (title: "Organizer", items: 24, updated: "2h ago"),
      (title: "Portfolio", items: 12, updated: "Yesterday"),
      (title: "Flutter UI", items: 43, updated: "3 days ago"),
    ];

    if (projects.isEmpty) {
      return EmptyProjectState(onCreateProject: () {});
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: projects.length,
      itemBuilder: (_, index) {
        final project = projects[index];

        return ProjectCard(
          title: project.title,
          items: project.items,
          updated: project.updated,
        );
      },
    );
  }
}
