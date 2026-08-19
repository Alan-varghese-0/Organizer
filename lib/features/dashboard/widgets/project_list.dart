import 'package:flutter/material.dart';
import 'package:organizer/core/models/mock_data.dart';
import 'empty_project_state.dart';
import 'project_card.dart';

class ProjectList extends StatelessWidget {
  const ProjectList({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = MockData.sampleProjects;

    if (projects.isEmpty) {
      return EmptyProjectState(onCreateProject: () {});
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 6, bottom: 20),
      itemCount: projects.length,
      itemBuilder: (_, index) {
        final project = projects[index];

        return ProjectCard(
          project: project,
        );
      },
    );
  }
}
